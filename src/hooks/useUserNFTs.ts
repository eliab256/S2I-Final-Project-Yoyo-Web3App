import { useQuery } from '@tanstack/react-query';
import { useAccount } from 'wagmi';
import { getReceivedNFTs, getSentNFTs } from '../graphql/client';
import getOwnedNFTs from '../utils/nftOwnership';
import type { OwnedNFT } from '../types/queriesTypes';
import type { Address } from 'viem';

/**
 * Custom hook to retrieve all YoYo NFTs owned by a wallet address.
 *
 * @remarks
 * This hook provides a complete view of NFT ownership by analyzing the full transfer history
 * of a wallet address. It implements intelligent ownership calculation and caching:
 *
 * **Avoid OwnerOf function loop calls**: Rather than iterating over ownerOf calls, which becomes
 * prohibitively expensive in terms of gas usage, this hook relies on indexed NFT transfer events
 * to compute the current ownership via the getOwnedNFTs utility.
 *
 * **Flexible Address Targeting**: By default, fetches NFTs for the currently connected wallet.
 * However, it accepts an optional `customAddress` parameter to retrieve NFTs for any other
 * wallet address, enabling use cases like viewing other users' collections or marketplace
 * profile pages.
 *
 * **Ownership Calculation via Transfer History**: Rather than relying on a single ownership
 * query, the hook fetches both received and sent NFT transfer events from the indexer, then
 * uses the `getOwnedNFTs` utility to calculate current ownership. This approach ensures accuracy
 * even if the indexer doesn't maintain a direct ownership mapping.
 *
 * **Parallel Data Fetching**: Uses `Promise.all` to fetch received and sent NFTs simultaneously,
 * minimizing total query time and improving performance.
 *
 * **Aggressive Caching Strategy**: Implements a two-tier caching approach:
 * - `gcTime: 5 minutes` - Cached data is garbage collected after 5 minutes of inactivity
 * - `staleTime: 1 hour` - Data is considered fresh for 1 hour, preventing unnecessary refetches
 * This is appropriate since NFT ownership changes infrequently compared to auction bids.
 *
 * **Automatic Refetching**: The query refetches when the browser window regains focus,
 * ensuring users see updated NFT ownership if transfers occurred in another tab or application.
 *
 * **Address-Specific Cache Keys**: Each wallet address has its own cache entry, preventing
 * cache collisions when switching between addresses or viewing multiple profiles.
 *
 * @used-in
 *  - MyNfts.tsx - To display the connected user's owned YoYo NFTs in their profile page.
 *
 * @param {Address} [customAddress] - Optional address to fetch NFTs for (defaults to connected wallet)
 *
 * @returns React Query result object containing the owned NFTs array and query states
 * @returns {OwnedNFT[]} data - Array of NFTs currently owned by the target address (empty array if none)
 * @returns {boolean} isLoading - True while fetching NFT transfer history
 * @returns {boolean} isError - True if the query failed
 * @returns {Error | null} error - Error object if the query failed
 * @returns {() => void} refetch - Function to manually refetch the NFT ownership data
 */

const useUserNFTs = (customAddress?: Address) => {
    const { address: connectedAddress } = useAccount();

    // Use customAddress if provided, otherwise use connectedAddress
    const targetAddress = customAddress ?? connectedAddress;
    return useQuery({
        queryKey: ['userNFTs', targetAddress], // Cache key unica per indirizzo
        queryFn: async (): Promise<OwnedNFT[]> => {
            if (!targetAddress) return [];

            const [received, sent] = await Promise.all([getReceivedNFTs(targetAddress), getSentNFTs(targetAddress)]);

            const owned = getOwnedNFTs(received, sent);

            return owned;
        },
        enabled: !!targetAddress,
        gcTime: 1000 * 60 * 5,
        staleTime: 1000 * 60 * 60,
        refetchOnWindowFocus: true, // refetch when window gets focus
    });
};

export default useUserNFTs;
