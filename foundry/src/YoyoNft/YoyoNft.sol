// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import { ConstructorParams } from '../YoyoTypes.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import '../YoyoNft/YoyoNftErrors.sol';
import '../YoyoNft/YoyoNftEvents.sol';

/**
 * @title A Yoga NFT collection
 * @author Elia Bordoni
 * @notice This contract manages a limited collection of yoga-themed NFTs with auction integration
 * @dev Extends ERC721 with custom minting logic, auction contract integration, and owner-only functions
 * @dev The contract communicates with the YoyoAuction via a custom interface that only implements
 */

contract YoyoNft is ERC721, Ownable {
    /* Errors */
    /**
     * @dev Errors are declared in YoyoNftErrors.sol
     */

    /* Variables */

    /**
     * @notice Maximum number of NFTs that can be minted in this collection
     * @dev Hard cap set to 20 NFTs to maintain collection exclusivity
     */
    uint256 public constant MAX_NFT_SUPPLY = 20;

    /**
     * @notice Address of the auction contract authorized to mint NFTs
     * @dev Immutable address set during contract deployment
     * @dev Only this contract can call onlyAuction protected functions
     */
    address private immutable i_auctionContract;

    /**
     * @notice Tracks the total number of NFTs minted so far
     * @dev Incremented after each successful mint to prevent exceeding MAX_NFT_SUPPLY
     */
    uint256 private s_tokenCounter;

    /**
     * @notice Minimum price required to mint an NFT, denominated in wei
     * @dev Can only be updated by the auction contract via setBasicMintPrice
     * @dev Set during contract deployment and adjustable to match auction dynamics
     */
    uint256 private s_basicMintPrice;

    /**
     * @notice Base URI for token metadata
     * @dev Used to construct complete token URIs in the format: baseURI/tokenId.json
     * @dev Set during contract deployment and cannot be changed afterward
     */
    string private s_baseURI;

    /* Events */
    /**
     * @dev Events are declared in YoyoNftEvents.sol
     */

    /* Modifiers */

    /**
     * @notice Restricts function access to the auction contract only
     * @dev Reverts with YoyoNft__NotAuctionContract if caller is not the auction contract
     */
    modifier onlyAuction() {
        if (msg.sender != i_auctionContract) {
            revert YoyoNft__NotAuctionContract();
        }
        _;
    }

    /**
     * @notice The ERC721 token is inizialized with the name "Yoyo Collection" and with the symbol "YOYO"
     * @dev The owner of the contract is set to be the sender of the deployment transaction
     */
    constructor(ConstructorParams memory _params) ERC721('Yoyo Collection', 'YOYO') Ownable(msg.sender) {
        if (bytes(_params.baseURI).length == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        if (_params.auctionContract == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        s_baseURI = _params.baseURI;
        s_tokenCounter = 0;
        i_auctionContract = _params.auctionContract;
        s_basicMintPrice = _params.basicMintPrice;
    }

    /* Functions */
    /**
     * @notice Rejects all direct ETH transfers to the contract
     * @dev Both receive and fallback functions refuse to accept eth and force users
     * @dev to use correct functions
     */
    receive() external payable {
        revert YoyoNft__ThisContractDoesntAcceptDeposit();
    }

    /**
     * @notice Rejects all calls to non-existent functions
     * @dev Provides clear error message directing users to use valid functions
     */
    fallback() external payable {
        revert YoyoNft__CallValidFunctionToInteractWithContract();
    }

    /**
     * @notice Allows only the owner of the contract to withdraw funds from contract
     * @dev Transfers entire contract balance to the owner
     * @dev Emits YoyoNft__WithdrawCompleted event on success
     * @dev Reverts with YoyoNft__ContractBalanceIsZero if balance is zero
     * @dev Reverts with YoyoNft__WithdrawFailed if transfer fails
     */
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        if (contractBalance == 0) {
            revert YoyoNft__ContractBalanceIsZero();
        }
        (bool success, ) = payable(owner()).call{ value: contractBalance }('');
        if (success) {
            emit YoyoNft__WithdrawCompleted(contractBalance, block.timestamp);
        } else {
            revert YoyoNft__WithdrawFailed();
        }
    }

    /**
     * @notice Allows only the owner of the contract to deposit funds
     * @dev Emits YoyoNft__DepositCompleted event with amount and timestamp
     * @dev Reverts with YoyoNft__ValueCantBeZero if msg.value is zero
     */
    function deposit() public payable onlyOwner {
        if (msg.value == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        emit YoyoNft__DepositCompleted(msg.value, block.timestamp);
    }

    /**
     * @notice Allows the auction contract to set the base minting price
     * @dev This is because the logic of the auction contract must prevent the winner's
     * @dev auction price from being in any way lower than the mint price, which would
     * @dev result in the minting process failing
     * @dev Emits YoyoNft__MintPriceUpdated event
     * @dev Reverts with YoyoNft__ValueCantBeZero if new price is zero
     * @param _newBasicPrice The new minting price in wei
     */
    function setBasicMintPrice(uint256 _newBasicPrice) public onlyAuction {
        if (_newBasicPrice == 0) {
            revert YoyoNft__ValueCantBeZero();
        }
        s_basicMintPrice = _newBasicPrice;

        emit YoyoNft__MintPriceUpdated(_newBasicPrice, block.timestamp);
    }

    /**
     * @notice Allows the auction contract to mint a new NFT to send to the auction winner
     * @dev Implementation of the safeMint function from ERC721 standard
     * @dev Creates the event with all the information for the frontend like tokenURI and tokenId
     * @dev Updates tokenCounter to avoid max supply exceed
     * @dev Emits YoyoNft__NftMinted event with recipient, tokenId, tokenURI and timestamp
     * @dev Reverts with YoyoNft__NftMaxSupplyReached if max supply is reached
     * @dev Reverts with YoyoNft__NftAlreadyMinted if token is already minted
     * @dev Reverts with YoyoNft__TokenIdDoesNotExist if tokenId >= MAX_NFT_SUPPLY
     * @dev Reverts with YoyoNft__NotEnoughEtherSent if msg.value < basicMintPrice
     * @dev Reverts with YoyoNft__InvalidAddress if recipient is address(0)
     * @param _to The recipient to whom the NFT will be sent immediately after it is minted
     * @param _tokenId The unique ID of the token to be minted
     */
    function mintNft(address _to, uint256 _tokenId) public payable onlyAuction {
        if (s_tokenCounter == MAX_NFT_SUPPLY) {
            revert YoyoNft__NftMaxSupplyReached();
        }
        if (_ownerOf(_tokenId) != address(0)) {
            revert YoyoNft__NftAlreadyMinted();
        }
        if (_tokenId >= MAX_NFT_SUPPLY) {
            revert YoyoNft__TokenIdDoesNotExist();
        }
        if (msg.value < s_basicMintPrice) {
            revert YoyoNft__NotEnoughEtherSent();
        }
        if (_to == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        _safeMint(_to, _tokenId);
        string memory tokenURIComplete = tokenURI(_tokenId);
        s_tokenCounter++;

        emit YoyoNft__NftMinted(_to, _tokenId, tokenURIComplete, block.timestamp);
    }

    /**
     * @notice Allows NFT owner to transfer their NFT to another user
     * @dev Implementation of the safeTransfer function from ERC721 standard
     * @dev Reverts with YoyoNft__InvalidAddress if recipient is address(0)
     * @dev Reverts with YoyoNft__NotNftOwner if caller is not the owner of the token
     * @param _to The recipient to whom the NFT will be sent
     * @param _tokenId The unique ID of the token to send
     */
    function transferNft(address _to, uint256 _tokenId) public {
        if (_to == address(0)) {
            revert YoyoNft__InvalidAddress();
        }
        if (ownerOf(_tokenId) != msg.sender) {
            revert YoyoNft__NotNftOwner();
        }
        _safeTransfer(msg.sender, _to, _tokenId);
    }

    /**
     * @notice Returns the complete URI of a specific token from its ID
     * @dev Reverts with YoyoNft__TokenIdDoesNotExist if tokenId >= MAX_NFT_SUPPLY
     * @dev Reverts with YoyoNft__NftNotMinted if token has not been minted yet
     * @param _tokenId The unique ID of the token
     * @return string The complete unique URI related to the specific token
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (_tokenId >= MAX_NFT_SUPPLY) {
            revert YoyoNft__TokenIdDoesNotExist();
        }
        if (_ownerOf(_tokenId) == address(0)) {
            revert YoyoNft__NftNotMinted();
        }
        return string(abi.encodePacked(s_baseURI, '/', Strings.toString(_tokenId), '.json'));
    }

    /**
     * @notice Returns the base URI for token metadata
     * @return string The base URI string
     */
    function getBaseURI() public view returns (string memory) {
        return s_baseURI;
    }

    /**
     * @notice Returns the total number of NFTs minted so far
     * @return uint256 The current token counter value
     */
    function getTotalMinted() public view returns (uint256) {
        return s_tokenCounter;
    }

    /**
     * @notice Returns the owner of a specific token ID
     * @dev Wrapper around ERC721's ownerOf function
     * @param tokenId The unique ID of the token
     * @return address The address of the token owner
     */
    function getOwnerFromTokenId(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    /**
     * @notice Returns the number of NFTs owned by a specific account
     * @dev Wrapper around ERC721's balanceOf function
     * @param _account The address to query
     * @return uint256 The number of NFTs owned by the account
     */
    function getAccountBalance(address _account) public view returns (uint256) {
        return balanceOf(_account);
    }

    /**
     * @notice Returns the address of the auction contract
     * @return address The immutable auction contract address
     */
    function getAuctionContract() public view returns (address) {
        return i_auctionContract;
    }

    /**
     * @notice Returns the current basic mint price for NFTs
     * @return uint256 The basic mint price in wei
     */
    function getBasicMintPrice() public view returns (uint256) {
        return s_basicMintPrice;
    }

    /**
     * @notice Checks whether a specific token ID can be minted or not
     * @dev Verifies both whether it has already been minted and whether the ID is within the maximum supply
     * @param _tokenId The unique ID of the token to check
     * @return bool True if the token is mintable, false otherwise
     */
    function getIfTokenIdIsMintable(uint256 _tokenId) public view returns (bool) {
        return _ownerOf(_tokenId) == address(0) && _tokenId < MAX_NFT_SUPPLY;
    }
}
