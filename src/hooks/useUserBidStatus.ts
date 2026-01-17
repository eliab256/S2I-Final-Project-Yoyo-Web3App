import { useAccount } from 'wagmi';
import useCurrentAuction from './useCurrentAuction';
import getBidHistoryDetailFromAuctionId from '../utils/bidHistoryDetailFromAuctionId';
import type { ProcessedBids } from '../utils/bidHistoryDetailFromAuctionId';
import type { Address } from 'viem';
import { useQuery } from '@tanstack/react-query';

const useUserBidStatus = (customAddress?: Address, customAuctionId?: string) => {
    const { address: connectedAddress } = useAccount();
    const { auction } = useCurrentAuction();

    // Use acustomAddress if provided, otherwise use connectedAddress
    const targetAddress = customAddress ?? connectedAddress;

    // Use customAuctionId if provided, otherwise use current auction ID
    const targetAuctionId = customAuctionId ?? auction?.auctionId.toString();

    const {
        data: processedBids,
        isLoading,
        error,
    } = useQuery({
        queryKey: ['bidHistoryDetail', targetAuctionId],
        queryFn: async (): Promise<ProcessedBids | null> => {
            if (!targetAuctionId) return null;
            return await getBidHistoryDetailFromAuctionId(targetAuctionId);
        },
        enabled: !!targetAuctionId,
        refetchOnWindowFocus: true,
    });

    // Determine if the user has placed a bid
    const userHasBid =
        processedBids && targetAddress
            ? processedBids.orderedBidders.some(bidder => bidder.toLowerCase() === targetAddress.toLowerCase())
            : false;

    // Determine if the user is currently winning
    const userIsWinning =
        processedBids && targetAddress
            ? processedBids.highestBidder.toLowerCase() === targetAddress.toLowerCase()
            : false;

    return {
        userHasBid,
        userIsWinning,
        isLoading,
        error,
    };
};

export default useUserBidStatus;
