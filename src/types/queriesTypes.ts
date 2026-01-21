import type { Address, Hash } from 'viem';
import type { AuctionType } from './contractsTypes';

// Ownership of an NFT queries types
export interface OwnedNFT {
    tokenId: string;
    mintedAt: string;
    mintTxHash: Hash;
}

export interface TransferEvent {
    from: Address;
    to: Address;
    tokenId: string;
    txHash: Hash;
    blockNumber: string;
    blockTimestamp: string;
}

export interface TransfersResponse {
    allTransfers: {
        nodes: TransferEvent[];
    };
}

// Bid history queries types
export interface BidPlaced {
    auctionId: string;
    bidder: Address;
    bidAmount: string;
    blockTimestamp: string;
    blockNumber: string;
    txHash: Hash;
}

export interface PlaceBidEvent {
    auctionId: string;
    bidder: Address;
    bidAmount: string;
    auctionType: AuctionType;
    txHash: Hash;
    blockTimestamp: string;
}

export interface BidsResponse {
    allYoyoAuctionBidPlaceds: {
        nodes: BidPlaced[];
    };
}

// Auctions lifecycle queries types
export interface AuctionOpened {
    auctionId: string;
    blockTimestamp: string;
    blockNumber: string;
    endTime: string;
}

export interface AuctionClosed {
    auctionId: string;
    blockTimestamp: string;
    blockNumber: string;
}

// query GetAuctionsLifecycle response type
export interface AuctionsLifecycleResponse {
    allYoyoAuctionAuctionOpeneds: {
        nodes: AuctionOpened[];
    };
    allYoyoAuctionAuctionCloseds: {
        nodes: AuctionClosed[];
    };
}

// Previous bidder refunds queries types
export interface BidderRefund {
    previousBidder: Address;
    bidAmount: string;
    blocknumber: string;
    blockTimestamp: string;
    txHash: Hash;
}

export interface BidderRefundsResponse {
    allYoyoAuctionBidderRefundeds: {
        nodes: BidderRefund[];
    };
}

export interface BidderFailedRefundResponse {
    allYoyoAuctionBidderRefundFaileds: {
        nodes: BidderRefund[];
    };
} 

// Finalized auctions queries types
export interface FinalizedAuction {
    auctionId: string;
    nftOwner: Address;
    tokenId: string;
    blockNumber: string;
    blockTimestamp: string;
}

export interface FinalizedAuctionsResponse {
    allYoyoAuctionAuctionFinalizeds: {
        nodes: FinalizedAuction[];
    };
}

// Mint failed queries types
export interface FailedMint {
    auctionId: string;
    to: Address;
    tokenId: string;
    blockNumber: string;
    blockTimestamp: string;
}

export interface FailedMintResponse {
    allYoyoAuctionMintFaileds: {
        nodes: FailedMint[];
    };
}