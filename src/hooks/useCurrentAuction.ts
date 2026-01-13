import { useReadContract, useChainId } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import type { AuctionStruct } from '../types/contractsTypes';
import { getAuctionsLifecycle } from '../graphql/client';
import getCurrentOpenAuction from '../utils/currentOpenAuction';

/**
 * Custom hook to fetch the current auction data.
 *
 * @remarks
 * This hook implements a hybrid approach to balance security and resource optimization:
 *
 * **Security First**: The primary data source is always the blockchain itself via `useReadContract`.
 * Reading directly from the blockchain ensures data integrity and prevents manipulation,
 * as the blockchain is the single source of truth.
 *
 * **Optimized Refetching**: Instead of polling the blockchain continuously (which would be
 * resource-intensive and costly in terms of RPC calls), this hook monitors auction lifecycle
 * events (AuctionOpened/AuctionClosed) from the indexer database. When the indexed `auctionId`
 * changes, it triggers a refetch of the blockchain data.
 *
 * **Intelligent Polling**: The indexer monitoring uses adaptive intervals:
 * - Every 30 seconds when no auction is active
 * - Every 10 seconds when the auction is close to expiring (< 5 minutes remaining)
 * - Every 60 seconds during normal auction periods
 *
 * This approach minimizes unnecessary blockchain reads while maintaining security and ensuring
 * the UI stays up-to-date with auction state changes.
 *
 * @returns Object containing the current auction data and loading state
 * @returns {AuctionStruct} auction - The current auction data read from the blockchain
 * @returns {boolean} isLoading - Loading state of the blockchain read operation
 */
function useCurrentAuction() {
    const queryClient = useQueryClient();
    const chainId = useChainId();
    const yoyoAuctionAddress = chainsToContractAddress[chainId]?.yoyoAuctionAddress;

    // Monitor events from the indexer to know when to refetch
    const { data: indexedAuction } = useQuery({
        queryKey: ['auctionEvents'],
        queryFn: async () => {
            const lifecycleData = await getAuctionsLifecycle();
            return getCurrentOpenAuction(lifecycleData);
        },
        refetchInterval: query => {
            const auction = query.state.data;
            if (!auction) return 30000; // Check every 30s if there is no auction

            const now = Math.floor(Date.now() / 1000);
            const endTime = parseInt(auction.endTime);
            const timeUntilEnd = endTime - now;

            // If less than 5 minutes remain, check every 10s
            if (timeUntilEnd < 300) return 10000;
            return 60000;
        },
    });

    // Read from the blockchain the current auction data
    const {
        data: auctionData,
        isLoading,
        refetch,
    } = useReadContract({
        address: yoyoAuctionAddress,
        abi: yoyoAuctionABI,
        functionName: 'getCurrentAuction',
    }) as { data: AuctionStruct | undefined; isLoading: boolean; refetch: () => void };

    const indexedAuctionId = indexedAuction?.auctionId;
    const currentAuctionId = auctionData?.auctionId;

    // When the auctionId changes in the events, it invalidates the reading from the blockchain.
    useEffect(() => {
        if (indexedAuctionId !== undefined && indexedAuctionId !== currentAuctionId?.toString()) {
            queryClient.invalidateQueries({
                queryKey: ['readContract'],
            });
        }
    }, [indexedAuctionId, currentAuctionId, queryClient]);

    // Invalidate the bids when the auction changes.
    useEffect(() => {
        if (currentAuctionId !== undefined) {
            queryClient.invalidateQueries({
                queryKey: ['auctionBids', currentAuctionId],
            });
        }
    }, [currentAuctionId, queryClient]);

    return {
        auction: auctionData as AuctionStruct,
        isLoading,
        refetch,
    };
}

export default useCurrentAuction;
