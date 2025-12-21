// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**  Type declarations
 * @notice Parameters structure for contract initialization
 * @dev Used to avoid stack too deep errors in constructor
 * @param s_baseURI the base URI for Yoyo NFTs' metadata stored in IPFS, the format of the string should be ipfs://<CID>
 * @param i_auctionContract the address of auction contract that allows to mint new nfts
 * @param s_basicMintPrice It is the initial mint price, also used as the auction starting bid in the YoyoAuction contract.
 */
struct ConstructorParams {
    string baseURI;
    address auctionContract;
    uint256 basicMintPrice;
}

/**
 * @dev notStarted: prevents the default value from being set to `open`.
 * @dev open: auction is active and bids can be placed.
 * @dev closed: auction has ended, no more bids can be placed, but the winner has not yet received the reward.
 * @dev finalized: after the auction is closed and the NFT is minted and delivered to the winner, the auction is considered finalized.
 */
enum AuctionState {
    NOT_STARTED,
    OPEN,
    CLOSED,
    FINALIZED
}

/**
 * @dev English: traditional auction where bidders place increasingly higher bids.
 * @dev Dutch: auction starts at a high price that decreases over time until a bidder accepts the current price.
 */
enum AuctionType {
    ENGLISH,
    DUTCH
}

/**
 * @dev Core data structure that holds all information about a single auction
 * @param auctionId Unique identifier for the auction
 * @param tokenId ID of the NFT being auctioned
 * @param nftOwner Address that will receive the NFT (set after finalization)
 * @param state Current state of the auction (NOT_STARTED, OPEN, CLOSED, FINALIZED)
 * @param auctionType Type of auction (ENGLISH or DUTCH)
 * @param startPrice Initial price when the auction begins
 * @param startTime Timestamp when the auction started
 * @param endTime Timestamp when the auction is scheduled to end
 * @param higherBidder Address of the current highest bidder
 * @param higherBid Amount of the current highest bid
 * @param minimumBidChangeAmount Minimum increment required for new bids (English) or drop amount (Dutch)
 */
struct AuctionStruct {
    uint256 auctionId;
    uint256 tokenId;
    address nftOwner;
    AuctionState state;
    AuctionType auctionType;
    uint256 startPrice;
    uint256 startTime;
    uint256 endTime;
    address higherBidder;
    uint256 higherBid;
    uint256 minimumBidChangeAmount;
}
