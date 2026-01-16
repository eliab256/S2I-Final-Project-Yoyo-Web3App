// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AuctionType } from '../YoyoTypes.sol';

event YoyoAuction__BidPlaced(
    uint256 indexed auctionId,
    address indexed bidder,
    uint256 bidAmount,
    AuctionType auctionType
);
event YoyoAuction__BidderRefunded(address indexed prevBidderAddress, uint256 bidAmount);
event YoyoAuction__BidderRefundFailed(address indexed prevBidderAddress, uint256 bidAmount);
event YoyoAuction__AuctionOpened(
    uint256 indexed auctionId,
    uint256 indexed tokenId,
    AuctionType auctionType,
    uint256 startPrice,
    uint256 startTime,
    uint256 endTime,
    uint256 minimumBidIncrement
);
event YoyoAuction__AuctionRestarted(
    uint256 indexed auctionId,
    uint256 indexed tokenId,
    uint256 newStartTime,
    uint256 newStartPrice,
    uint256 newEndTime,
    uint256 minimumBidIncrement
);
event YoyoAuction__AuctionClosed(
    uint256 indexed auctionId,
    uint256 indexed tokenId,
    uint256 startPrice,
    uint256 startTime,
    uint256 endTime,
    address winner,
    uint256 indexed higherBid
);
event YoyoAuction__AuctionFinalized(uint256 indexed auctionId, uint256 indexed tokenId, address indexed nftOwner);
event YoyoAuction__MintFailed(uint256 indexed auctionId, uint256 indexed tokenId, address indexed bidder, string reason);
event YoyoAuction__ManualUpkeepExecuted(uint256 indexed auctionId, address indexed executor, uint256 timestamp);
