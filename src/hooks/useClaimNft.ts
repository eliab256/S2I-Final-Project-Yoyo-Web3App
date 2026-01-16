import { useWriteContract, useWaitForTransactionReceipt, useChainId, useAccount } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQueryClient, useQuery } from '@tanstack/react-query';
import type { FailedMint } from '../types/queriesTypes';
import { getAllMintFailed, getAllFinalizedAuctions } from '../graphql/client';
import getUnclaimedTokens from '../utils/unclaimedTokens';
import { useEffect } from 'react';

const useClaimNft = () => {
    const chainId = useChainId();
    const { address } = useAccount();
    const queryClient = useQueryClient();
    const yoyoAuctionAddress = chainsToContractAddress[chainId].yoyoAuctionAddress;
    const { writeContract, data: hash, isPending: isWritePending, error: writeError } = useWriteContract();
    const {
        isLoading: isConfirming,
        isSuccess: isConfirmed,
        error: confirmError,
    } = useWaitForTransactionReceipt({ hash });

    // Refetch when the tx is confirmed
    useEffect(() => {
    if (isConfirmed) {
        queryClient.invalidateQueries({
            queryKey: ['claimNft', address],
        });
    }
}, [isConfirmed, queryClient, address]);

    const failedMintQuery = useQuery({
        queryKey: ['claimNft', address],
        queryFn: async (): Promise<FailedMint | null> => {
            if (!address) return null;

            const [mintFaileds, finalizedAuctions] = await Promise.all([
                getAllMintFailed(address),
                getAllFinalizedAuctions(address),
            ]);

            const failedMint = getUnclaimedTokens(mintFaileds, finalizedAuctions);
            return failedMint;
        },
        enabled: !!address,
        refetchOnWindowFocus: true,
    });

    // Function to call the claimNftForWinner contract method
    const claimNft = () => {
        writeContract({
            address: yoyoAuctionAddress,
            abi: yoyoAuctionABI,
            functionName: 'claimNftForWinner',
            args: failedMintQuery.data ? [failedMintQuery.data.auctionId] : [], 
        });
    };

    const unclaimedNftId = failedMintQuery.data?.tokenId ?? null;

    return {
        claimNft,
        isWritePending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError || confirmError,
        unclaimedNftId,
    };
};

export default useClaimNft;
