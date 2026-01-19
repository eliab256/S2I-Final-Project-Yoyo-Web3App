// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AuctionStruct, AuctionState, AuctionType } from '../YoyoTypes.sol';
import { IERC721Receiver } from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import { AutomationCompatibleInterface } from '@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol';

/**
 * @title IYoyoAuction
 * @author Elia Bordoni
 * @notice Interface for the YoyoAuction NFT auction contract
 * @dev Defines all external and public functions for interacting with the auction system
 */
interface IYoyoAuction is AutomationCompatibleInterface, IERC721Receiver {
    /* ========== SETUP FUNCTIONS ========== */

    /**
     * @notice Sets the address of the NFT collection smart contract to be managed by the auction
     * @dev Can only be called once by the owner after deployment
     * @param _yoyoNftAddress The address of the NFT collection smart contract
     */
    function setNftContract(address _yoyoNftAddress) external;

    /**
     * @notice Checks if upkeep is needed for Chainlink Automation
     * @dev Called by Chainlink Keepers to determine if performUpkeep should be executed
     * @param checkData Encoded data for the upkeep check (not used in this implementation)
     * @return upkeepNeeded Boolean indicating if upkeep is needed
     * @return performData Encoded data to be passed to performUpkeep
     */
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);

    /**
     * @notice Executes the Chainlink Keepers upkeep if conditions are met
     * @dev Closes or restarts auctions based on their state
     * @param performData Encoded data containing the auctionId to process
     */
    function performUpkeep(bytes calldata performData) external;

    /* ========== AUCTION MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Opens a new auction for a given NFT token
     * @dev Only callable by the owner
     * @param _tokenId The ID of the NFT to be auctioned
     * @param _auctionType The type of auction (ENGLISH or DUTCH)
     */
    function openNewAuction(uint256 _tokenId, AuctionType _auctionType) external returns (uint256);

    /**
     * @notice Allows users to place bids on active auctions
     * @dev Validates auction existence and state before processing bid
     * @param _auctionId ID of the auction to bid on
     */
    function placeBidOnAuction(uint256 _auctionId) external payable;

    /**
     * @notice Allows users to claim ETH from failed refund attempts
     * @dev Reverts if caller has no failed refunds to claim
     */
    function claimFailedRefunds() external;

    /**
     * @notice Manual function to claim NFT for auction winner when automatic mint fails
     * @dev Validates that the caller is the auction winner and auction is closed
     * @param _auctionId ID of the auction to manually finalize
     */
    function claimNftForWinner(uint256 _auctionId) external;

    /**
     * @notice Allows the owner to change the basic mint price for future auctions
     * @dev Cannot be called during an open or closed auction
     * @param _newPrice New basic mint price in wei
     */
    function changeMintPrice(uint256 _newPrice) external;

    /* ========== GETTER FUNCTIONS ========== */

    /**
     * @notice Returns the address of the NFT contract managed by this auction
     * @return address Address of the NFT collection contract
     */
    function getNftContract() external view returns (address);

    /**
     * @notice Returns the total number of auctions created so far
     * @return uint256 Current auction counter
     */
    function getAuctionCounter() external view returns (uint256);

    /**
     * @notice Returns the duration of each auction in hours
     * @return uint256 Auction duration in hours
     */
    function getAuctionDuration() external pure returns (uint256);

    /**
     * @notice Returns the minimum amount required to outbid the current highest bid
     * @return uint256 Minimum bid increment in wei
     */
    function getMinimumBidChangeAmount() external view returns (uint256);

    /**
     * @notice Returns the percentage used to calculate the minimum bid increment
     * @dev Returns MINIMUM_BID_INCREMENT_PERCENTAGE constant (25 per-mille = 2.5%)
     * @dev This percentage is applied to the basic mint price to determine s_minimumBidChangeAmount
     * @return uint256 Minimum bid increment percentage in per-mille (25 = 2.5%)
     */
    function getMinimumBidChangePercentage() external pure returns (uint256);

    /**
     * @notice Returns the multiplier used to calculate Dutch auction starting price
     * @dev Starting price = basic mint price * multiplier.
     * @dev Used in `openNewDutchAuction` and `restartAuction` to determine starting price for Dutch auctions.
     * @return uint256 Dutch auction start price multiplier
     */
    function getDutchAuctionStartPriceMultiplier() external pure returns (uint256);

    /**
     * @notice Returns the denominator used for percentage calculations
     * @dev Returns PERCENTAGE_DENOMINATOR constant (1000 = 100%)
     * @dev Using 1000 instead of 100 provides better precision for decimal percentages
     * @dev Used to calculate minimum bid increments and other percentage-based values
     * @return uint256 Percentage denominator (1000)
     */
    function getPercentageDenominator() external pure returns (uint256);

    /**
     * @notice Returns the minimum allowed mint price for NFTs
     * @dev Returns MINIMUM_POSSIBLE_MINT_PRICE constant
     * @dev Calculated as PERCENTAGE_DENOMINATOR / MINIMUM_BID_INCREMENT_PERCENTAGE
     * @dev Ensures mint price is large enough to avoid rounding issues in percentage calculations
     * @return uint256 Minimum possible mint price in wei (40 wei with current constants)
     */
    function getMinimumPossibleMintPrice() external pure returns (uint256);

    /**
     * @notice Returns the number of price drop intervals in Dutch auctions
     * @dev Returns DUTCH_AUCTION_DROP_NUMBER_OF_INTERVALS constant (48)
     * @dev Price drops occur at regular intervals throughout the auction duration
     * @dev With 24-hour auctions, this means a price drop every 30 minutes (24h / 48 = 0.5h)
     * @return uint256 Number of price drop intervals (48)
     */
    function getDutchAuctionNumberOfIntervals() external pure returns (uint256);

    /**
     * @notice Returns the grace period duration for manual auction closure
     * @dev Returns GRACE_PERIOD constant (6 hours = 21600 seconds)
     * @dev After auction end time + grace period, any user can manually close/restart auctions
     * @dev Provides resilience against Chainlink Automation downtime or failures
     * @return uint256 Grace period duration in seconds (21600)
     */
    function getGracePeriod() external pure returns (uint256);

    /**
     * @notice Returns all information about a specific auction by its ID
     * @param _auctionId ID of the auction to retrieve
     * @return AuctionStruct Full auction data structure
     */
    function getAuctionFromAuctionId(uint256 _auctionId) external view returns (AuctionStruct memory);

    /**
     * @notice Returns the latest auction created
     * @return AuctionStruct Full data of the latest auction
     */
    function getCurrentAuction() external view returns (AuctionStruct memory);

    /**
     * @notice Returns the current price of the ongoing auction
     * @dev For English auctions: highest bid + minimum increment
     * @dev For Dutch auctions: calculated based on elapsed time
     * @return uint256 Current auction price in wei
     */
    function getCurrentAuctionPrice() external view returns (uint256);

    /**
     * @notice Returns the amount of failed refunds for a specific bidder
     * @param _bidder Address of the bidder to check
     * @return uint256 Amount of failed refunds in wei
     */
    function getFailedRefundAmount(address _bidder) external view returns (uint256);

    /**
     * @notice Returns the upkeep ID associated with this contract
     * @dev Used by Chainlink Automation to identify this contract's upkeep registration
     * @return uint256 The upkeep ID
     */
    function getUpkeepId() external view returns (uint256);

    /**
     * @notice Returns the address of the Chainlink Forwarder
     * @dev The Chainlink Forwarder is the authorized Automation contract for upkeeps
     * @return address The Chainlink Forwarder address
     */
    function getChainlinkForwarderAddress() external view returns (address);

    /**
     * @notice Checks if a claimer is eligible to claim their unminted NFT for a specific auction
     * @dev Returns true if the claimer has an unclaimed NFT for the given auction
     * @param _auctionId The ID of the auction to check eligibility for
     * @param _claimer The address of the potential claimer
     * @return bool True if the claimer can claim the NFT, false otherwise
     */
    function getElegibilityForClaimingNft(uint256 _auctionId, address _claimer) external view returns (bool);
}
