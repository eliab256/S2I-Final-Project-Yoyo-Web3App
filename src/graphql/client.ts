import type { Address } from 'viem';
import type { TransferEvent, TransfersResponse, BidsResponse, BidPlaced, AuctionsLifecycleResponse } from '../types/queriesTypes';
import { GET_RECEIVED_NFTS, GET_SENT_NFTS, GET_BID_HYSTORY_FROM_AUCTION_ID, GET_AUCTIONS_LIFECYCLE } from './queries';

const GRAPHQL_ENDPOINT = import.meta.env.VITE_INDEXER_URL || 'http://localhost:3001/graphql';

async function fetchGraphQL(query: string, variables: Record<string, any> = {}) {
    const response = await fetch(GRAPHQL_ENDPOINT, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            query,
            variables,
        }),
    });

    const { data, errors } = await response.json();

    if (errors) {
        throw new Error(errors[0].message);
    }

    return data;
}

export async function getReceivedNFTs(ownerAddress: Address): Promise<TransferEvent[]> {
    const data = (await fetchGraphQL(GET_RECEIVED_NFTS, {
        ownerAddress: ownerAddress.toLowerCase(),
    })) as TransfersResponse;
    return data.allTransfers.nodes;
}

export async function getSentNFTs(ownerAddress: Address): Promise<TransferEvent[]> {
    const data = (await fetchGraphQL(GET_SENT_NFTS, { ownerAddress: ownerAddress.toLowerCase() })) as TransfersResponse;
    return data.allTransfers.nodes;
}

export async function getBidHistoryFromAuctionId(auctionId: string): Promise<BidPlaced[]> {
    const data = (await fetchGraphQL(GET_BID_HYSTORY_FROM_AUCTION_ID, { auctionId: auctionId })) as BidsResponse;
    return data.allYoyoAuctionBidPlaceds.nodes;
}

export async function getAuctionsLifecycle(): Promise<AuctionsLifecycleResponse> {
    const data = (await fetchGraphQL(GET_AUCTIONS_LIFECYCLE)) as AuctionsLifecycleResponse;
    return data;
}
