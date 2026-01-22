import { useAccount } from 'wagmi';
import useCurrentAuction from './useCurrentAuction';
import getBidHistoryDetailFromAuctionId from '../utils/bidHistoryDetailFromAuctionId';
import type { ProcessedBids } from '../utils/bidHistoryDetailFromAuctionId';
import type { Address } from 'viem';
import { useQuery } from '@tanstack/react-query';

/**
 * Custom hook to check a user's bidding status on an auction.
 *
 * @remarks
 * This hook provides real-time information about a user's participation and standing in
 * an auction. It's designed with flexibility to support both current user status checks
 * and historical/external address lookups:
 *
 * **Flexible Address Targeting**: By default, checks the status of the currently connected
 * wallet. However, it accepts an optional `customAddress` parameter to check the status of
 * any other wallet address, enabling use cases like viewing other users' profiles or
 * historical auction analysis.
 *
 * **Flexible Auction Targeting**: By default, checks the status on the current active auction
 * (via `useCurrentAuction`). However, it accepts an optional `customAuctionId` parameter to
 * check status on any past or specific auction, enabling historical bid tracking and
 * auction archive views.
 *
 * **Processed Bid Data**: Leverages the `getBidHistoryDetailFromAuctionId` utility which
 * returns structured bid data including an ordered list of all bidders and the current
 * highest bidder. This processing happens via React Query for efficient caching and refetching.
 *
 * **Case-Insensitive Comparison**: All address comparisons are performed in lowercase to
 * ensure reliable matching regardless of address checksum formatting (0x vs 0X, mixed case).
 *
 * **Automatic Refetching**: The query refetches when the browser window regains focus,
 * ensuring users see up-to-date bid status when returning to the application tab.
 *
 * **Null Safety**: Gracefully handles cases where no address is connected, no auction exists,
 * or bid data hasn't loaded yet by returning `false` for both status flags.
 *
 * @used-in
 *  - CurrentAuction.tsx - To display to the user if they have placed bids has been outbid or if they are winning.
 *
 * @param {Address} [customAddress] - Optional address to check status for (defaults to connected wallet)
 * @param {string} [customAuctionId] - Optional auction ID to check status on (defaults to current auction)
 *
 * @returns Object containing the user's bid status and query states
 * @returns {boolean} userHasBid - True if the target address has placed at least one bid on the auction
 * @returns {boolean} userIsWinning - True if the target address is currently the highest bidder
 * @returns {boolean} isLoading - True while fetching bid history data
 * @returns {Error | null} error - Error object if the bid history query failed
 */

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
