import type { Address } from 'viem';
import type { Transfer, TransfersResponse } from '../types/queriesTypes';
import { GET_RECEIVED_NFTS, GET_SENT_NFTS } from './queries';

const GRAPHQL_ENDPOINT = 'http://localhost:3001/playground';

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

export async function getReceivedNFTs(ownerAddress: Address): Promise<Transfer[]> {
    const data = (await fetchGraphQL(GET_RECEIVED_NFTS, { ownerAddress })) as TransfersResponse;
    return data.allTransfers.nodes;
}

export async function getSentNFTs(ownerAddress: Address): Promise<Transfer[]> {
    const data = (await fetchGraphQL(GET_SENT_NFTS, { ownerAddress })) as TransfersResponse;
    return data.allTransfers.nodes;
}
