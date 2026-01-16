import { useWriteContract, useWaitForTransactionReceipt, useChainId, useAccount } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQueryClient } from '@tanstack/react-query';
import { getBidderRefundsByAddress, getBidderFailedRefundsByAddress } from '../graphql/client';
import getUnclaimedRefund from '../utils/unclaimedRefund';
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

    // Refetch when the bid is confirmed
    // useEffect(() => {
    //     if (isConfirmed) {
    //         // Invalidate the current auction query
    //         queryClient.invalidateQueries({
    //             queryKey: ['readContract'],
    //         });
    //         // Invalidate the events query if using the indexer
    //         queryClient.invalidateQueries({
    //             queryKey: ['auctionEvents'],
    //         });
    //     }
    // }, [isConfirmed, queryClient]);

    // Function to call the claimFailedRefunds contract method
    const claimNft = () => {
        writeContract({
            address: yoyoAuctionAddress,
            abi: yoyoAuctionABI,
            functionName: 'claimNftForWinner',
            args: [10], // Placeholder auctionId, to be replaced with actual value
        });
    };

    return {
        claimNft,
        isWritePending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError || confirmError,
        //hasUnclaimedNft,
    };
};

export default useClaimNft;
