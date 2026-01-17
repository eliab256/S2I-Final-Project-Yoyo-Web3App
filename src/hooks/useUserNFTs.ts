import { useQuery } from '@tanstack/react-query';
import { useAccount } from 'wagmi';
import { getReceivedNFTs, getSentNFTs } from '../graphql/client';
import getOwnedNFTs from '../utils/nftOwnership';
import type { OwnedNFT } from '../types/queriesTypes';
import type { Address } from 'viem';

const useUserNFTs = (customAddress?: Address) => {
    const { address: connectedAddress } = useAccount();

    // Use acustomAddress if provided, otherwise use connectedAddress
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
}

export default useUserNFTs;
