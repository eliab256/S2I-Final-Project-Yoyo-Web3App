import type { BidPlaced } from '../types/queriesTypes';
import type { Address } from 'viem';
import { getBidHistoryFromAuctionId } from '../graphql/client';

export interface ProcessedBids {
    orderedBids: BidPlaced[]; // From oldest to newest
    highestBidAmount: string;
    highestBidder: Address;
}

async function getBidHistoryOrderedFromAuctionId(auctionId: string): Promise<ProcessedBids | null> {
    const bids = await getBidHistoryFromAuctionId(auctionId);

    if (!bids || bids.length === 0) {
        return null;
    }

    // 2. Order bids by blockTimestamp ascending
    const orderedBids = [...bids].sort(
        (a, b) => new Date(a.blockTimestamp).getTime() - new Date(b.blockTimestamp).getTime()
    );

    // 3. Find the bid with the highest bidAmount
    const highestBid = bids.reduce((max, bid) => (BigInt(bid.bidAmount) > BigInt(max.bidAmount) ? bid : max));

    return {
        orderedBids,
        highestBidAmount: highestBid.bidAmount,
        highestBidder: highestBid.bidder,
    };
}

export default getBidHistoryOrderedFromAuctionId;
