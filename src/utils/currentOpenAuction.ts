import type {AuctionsLifecycleResponse, AuctionOpened } from '../types/queriesTypes';

function getCurrentOpenAuction(data: AuctionsLifecycleResponse): AuctionOpened | null {
    const openedAuctions = data.allYoyoAuctionAuctionOpeneds.nodes;
    const closedAuctions = data.allYoyoAuctionAuctionCloseds.nodes;

    // Filter out auctions that have been closed
    const stillOpenAuctions = openedAuctions.filter(
        opened => !closedAuctions.some(closed => closed.auctionId === opened.auctionId)
    );

    // If no auctions are open, return null
    if (stillOpenAuctions.length === 0) return null;

    // Get the most recent auction (highest auctionId or latest blockNumber)
    const latestAuction = stillOpenAuctions.reduce((latest, current) => {
        return BigInt(current.auctionId) > BigInt(latest.auctionId) ? current : latest;
    });

    // Check if the auction is still active (endTime > now)
    const now = Math.floor(Date.now() / 1000); // Current time in seconds
    const endTime = parseInt(latestAuction.endTime);

    if (endTime <= now) {
        return null; // Auction has expired
    }

    return latestAuction;
}

export default getCurrentOpenAuction;