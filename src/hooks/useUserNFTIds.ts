import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import { useAccount } from 'wagmi';
import type { NftEventsCombined } from '../types/nftTypes';

const INDEXER_URL = import.meta.env.VITE_INDEXER_URL;
const INDEXER_WS_URL = import.meta.env.VITE_INDEXER_WS_URL;

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
            const response = await fetch(INDEXER_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    query: `
                        query GetUserNFTs($owner: String!) {
                            yoyo_nft_transfer(
                                where: { to: { _eq: $owner } }
                            ) {
                                token_id
                            }
                        }
                    `,
                    variables: { owner: address.toLowerCase() },
                }),
            });
            if (!response.ok) throw new Error('Failed to fetch NFTs');
            const result = await response.json();
            return result.data.yoyo_nft_transfer;
        },
        select: data => data.map(nft => nft.token_id),
        enabled: !!address,
    });

    useEffect(() => {
        if (!address) return;

        const ws = new WebSocket(INDEXER_WS_URL);

        ws.onopen = () => {
            // Inizializza la connessione GraphQL WebSocket
            ws.send(
                JSON.stringify({
                    type: 'connection_init',
                })
            );

            // Sottoscrivi agli eventi Transfer per l'utente
            ws.send(
                JSON.stringify({
                    id: '1',
                    type: 'start',
                    payload: {
                        query: `
                        subscription OnNFTEvents($owner: String!) {
                            yoyo_nft_transfer(
                                where: { to: { _eq: $owner } }
                            ) {
                                token_id
                                to
                                from
                            }
                        }
                    `,
                        variables: { owner: address.toLowerCase() },
                    },
                })
            );
        };

        ws.onmessage = event => {
            const data = JSON.parse(event.data);
            // Quando arrivano nuovi dati dalla subscription
            if (data.type === 'data') {
                queryClient.invalidateQueries({ queryKey: ['userNFTs', address] });
            }
        };

        ws.onerror = error => {
            console.error('WebSocket error:', error);
        };

        return () => ws.close();
    }, [address, queryClient]);

    return { tokenIds, isLoading, error };
}

export default useUserNFTIds;
