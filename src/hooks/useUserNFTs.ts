import { useQuery } from '@tanstack/react-query';
import { useAccount } from 'wagmi';
import { getReceivedNFTs, getSentNFTs } from '../graphql/client';
import getOwnedNFTs from '../utils/nftOwnership';
import type { OwnedNFT } from '../types/queriesTypes';
import type { Address } from 'viem';

function useUserNFTs(customAddress?: Address) {
    const { address: connectedAddress } = useAccount();

    // Use acustomAddress if provided, otherwise use connectedAddress
    const targetAddress = customAddress ?? connectedAddress;
    return useQuery({
        queryKey: ['userNFTs', targetAddress], // Cache key unica per indirizzo
        queryFn: async (): Promise<OwnedNFT[]> => {
            if (!targetAddress) return [];

            const [received, sent] = await Promise.all([getReceivedNFTs(targetAddress), getSentNFTs(targetAddress)]);

            console.log('Received NFTs:', received);
            console.log('Sent NFTs:', sent);

            const owned = getOwnedNFTs(received, sent);
            console.log('Owned NFTs:', owned);

            return owned;
        },
        enabled: !!targetAddress, // Esegui solo se address esiste
        gcTime: 1000 * 60 * 5, // 5 minutes cache
        staleTime: 1000 * 60 * 60, // 6 minutes stale time
        refetchOnWindowFocus: true, // refetch when window gets focus
    });
}

export default useUserNFTs;
