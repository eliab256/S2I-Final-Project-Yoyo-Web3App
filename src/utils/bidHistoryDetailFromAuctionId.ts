import type { BidPlaced } from '../types/queriesTypes';
import type { Address } from 'viem';
import { getBidHistoryFromAuctionId } from '../graphql/client';

export interface ProcessedBids {
    orderedBids: BidPlaced[]; // From oldest to newest
    orderedBidders: Address[];
    highestBidAmount: string;
    highestBidder: Address;
}

async function getBidHistoryDetailFromAuctionId(auctionId: string): Promise<ProcessedBids | null> {
    const orderedBids = await getBidHistoryFromAuctionId(auctionId);

    if (!orderedBids || orderedBids.length === 0) {
        return null;
    }
    console.log('orderedBids in util:', orderedBids);
    // 1. Find the bid with the highest bidAmount
    const highestBid = orderedBids.reduce((max, bid) => (BigInt(bid.bidAmount) > BigInt(max.bidAmount) ? bid : max));

    // 2. Extract bidders in chronological order
    const orderedBidders = orderedBids.map(bid => bid.bidder);

    return {
        orderedBids, //query already returns ordered bids from oldest to newest
        orderedBidders,
        highestBidAmount: highestBid.bidAmount,
        highestBidder: highestBid.bidder,
    };
}

export default getBidHistoryDetailFromAuctionId;
