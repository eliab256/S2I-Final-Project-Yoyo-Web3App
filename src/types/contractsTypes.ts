import type { Address } from 'viem';

export interface AuctionStruct {
    auctionId: bigint;
    tokenId: bigint;
    nftOwner: Address | 0;
    state: AuctionState; // ← Cambiato da auctionState a state
    auctionType: AuctionType;
    startPrice: bigint;
    startTime: bigint;
    endTime: bigint;
    higherBidder: Address | 0;
    higherBid: bigint;
    minimumBidChangeAmount: bigint;
}

export type AuctionState = 0 | 1 | 2 | 3; // 0: NotStrarted, 1: Open, 2: Closed, 3: Finalized
export type AuctionType = 0 | 1; // 0: English, 1: Dutch
