import type { Address, Hash } from 'viem';

export interface OwnedNFT {
    tokenId: string;
    mintedAt: string;
    mintTxHash: Hash;
}

export interface Transfer {
    from: Address;
    to: Address;
    tokenId: string;
    txHash: Hash;
    blockNumber: string;
    blockTimestamp: string;
}

export interface TransfersResponse {
    allTransfers: {
        nodes: Transfer[];
    };
}
