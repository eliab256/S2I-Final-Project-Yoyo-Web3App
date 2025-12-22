// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AuctionStruct, AuctionState, AuctionType } from '../YoyoTypes.sol';

/**
 * @title IYoyoAuction
 * @author Elia Bordoni
 * @notice Interface for the YoyoAuction NFT auction contract
 * @dev Defines all external and public functions for interacting with the auction system
 */
interface IYoyoAuction {
    /* ========== SETUP FUNCTIONS ========== */

    /**
     * @notice Sets the address of the NFT collection smart contract to be managed by the auction
     * @dev Can only be called once by the owner after deployment
     * @param _yoyoNftAddress The address of the NFT collection smart contract
     */
    function setNftContract(address _yoyoNftAddress) external;

    /* ========== CHAINLINK AUTOMATION FUNCTIONS ========== */

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
    function openNewAuction(uint256 _tokenId, AuctionType _auctionType) external;

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
     * @notice Manual function to mint NFT for auction winner when mint after auction close fails
     * @dev Only callable by owner as a fallback mechanism
     * @param _auctionId ID of the auction to manually finalize
     */
    function mintNftForWinner(uint256 _auctionId) external;

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
     * @notice Returns the multiplier used to calculate Dutch auction starting price
     * @return uint256 Dutch auction start price multiplier
     */
    function getDutchAuctionStartPriceMultiplier() external pure returns (uint256);

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
     * @notice Checks if a winner is eligible to claim their unminted NFT
     * @param _tokenId ID of the NFT token to check eligibility for
     * @return bool True if the caller is eligible to claim the token
     */
    function getElegibiltyToClaimToken(uint256 _tokenId) external view returns (bool);
}
