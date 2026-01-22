import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useChainId } from 'wagmi';
import { useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';

/**
 * Custom hook to place bids on active auctions.
 *
 * @remarks
 * This hook provides the core bidding functionality for the auction system, handling
 * the complete lifecycle of a bid transaction from submission to confirmation:
 *
 * **Bid Amount Conversion**: Automatically converts the user-provided ETH amount (as a string)
 * to Wei using `parseEther` before sending it to the contract. This ensures precise handling
 * of decimal values and prevents rounding errors.
 *
 * **Smart Contract Interaction**: Calls the `placeBidOnAuction` function on the YoyoAuction
 * contract, passing the auction ID as an argument and the bid amount as the transaction value.
 * The contract validates the bid amount, checks auction status, and processes the bid on-chain.
 *
 * **Automatic Cache Invalidation**: After a successful bid confirmation, the hook automatically
 * invalidates multiple queries to ensure the UI reflects the updated state:
 * - `readContract`: Refreshes the current auction data (new highest bid, bidder count, etc.)
 * - `auctionEvents`: Updates the indexer-based auction lifecycle monitoring
 * - `bidHistoryDetail`: Refreshes the user's personal bid history and status
 *
 * **Multi-Chain Support**: The hook is chain-aware and automatically uses the correct
 * contract address based on the currently connected network via `chainsToContractAddress`.
 *
 * **Transaction State Management**: Provides granular transaction states (pending, confirming,
 * confirmed) and error handling for both the write operation and confirmation phases, enabling
 * precise UI feedback during the bidding process.
 *
 * @used-in
 * - BidResume.tsx on the button that confirms placing a bid
 *
 *
 * @returns Object containing the bid placement function and transaction states
 * @returns {(bidAmount: string, auctionId: bigint) => void} placeBid - Function to place a bid with the specified amount and auction ID
 * @returns {boolean} isWritePending - True while the transaction is being signed/submitted
 * @returns {boolean} isConfirming - True while waiting for transaction confirmation on-chain
 * @returns {boolean} isConfirmed - True once the transaction has been successfully confirmed
 * @returns {string | undefined} hash - Transaction hash, available after submission
 * @returns {Error | null} error - Error object from either write or confirmation failures
 */

const usePlaceBid = () => {
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
            queryClient.invalidateQueries({ queryKey: ['readContract'] });

            // Invalidate the events query if using the indexer
            queryClient.invalidateQueries({ queryKey: ['auctionEvents'] });

            // Invalidate the user bid status query
            queryClient.invalidateQueries({ queryKey: ['bidHistoryDetail'] });
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
};

export default usePlaceBid;
