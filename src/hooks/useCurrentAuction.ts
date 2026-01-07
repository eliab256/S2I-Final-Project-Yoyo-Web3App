import { useReadContract, useChainId } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';

function useCurrentAuction() {
    const queryClient = useQueryClient();
    const chainId = useChainId();
    const yoyoAuctionAddress = chainsToContractAddress[chainId]?.yoyoAuctionAddress;

    const { data: currentAuctionId, isLoading: isLoadingId } = useReadContract({
        address: yoyoAuctionAddress,
        abi: yoyoAuctionABI,
        functionName: 'getCurrentAuctionId',
        query: {
            refetchInterval: 30000, //DA CAMBIARE CON LETTURA NUOVO EVENTO AUCTIONOPEN
        },
    });

    const { data: auctionData, isLoading: isLoadingAuction } = useReadContract({
        address: yoyoAuctionAddress,
        abi: yoyoAuctionABI,
        functionName: 'getAuctionFromAuctionId',
        args: currentAuctionId !== undefined ? [currentAuctionId] : undefined,
        query: {
            enabled: currentAuctionId !== undefined, 
            refetchInterval: 10000, // 🔄 Aggiorna ogni 10 secondi
        },
    });

    useEffect(() => {
        if (currentAuctionId !== undefined) {
            queryClient.invalidateQueries({
                queryKey: ['auctionBids', currentAuctionId],
            });
        }
    }, [currentAuctionId, queryClient]);

    return {
        auctionId: currentAuctionId,
        auction: auctionData,
        isLoading: isLoadingId || isLoadingAuction,
    };
}

export default useCurrentAuction;
