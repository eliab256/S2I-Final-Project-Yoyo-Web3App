// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IYoyoNft } from '../YoyoNft/IYoyoNft.sol';
import { ReentrancyGuard } from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { AutomationCompatibleInterface } from '@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol';
import {
    IAutomationRegistryConsumer
} from '@chainlink/contracts/src/v0.8/automation/interfaces/IAutomationRegistryConsumer.sol';
import { IERC721Receiver } from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import { YoyoDutchAuctionLibrary } from './YoyoDutchAuctionLibrary.sol';
import './YoyoAuctionEvents.sol';
import './YoyoAuctionErrors.sol';
import { AuctionStruct, AuctionState, AuctionType } from '../YoyoTypes.sol';
import { console2 } from 'forge-std/console2.sol';

/**
 * @title Nft Auction System
 * @author Elia Bordoni
 * @notice This contract manages english and dutch auction for Nft collection
 * @dev Implements automated auction lifecycle with reentrancy protection and Chainlink upkeep integration
 */

contract YoyoAuction is ReentrancyGuard, Ownable, AutomationCompatibleInterface, IERC721Receiver {
    /**
     * @dev Interface that allows contract to acces the NFT contract
     */
    IYoyoNft private yoyoNftContract;

    /**
     * @dev Interface for the chainlink automation registry
     */
    IAutomationRegistryConsumer public immutable i_registry;

    /* Errors */
    /**
     * @dev Errors are declared in YoyoAuctionErrors.sol
     */

    /* Type Declaration */
    /**
     * @dev Enums and Structs are declared in YoyoTypes.sol
     */

    /* State variables */

    /**
     * @dev Percentage of basic mint price used for minimum bid increment (in per-mille)
     * @dev 25 per-mille = 2.5% (25/1000 = 0.025)
     * @dev Used to calculate s_minimumBidChangeAmount for English auctions
     */
    uint256 private constant MINIMUM_BID_INCREMENT_PERCENTAGE = 25;

    /**
     * @dev Denominator for percentage calculations (represents 100%)
     * @dev Using 1000 instead of 100 provides better precision for decimal percentages
     */
    uint256 private constant PERCENTAGE_DENOMINATOR = 1000;

    /**
     * @notice Minimum multiplier to calculate the minimum mint price
     * @dev Used to ensure minimum mint price is big enough to avoid rounding issues with percentage calculations
     */
    uint256 private constant MINIMUM_POSSIBLE_MINT_PRICE = PERCENTAGE_DENOMINATOR / MINIMUM_BID_INCREMENT_PERCENTAGE;

    /**
     * @dev Minimum amount required to increase a bid in English auctions
     * @dev Set to 2.5% of the basic mint price when NFT contract is initialized
     */
    uint256 private s_minimumBidChangeAmount;
    /**
     * @dev Duration of each auction in seconds (default: 24 hours)
     */
    uint256 private constant AUCTION_DURATION = 24 hours;

    /**
     * @dev Time window during which only Chainlink Automation can close/restart auctions
     * @dev After this period elapses, any user can call manual close functions as a fallback
     * @dev Default: 6 hours (21600 seconds)
     * @dev Provides resilience against Chainlink Automation downtime or failures
     */
    uint256 private constant GRACE_PERIOD = 6 hours;

    /**
     * @dev Counter that tracks the total number of auctions created
     * @dev Also serves as the ID for the current/latest auction
     */
    uint256 private s_auctionCounter;

    /**
     * @dev Number of price drop intervals for Dutch auctions (default: 48)
     * @dev Price drops occur at regular intervals throughout the auction duration
     */
    uint256 private constant DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS = 48;

    /**
     * @dev Multiplier used to calculate Dutch auction starting price
     * @dev Start price = basic mint price * multiplier (default: 13x)
     */
    uint256 private constant DUTCH_AUCTION_START_PRICE_MULTIPLIER = 13;

    /** 
    @dev Mapping used to retrieve any necessary information about an auction starting from its auctionId.
    */
    mapping(uint256 => AuctionStruct) internal s_auctionsFromAuctionId;

    /**
     * @notice This mapping handles 3 different scenarios:
     * 1. The address has no token to claim, therefore returns 0
     * 2. The address has a token to claim and it was minted by this contract,
     *    therefore returns uint256.max which indicates no payment is required
     *    because the mint was already paid at auction close by this contract
     * 3. The address returns a value different from 0 and uint256.max.
     *    This means the address is entitled to claim a token that must be minted
     *    and therefore must be paid for
     * @dev Mapping used to track the unsuccessful token claim to the winners.
     * @dev In case the mint to the winner fails, the winner can claim the token later.
     * @dev winner --> tokenId --> mintPrice
     */
    mapping(address => mapping(uint256 => uint256)) internal s_unclaimedTokensFromWinner;

    /**
     * @dev Mapping used to track unsuccessful refunds to previous bidders.
     * @dev previousBidderAddress --> amountToRefund
     */
    mapping(address => uint256) internal s_failedRefundsToPreviousBidders;

    /* Events */
    /**
     * @dev Events are declared in YoyoAuctionEvents.sol
     */

    /* Modifiers */
    modifier nftContractSet() {
        if (address(yoyoNftContract) == address(0)) {
            revert YoyoAuction__NftContractNotSet();
        }
        _;
    }

    /* Constructor */
    /**
     * @dev Contract constructor that sets the deployer as the owner
     * @dev Initializes auction counter to 0
     * @dev The NFT contract address must be set separately after deployment
     * @dev The Chainlink Automation registry address must be set in the constructor
     * @param _registry Address of the Chainlink Automation registry
     */
    constructor(address _registry) Ownable(msg.sender) {
        s_auctionCounter = 0;
        i_registry = IAutomationRegistryConsumer(_registry);
    }

    /*Functions */
    /**
     * @notice Sets the address of the NFT collection smart contract to be managed by the auction.
     * @notice This function is designed to be called only once. It can be called only from the owner.
     * @notice Since the two contracts (auction and NFT collection) are deployed together,
     * @dev the NFT collection address cannot be set in the constructor and must be set immediately after deployment.
     * @param _yoyoNftAddress the address of the nft collection smart contract
     */
    function setNftContract(address _yoyoNftAddress) external onlyOwner {
        if (address(yoyoNftContract) != address(0)) {
            revert YoyoAuction__NftContractAlreadySet();
        }
        yoyoNftContract = IYoyoNft(_yoyoNftAddress);
        s_minimumBidChangeAmount =
            (yoyoNftContract.getBasicMintPrice() * MINIMUM_BID_INCREMENT_PERCENTAGE) /
            PERCENTAGE_DENOMINATOR; // 2,5% of the basic mint price
    }

    /**
     * @notice Allows this contract to safely receive ERC721 tokens (NFTs).
     * @dev Implements the ERC721Receiver interface to accept safe transfers and mints.
     * @param operator The address which called `safeTransferFrom` or `mintNft`.
     * @param from The address which previously owned the token.
     * @param tokenId The NFT identifier which is being transferred.
     * @param data Additional data with no specified format.
     * @return selector The selector to confirm the token transfer.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev Receive function that rejects all direct ETH transfers
     * @dev Forces users to use proper auction functions to interact with the contract
     */
    receive() external payable {
        revert YoyoAuction__ThisContractDoesntAcceptDeposit();
    }

    /**
     * @dev Fallback function that rejects all calls to non-existent functions
     * @dev Provides clear error message directing users to use valid functions
     */
    fallback() external payable {
        revert YoyoAuction__CallValidFunctionToInteractWithContract();
    }

    /* Functions */
    /**
     * @notice Called by Chainlink Keepers to check if upkeep is needed.
     * @notice Retrieves the latest auction using s_auctionCounter.
     * @notice Checks if the auction is currently open and if its end time has passed.
     * @notice upkeepNeeded is true only if the auction has ended but is still marked as open.
     * @dev performData encodes the auctionId to be used by performUpkeep for execution.
     * @return upkeepNeeded Boolean indicating whether upkeep should be performed.
     * @return performData Encoded data to be passed to performUpkeep, containing the auctionId.
     */
    function checkUpkeep(
        bytes calldata /*checkData*/
    ) public view override returns (bool upkeepNeeded, bytes memory performData) {
        AuctionStruct memory auction = s_auctionsFromAuctionId[s_auctionCounter];
        bool auctionOpen = auction.state == AuctionState.OPEN;
        bool auctionEnded = block.timestamp >= auction.endTime;
        uint256 auctionId = auction.auctionId;
        uint256 auctionEndTime = auction.endTime;

        upkeepNeeded = (auctionEnded && auctionOpen);
        performData = abi.encode(auctionId, auctionEndTime);
        return (upkeepNeeded, performData);
    }

    /**
     * @notice Executes the Chainlink Keepers upkeep if conditions are met.
     * @notice  checks if the auction has a higher bidder.If there is a new
     * @notice higher bidder, it means a bid has been placed and therefore
     * @notice the auction will be closed at the deadline. If instead there
     * @notice is no higher bidder, the auction will be restarted.
     * @dev Decodes the auctionId and auctionEndTime from performData.
     * @dev Reverts if `checkUpkeep` returns `upkeepNeeded = false`.
     * @dev Only Chainlink Automation or owner can call this function within the grace period.
     * @dev To avoid DOS if Chainlink goes down, after the grace period anyone can call this function.
     * @param performData Encoded data containing the auctionId to process.
     */

    function performUpkeep(bytes calldata performData) external override {
        (uint256 auctionId, uint256 auctionEndTime) = abi.decode(performData, (uint256, uint256));

        bool withinGracePeriod = block.timestamp < (auctionEndTime + GRACE_PERIOD);

        if (withinGracePeriod) {
            // During grace period: only Chainlink Automation can call
            if (msg.sender != address(i_registry)) {
                revert YoyoAuction__OnlyChainlinkAutomationOrOwner();
            }
        } else {
            // After grace period: only Chainlink Automation or owner can call
            if (msg.sender != address(i_registry) && msg.sender != owner()) {
                revert YoyoAuction__OnlyChainlinkAutomationOrOwner();
            }
            emit YoyoAuction__ManualUpkeepExecuted(auctionId, msg.sender, block.timestamp);
        }

        (bool upkeepNeeded, ) = checkUpkeep(performData);
        if (!upkeepNeeded) {
            revert YoyoAuction__UpkeepNotNeeded();
        }

        AuctionStruct memory auction = s_auctionsFromAuctionId[auctionId];

        if (auction.higherBidder != address(0)) {
            _closeAuction(auctionId);
        } else {
            _restartAuction(auctionId);
        }
    }

    /**
     * @notice Opens a new auction for a given NFT token, with a specified auction type.
     * @dev Only the contract owner can call this function.
     * @dev Validates the NFT contract, token ID, and ensures no overlapping auctions.
     * @dev Once the checks are completed, it will call the initialization function specific
     * to the chosen auction type.
     * @dev After the execution of the type-specific function is finished, it will emit the
     * auction opened event.
     * @param _tokenId The ID of the NFT to be auctioned.
     * @param _auctionType The type of auction (ENGLISH or DUTCH).
     */
    function openNewAuction(
        uint256 _tokenId,
        AuctionType _auctionType
    ) public onlyOwner nftContractSet returns (uint256 auctionId) {
        if (yoyoNftContract.getIfTokenIdIsMintable(_tokenId) == false) {
            revert YoyoAuction__InvalidTokenId();
        }

        AuctionStruct memory auction = s_auctionsFromAuctionId[s_auctionCounter];
        if (auction.state == AuctionState.OPEN) {
            revert YoyoAuction__AuctionStillOpen();
        }

        uint256 newAuctionId;
        uint256 endTime;
        unchecked {
            newAuctionId = ++s_auctionCounter;
            endTime = block.timestamp + (AUCTION_DURATION);
        }

        AuctionStruct memory newAuction;

        if (_auctionType == AuctionType.ENGLISH) {
            newAuction = _openNewEnglishAuction(_tokenId, newAuctionId, endTime);
        } else if (_auctionType == AuctionType.DUTCH) {
            newAuction = _openNewDutchAuction(_tokenId, newAuctionId, endTime);
        } 

        s_auctionsFromAuctionId[newAuctionId] = newAuction;

        emit YoyoAuction__AuctionOpened(
            newAuctionId,
            _tokenId,
            newAuction.auctionType,
            newAuction.startPrice,
            newAuction.startTime,
            newAuction.endTime,
            newAuction.minimumBidChangeAmount
        );

        return newAuctionId;
    }

    /**
     * @dev Creates a new English auction structure with appropriate parameters
     * @dev English auctions start at the basic mint price and increase with each bid
     * @param _tokenId ID of the NFT to be auctioned
     * @param _auctionId Unique identifier for this auction
     * @param _endTime Timestamp when the auction will end
     * @return AuctionStruct memory structure containing all auction parameters
     */
    function _openNewEnglishAuction(
        uint256 _tokenId,
        uint256 _auctionId,
        uint256 _endTime
    ) private view returns (AuctionStruct memory) {
        uint256 startPrice = yoyoNftContract.getBasicMintPrice();

        AuctionStruct memory newAuction = AuctionStruct({
            auctionId: _auctionId,
            tokenId: _tokenId,
            nftOwner: address(0),
            state: AuctionState.OPEN,
            auctionType: AuctionType.ENGLISH,
            startPrice: startPrice,
            startTime: block.timestamp,
            endTime: _endTime,
            higherBidder: address(0),
            higherBid: startPrice,
            minimumBidChangeAmount: s_minimumBidChangeAmount
        });

        return newAuction;
    }

    /**
     * @dev Creates a new Dutch auction structure with appropriate parameters
     * @dev Dutch auctions start at a high price (mint price * multiplier) and decrease over time
     * @param _tokenId ID of the NFT to be auctioned
     * @param _auctionId Unique identifier for this auction
     * @param _endTime Timestamp when the auction will end
     * @return AuctionStruct memory structure containing all auction parameters
     */
    function _openNewDutchAuction(
        uint256 _tokenId,
        uint256 _auctionId,
        uint256 _endTime
    ) private view returns (AuctionStruct memory) {
        uint256 startPrice = yoyoNftContract.getBasicMintPrice() * DUTCH_AUCTION_START_PRICE_MULTIPLIER;
        uint256 dropAmount = YoyoDutchAuctionLibrary.dropAmountFromPricesAndIntervalsCalculator(
            yoyoNftContract.getBasicMintPrice(),
            startPrice,
            DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS
        );

        AuctionStruct memory newAuction = AuctionStruct({
            auctionId: _auctionId,
            tokenId: _tokenId,
            nftOwner: address(0),
            state: AuctionState.OPEN,
            auctionType: AuctionType.DUTCH,
            startPrice: startPrice,
            startTime: block.timestamp,
            endTime: _endTime,
            higherBidder: address(0),
            higherBid: startPrice,
            minimumBidChangeAmount: dropAmount
        });

        return newAuction;
    }

    /**
     * @notice Allows users to place bids on active auctions
     * @dev Uses reentrancy guard to prevent reentrancy attacks
     * @dev Validates auction existence and state before processing bid
     * @dev Delegates to specific bid processing functions based on auction type
     * @param _auctionId ID of the auction to bid on
     */
    function placeBidOnAuction(uint256 _auctionId) external payable nonReentrant {
        AuctionStruct memory auction = s_auctionsFromAuctionId[_auctionId];
        if (auction.startTime == 0) {
            revert YoyoAuction__AuctionDoesNotExist();
        }
        if (auction.state != AuctionState.OPEN) {
            revert YoyoAuction__AuctionNotOpen();
        }
        if (auction.auctionType == AuctionType.DUTCH) {
            _placeBidOnDutchAuction(_auctionId);
        } else if (auction.auctionType == AuctionType.ENGLISH) {
            _placeBidOnEnglishAuction(_auctionId);
        }

        // Emit an event for the new bid
        emit YoyoAuction__BidPlaced(_auctionId, msg.sender, msg.value, auction.auctionType);
    }

    /**
     * @notice Processes a bid on a Dutch auction where any bid at or above current price wins immediately
     * @dev In Dutch auctions, any bid at or above current price wins immediately
     * @dev Closes the auction immediately upon successful bid
     * @param _auctionId ID of the Dutch auction
     */
    function _placeBidOnDutchAuction(uint256 _auctionId) private {
        uint256 currentPrice = getCurrentAuctionPrice();

        if (msg.value < currentPrice) {
            revert YoyoAuction__BidTooLow();
        }

        _closeAuction(_auctionId);
    }

    /**
     * @notice Processes a bid on an English auction with minimum increment validation and previous bidder refund
     * @dev Validates that bid meets minimum increment requirements
     * @dev Refunds the previous highest bidder before accepting new bid
     * @param _auctionId ID of the English auction
     */
    function _placeBidOnEnglishAuction(uint256 _auctionId) private {
        AuctionStruct storage auction = s_auctionsFromAuctionId[_auctionId];

        if (msg.value < auction.higherBid + auction.minimumBidChangeAmount) {
            revert YoyoAuction__BidTooLow();
        }

        uint256 previousHigherBid = auction.higherBid;
        address previousHigherBidder = auction.higherBidder;

        // Update the auction with the new bid from the current bidder
        auction.higherBidder = msg.sender;
        auction.higherBid = msg.value;

        //refund previous bidder
        if (previousHigherBidder != address(0)) {
            _refundPreviousBidder(previousHigherBid, previousHigherBidder);
        }
    }

    /**
     * @notice Safely refunds the previous highest bidder when a new higher bid is placed in English auctions
     * @dev Uses low-level call to send ETH and handles failure appropriately
     * @dev If refund fails (e.g., recipient is a contract that rejects ETH):
     *      - Amount is stored in s_failedRefundsToPreviousBidders mapping
     *      - Emits YoyoAuction__BidderRefundFailed event
     *      - Bidder can later claim via claimFailedRefunds()
     * @dev If refund succeeds, emits YoyoAuction__BidderRefunded event
     * @dev Does nothing if _previousBidder is address(0) or _amount is 0
     * @param _amount Amount to refund
     * @param _previousBidder Address to receive the refund
     */
    function _refundPreviousBidder(uint256 _amount, address _previousBidder) private {
        if (_previousBidder != address(0) && _amount > 0) {
            (bool success, ) = _previousBidder.call{ value: _amount }('');
            if (!success) {
                s_failedRefundsToPreviousBidders[_previousBidder] += _amount;
                emit YoyoAuction__BidderRefundFailed(_previousBidder, _amount);
            } else emit YoyoAuction__BidderRefunded(_previousBidder, _amount);
        }
    }

    /**
     * @notice Allows users to claim ETH from failed refund attempts
     * @notice When a refund to a previous bidder fails (e.g., contract recipient),
     *         the amount is stored in a mapping for later manual claim
     * @dev Reverts if caller has no failed refunds to claim
     * @dev Emits YoyoAuction__BidderRefunded event on successful claim
     */
    function claimFailedRefunds() public nonReentrant {
        if (s_failedRefundsToPreviousBidders[msg.sender] == 0) {
            revert YoyoAuction__NoFailedRefundsToClaim();
        }
        uint256 amountToRefund = s_failedRefundsToPreviousBidders[msg.sender];
        s_failedRefundsToPreviousBidders[msg.sender] = 0;
        (bool success, ) = msg.sender.call{ value: amountToRefund }('');
        if (!success) {
            revert YoyoAuction__PreviousBidderRefundFailed();
        }
        emit YoyoAuction__BidderRefunded(msg.sender, amountToRefund);
    }

    /**
     * @notice Closes an auction and attempts to automatically mint the NFT to the winner
     * @notice If minting to the winner fails, mints to this contract and logs the failure
     * @notice if minting to this contract also fails, logs the failure for manual resolution
     * @dev Called automatically by Chainlink Keepers when an auction ends with new bids
     * @dev Changes auction state to CLOSED and attempts NFT minting
     * @dev If minting to the winner succeeds, finalizes the auction; if it fails, logs the error and mint to this contract
     * @dev Force to mint to this contract if minting to winner fails to allow open new auction and avoid confilct with mintPrice if it changes
     * @dev s_unclaimedTokensFromWinner is updated accordingly for manual claiming later
     * @param _auctionId ID of the auction to close
     */
    function _closeAuction(uint256 _auctionId) private {
        AuctionStruct storage auction = s_auctionsFromAuctionId[_auctionId];
        if (auction.state == AuctionState.OPEN) {
            auction.state = AuctionState.CLOSED;
        }
        if (auction.auctionType == AuctionType.DUTCH) {
            auction.endTime = block.timestamp; // Set end time to current time for Dutch auction
            // Update the auction with the new bid
            auction.higherBidder = msg.sender;
            auction.higherBid = msg.value;
        }
        emit YoyoAuction__AuctionClosed(
            auction.auctionId,
            auction.tokenId,
            auction.startPrice,
            auction.startTime,
            auction.endTime,
            auction.higherBidder,
            auction.higherBid
        );

        try yoyoNftContract.mintNft{ value: auction.higherBid }(auction.higherBidder, auction.tokenId) {
            auction.state = AuctionState.FINALIZED;
            auction.nftOwner = auction.higherBidder;
            emit YoyoAuction__AuctionFinalized(auction.auctionId, auction.tokenId, auction.higherBidder);
        } catch Error(string memory reason) {
            _handleFallbackMint(auction, reason);
        } catch (bytes memory) {
            _handleFallbackMint(auction, 'Low-level mint failure');
        }
    }

    /**
     * @notice Handles fallback minting logic when minting to the winner fails.
     * @dev Attempts to mint the NFT to this contract if minting to the winner fails, and emits appropriate events.
     *      If minting to this contract also fails, logs the failure for manual resolution.
     * @param auction The auction struct for which fallback minting is being handled.
     * @param reason The error message or reason for the initial mint failure to the winner.
     */
    function _handleFallbackMint(AuctionStruct storage auction, string memory reason) internal {
        (bool success, string memory fallbackReason) = _tryFallbackMintToThisContract(
            auction.higherBidder,
            auction.tokenId,
            auction.higherBid
        );
        if (success) {
            auction.state = AuctionState.CLOSED;
            auction.nftOwner = address(this);
            emit YoyoAuction__MintToWinnerFailed(auction.auctionId, auction.tokenId, auction.higherBidder, reason);
        } else {
            emit YoyoAuction__MintFailed(auction.auctionId, auction.tokenId, auction.higherBidder, fallbackReason);
        }
    }

    /**
     * @notice Attempts to mint the NFT to this contract as a fallback if minting to the winner fails.
     * @dev If minting to this contract succeeds, updates the unclaimed tokens mapping for the winner.
     *      If it fails, stores the mint price for manual claim and returns the failure reason.
     * @param _finalClaimer The address of the original auction winner entitled to claim the NFT.
     * @param _tokenId The ID of the NFT to mint.
     * @param _mintPrice The price to pay for minting the NFT.
     * @return success True if minting to this contract succeeded, false otherwise.
     * @return reason The error message or reason for the mint failure, if any.
     */
    function _tryFallbackMintToThisContract(
        address _finalClaimer,
        uint256 _tokenId,
        uint256 _mintPrice
    ) internal returns (bool, string memory) {
        try yoyoNftContract.mintNft{ value: _mintPrice }(address(this), _tokenId) {
            s_unclaimedTokensFromWinner[_finalClaimer][_tokenId] = type(uint256).max;
            return (true, '');
        } catch Error(string memory reason) {
            s_unclaimedTokensFromWinner[_finalClaimer][_tokenId] = _mintPrice;
            return (false, reason);
        } catch {
            s_unclaimedTokensFromWinner[_finalClaimer][_tokenId] = _mintPrice;
            return (false, 'Low-level mint failure');
        }
    }

    /**
     * @notice Automatically restarts an auction that ended without receiving any bids
     * @dev Resets auction timing and pricing parameters for a new auction cycle
     * @dev Called automatically by Chainlink Keepers when an auction ends without bids
     * @param _auctionId ID of the auction to restart
     */
    function _restartAuction(uint256 _auctionId) private {
        AuctionStruct storage auction = s_auctionsFromAuctionId[_auctionId];

        uint256 startPrice;
        if (auction.auctionType == AuctionType.ENGLISH) {
            startPrice = yoyoNftContract.getBasicMintPrice();
        } else if (auction.auctionType == AuctionType.DUTCH) {
            startPrice = YoyoDutchAuctionLibrary.startPriceFromReserveAndMultiplierCalculator(
                yoyoNftContract.getBasicMintPrice(),
                DUTCH_AUCTION_START_PRICE_MULTIPLIER,
                1 // Using 1 interval for restart
            );
        }
        uint256 endTime = block.timestamp + (AUCTION_DURATION);

        auction.startTime = block.timestamp;
        auction.endTime = endTime;
        auction.startPrice = startPrice;
        auction.higherBid = startPrice;
        auction.minimumBidChangeAmount = s_minimumBidChangeAmount;

        emit YoyoAuction__AuctionRestarted(
            auction.auctionId,
            auction.tokenId,
            auction.startTime,
            auction.startPrice,
            auction.endTime,
            auction.minimumBidChangeAmount
        );
    }

    /**
     * @notice Allows the auction winner to manually claim their NFT if automatic minting or transfer failed.
     * @dev Used as a fallback when the automatic minting in _closeAuction() and claimNftForWinner() fails
     * @dev If the NFT was already minted to the contract, it will be transferred. If not, the contract will mint it and transfer.
     * @param _auctionId The ID of the auction for which the winner is claiming the NFT.
     */
    function claimNftForWinner(uint256 _auctionId) public nonReentrant {
        bool eligible = getElegibilityForClaimingNft(_auctionId, msg.sender);

        if (eligible) {
            uint256 tokenId = s_auctionsFromAuctionId[_auctionId].tokenId;

            if (s_unclaimedTokensFromWinner[msg.sender][tokenId] == type(uint256).max) {
                _claimNftForWinner(_auctionId);
            } else {
                _mintNftForWinner(_auctionId);
            }
        } else {
            revert YoyoAuction__NoTokenToClaim();
        }
    }

    /**
     * @notice Internal function to transfer an already minted NFT from the contract to the winner.
     * @dev Used when the NFT was minted to the contract due to a failed mint to the winner.
     * @param _auctionId The ID of the auction for which the NFT is being claimed.
     */
    function _claimNftForWinner(uint256 _auctionId) internal {
        AuctionStruct storage auction = s_auctionsFromAuctionId[_auctionId];

        if (auction.nftOwner != address(this)) {
            revert YoyoAuction__NftNotHeldByContract();
        }

        auction.state = AuctionState.FINALIZED;
        auction.nftOwner = auction.higherBidder;
        delete s_unclaimedTokensFromWinner[auction.higherBidder][auction.tokenId];

        yoyoNftContract.transferNft(msg.sender, auction.tokenId);

        emit YoyoAuction__AuctionFinalized(auction.auctionId, auction.tokenId, auction.higherBidder);
    }

    /**
     * @notice Internal function to mint the NFT for the winner if it was not minted during auction close.
     * @dev Used as a fallback when both automatic and manual transfer failed and the NFT is not yet minted.
     * @param _auctionId The ID of the auction for which the NFT is being minted and claimed.
     */
    function _mintNftForWinner(uint256 _auctionId) internal {
        AuctionStruct storage auction = s_auctionsFromAuctionId[_auctionId];

        if (auction.nftOwner != address(0)) {
            revert YoyoAuction__NftAlreadyMinted();
        }

        uint256 paidAmount = s_unclaimedTokensFromWinner[auction.higherBidder][auction.tokenId];
        delete s_unclaimedTokensFromWinner[auction.higherBidder][auction.tokenId];

        auction.state = AuctionState.FINALIZED;
        auction.nftOwner = auction.higherBidder;

        yoyoNftContract.mintNft{ value: paidAmount }(auction.higherBidder, auction.tokenId);

        emit YoyoAuction__AuctionFinalized(auction.auctionId, auction.tokenId, auction.higherBidder);
    }

    /**
     * @notice Allows the owner to change the basic mint price for future auctions
     * @dev Validates that the new price doesn't conflict with ongoing auctions
     * @dev Updates the minimum bid change amount proportionally (2.5% of new price)
     * @dev Cannot be called if current auction has bids below the new price
     * @dev The logic is designed to prevent the winner's final bid from being lower than
     *      the basic mint price, which would make minting impossible
     * @param _newPrice New basic mint price in wei
     */
    function changeMintPrice(uint256 _newPrice) public onlyOwner nftContractSet {
        if (_newPrice <= MINIMUM_POSSIBLE_MINT_PRICE) {
            revert YoyoAuction__InvalidValue();
        }
        AuctionStruct memory currentAuction = s_auctionsFromAuctionId[s_auctionCounter];
        if (currentAuction.state == AuctionState.OPEN || currentAuction.state == AuctionState.CLOSED) {
            revert YoyoAuction__CannotChangeMintPriceDuringOpenAuction();
        }
        yoyoNftContract.setBasicMintPrice(_newPrice);
        s_minimumBidChangeAmount = (_newPrice * MINIMUM_BID_INCREMENT_PERCENTAGE) / PERCENTAGE_DENOMINATOR; // 2,5% of the basic mint price
    }

    //Getter Functions

    /**
     * @notice Returns the address of the NFT contract managed by this auction
     * @dev This address must be set before auctions can be created.
     * @dev Used throughout the contract to call NFT-specific functions through the IYoyoNft interface.
     * @return address Address of the NFT collection contract
     */
    function getNftContract() external view returns (address) {
        return address(yoyoNftContract);
    }

    /**
     * @notice Returns the total number of auctions created so far
     * @dev This value also represents the ID of the latest auction.
     * @dev Used as a reference key for `s_auctionsFromAuctionId` mapping and in functions like `getCurrentAuction` and `changeMintPrice`.
     * @return uint256 Current auction counter
     */
    function getAuctionCounter() external view returns (uint256) {
        return s_auctionCounter;
    }

    function getAuctionDuration() external pure returns (uint256) {
        return AUCTION_DURATION;
    }

    /**
     * @notice Returns the minimum amount required to outbid the current highest bid
     * @dev For English auctions, this is set to 2.5% of the basic mint price.
     * @dev Used in `placeBidOnEnglishAuction` to validate bid increments and in auction initialization.
     * @return uint256 Minimum bid increment in wei
     */
    function getMinimumBidChangeAmount() external view returns (uint256) {
        return s_minimumBidChangeAmount;
    }

    function getMinimumBidChangePercentage() external pure returns (uint256) {
        return MINIMUM_BID_INCREMENT_PERCENTAGE;
    }

    /**
     * @notice Returns the multiplier used to calculate Dutch auction starting price
     * @dev Starting price = basic mint price * multiplier.
     * @dev Used in `openNewDutchAuction` and `restartAuction` to determine starting price for Dutch auctions.
     * @return uint256 Dutch auction start price multiplier
     */
    function getDutchAuctionStartPriceMultiplier() external pure returns (uint256) {
        return DUTCH_AUCTION_START_PRICE_MULTIPLIER;
    }

    function getPercentageDenominator() external pure returns (uint256) {
        return PERCENTAGE_DENOMINATOR;
    }

    function getMinimumPossibleMintPrice() external pure returns (uint256) {
        return MINIMUM_POSSIBLE_MINT_PRICE;
    }

    function getDutchAuctionNumberOfIntervals() external pure returns (uint256) {
        return DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS;
    }

    function getGracePeriod() external pure returns (uint256) {
        return GRACE_PERIOD;
    }

    /**
     * @notice Returns all information about a specific auction by its ID
     * @dev Includes pricing, timing, current bids, and auction state.
     * @dev Used in multiple parts of the contract for bid validation, auction status checks, and Chainlink upkeep logic.
     * @param _auctionId ID of the auction to retrieve
     * @return AuctionStruct Full auction data structure
     */
    function getAuctionFromAuctionId(uint256 _auctionId) public view returns (AuctionStruct memory) {
        return s_auctionsFromAuctionId[_auctionId];
    }

    /**
     * @notice Returns the latest auction created
     * @dev Fetches auction data using the current auction counter.
     * @dev Used in functions like `getCurrentAuctionPrice` and `changeMintPrice` to operate on the most recent auction.
     * @return AuctionStruct Full data of the latest auction
     */
    function getCurrentAuction() public view returns (AuctionStruct memory) {
        return s_auctionsFromAuctionId[s_auctionCounter];
    }

    /**
     * @notice Returns the current price of the ongoing auction
     * @dev For English auctions: highest bid + minimum increment.
     * @dev For Dutch auctions: calculated based on elapsed time and price drop intervals.
     * @dev Used in `placeBidOnDutchAuction` to validate the bid amount and ensure the winner pays the current fair price.
     * @dev Reverts if no auction is currently open.
     * @return uint256 Current auction price in wei
     */
    function getCurrentAuctionPrice() public view returns (uint256) {
        AuctionStruct memory auction = s_auctionsFromAuctionId[s_auctionCounter];
        uint256 currentPrice;
        if (auction.state != AuctionState.OPEN) {
            revert YoyoAuction__AuctionNotOpen();
        }
        if (auction.auctionType == AuctionType.ENGLISH) {
            currentPrice = auction.higherBid + auction.minimumBidChangeAmount;
        }
        if (auction.auctionType == AuctionType.DUTCH) {
            uint256 dropAmount = YoyoDutchAuctionLibrary.dropAmountFromPricesAndIntervalsCalculator(
                yoyoNftContract.getBasicMintPrice(),
                auction.startPrice,
                DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS
            );
            currentPrice = YoyoDutchAuctionLibrary.currentPriceFromTimeRangeCalculator(
                auction.startPrice,
                yoyoNftContract.getBasicMintPrice(),
                dropAmount,
                auction.startTime,
                auction.endTime,
                DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS
            );
        }
        return currentPrice;
    }

    /**
     * @notice Returns the amount of failed refunds for a specific bidder
     * @dev Used to track and allow bidders to claim any failed refunds
     * @param _bidder Address of the bidder to check
     * @return uint256 Amount of failed refunds in wei
     */
    function getFailedRefundAmount(address _bidder) public view returns (uint256) {
        return s_failedRefundsToPreviousBidders[_bidder];
    }

    /**
     * @notice Checks if the caller is eligible to claim an NFT for a specific auction.
     * @dev Returns true if the caller has an unclaimed NFT for the given auction.
     * @param _auctionId The ID of the auction to check eligibility for.
     * @param _claimer The address of the potential claimer.
     * @return eligible True if the caller can claim the NFT, false otherwise.
     */
    function getElegibilityForClaimingNft(uint256 _auctionId, address _claimer) public view returns (bool eligible) {
        uint256 tokenId = s_auctionsFromAuctionId[_auctionId].tokenId;
        eligible = s_unclaimedTokensFromWinner[_claimer][tokenId] != 0;
    }
}
