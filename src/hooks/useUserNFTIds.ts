import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import { useAccount } from 'wagmi';
import type { NftEventsCombined } from '../types/nftTypes';

function useUserNFTIds() {
    const { address } = useAccount();
    const queryClient = useQueryClient();

    const {
        data: tokenIds,
        isLoading,
        error,
    } = useQuery<NftEventsCombined[], Error, number[]>({
        queryKey: ['userNFTs', address],
        queryFn: async () => {
            if (!address) return [];
            const response = await fetch(`/api/nfts/owned?address=${address}`);
            if (!response.ok) throw new Error('Failed to fetch NFTs');
            return response.json();
        },
        select: data => data.map(nft => nft.token_id),
        enabled: !!address,
    });

    useEffect(() => {
        if (!address) return;
        const ws = new WebSocket(`ws://your-server/nft-events?address=${address}`);

        ws.onmessage = event => {
            const data = JSON.parse(event.data);
            if (data.type === 'NFT_MINTED' || data.type === 'NFT_TRANSFERRED') {
                queryClient.invalidateQueries({ queryKey: ['userNFTs', address] });
            }
        };

        return () => ws.close();
    }, [address, queryClient]);

    return { tokenIds, isLoading, error };
}

export default useUserNFTIds;
