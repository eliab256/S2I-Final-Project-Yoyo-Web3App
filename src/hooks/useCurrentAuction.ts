import { useReadContract, useChainId } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import type { AuctionStruct } from '../types/contractsTypes';

function useCurrentAuction() {
    const queryClient = useQueryClient();
    const chainId = useChainId();
    const yoyoAuctionAddress = chainsToContractAddress[chainId]?.yoyoAuctionAddress;

    const { data: auctionData, isLoading } = useReadContract({
        address: yoyoAuctionAddress,
        abi: yoyoAuctionABI,
        functionName: 'getCurrentAuction',
        query: {
            refetchInterval: 10000, // 🔄 Aggiorna ogni 10 secondi - DA CAMBIARE CON LETTURA NUOVO EVENTO AUCTIONOPEN
        },
    }) as { data: AuctionStruct | undefined; isLoading: boolean };
  
    const auctionId = auctionData?.auctionId;

    useEffect(() => {
        if (auctionId !== undefined) {
            queryClient.invalidateQueries({
                queryKey: ['auctionBids', auctionId],
            });
        }
    }, [auctionId, queryClient]);

    return {
        auction: auctionData as AuctionStruct, // return the entire AuctionStruct
        isLoading,
    };
}

export default useCurrentAuction;
