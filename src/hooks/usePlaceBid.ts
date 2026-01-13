import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useChainId } from 'wagmi';
import { useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';

function usePlaceBid() {
    const chainId = useChainId();
    const yoyoAuctionAddress = chainsToContractAddress[chainId].yoyoAuctionAddress;
    const queryClient = useQueryClient();

    const { writeContract, data: hash, isPending: isWritePending, error: writeError } = useWriteContract();

    const {
        isLoading: isConfirming,
        isSuccess: isConfirmed,
        error: confirmError,
    } = useWaitForTransactionReceipt({ hash });

    // Refetch when the bid is confirmed
    useEffect(() => {
        if (isConfirmed) {
            // Invalidate the current auction query
            queryClient.invalidateQueries({
                queryKey: ['readContract'],
            });
            // Invalidate the events query if using the indexer
            queryClient.invalidateQueries({
                queryKey: ['auctionEvents'],
            });
        }
    }, [isConfirmed, queryClient]);

    const placeBid = (bidAmount: string, auctionId: bigint) => {
        const bidAmountInWei = parseEther(bidAmount);

        writeContract({
            address: yoyoAuctionAddress,
            abi: yoyoAuctionABI,
            functionName: 'placeBidOnAuction',
            args: [auctionId],
            value: bidAmountInWei,
        });
    };

    return {
        placeBid,
        isWritePending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError || confirmError,
    };
}

export default usePlaceBid;
