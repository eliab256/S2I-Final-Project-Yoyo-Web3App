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

    // Refetch quando la transazione è confermata
    useEffect(() => {
        if (isConfirmed) {
            // Invalida la query dell'auction corrente
            queryClient.invalidateQueries({
                queryKey: ['readContract'],
            });
            // Invalida anche la query degli eventi se usi l'indexer
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
