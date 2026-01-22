import { useWriteContract, useWaitForTransactionReceipt, useChainId, useAccount } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQuery } from '@tanstack/react-query';
import { getBidderRefundsByAddress, getBidderFailedRefundsByAddress } from '../graphql/client';
import getUnclaimedRefund from '../utils/unclaimedRefund';

/**
 * Custom hook to claim failed Ether refunds for users who experienced refund transaction failures.
 *
 * @remarks
 * This hook provides functionality to recover Ether when the automatic refund process fails
 * after losing an auction bid. It implements a comprehensive solution that:
 *
 * **Detection of Failed Refunds**: Queries the indexer database to identify refund transactions
 * that failed for the connected wallet address. This is done by cross-referencing successful
 * refunds with failed refund events to determine if there are any unclaimed amounts.
 *
 * **Smart Contract Interaction**: Calls the `claimFailedRefunds` function on the YoyoAuction
 * contract. This function verifies the user's eligibility and transfers the owed Ether back
 * to the user's wallet on-chain. Unlike `claimNftForWinner`, this function doesn't require
 * any arguments as it processes all failed refunds for the caller.
 *
 * **Real-time Validation**: The hook continuously monitors for unclaimed refunds through
 * a query that refetches when the window regains focus, ensuring the UI always reflects
 * the current refund status without requiring manual refreshes.
 *
 * **Multi-Chain Support**: The hook is chain-aware and automatically uses the correct
 * contract address based on the currently connected network via `chainsToContractAddress`.
 *
 * @used-in
 * - `ClaimFailedRefundButton.tsx` - Renders the claim refund button with transaction states
 *
 * @returns Object containing claim function, transaction states, and unclaimed refund status
 * @returns {() => void} claimRefund - Function to execute the refund claim transaction on the blockchain
 * @returns {boolean} isWritePending - True while the transaction is being signed/submitted
 * @returns {boolean} isConfirming - True while waiting for transaction confirmation on-chain
 * @returns {boolean} isConfirmed - True once the transaction has been successfully confirmed
 * @returns {string | undefined} hash - Transaction hash, available after submission
 * @returns {Error | null} error - Error object from either write or confirmation failures
 * @returns {boolean | undefined} hasUnclaimedRefund - True if the user has failed refunds to claim, false otherwise
 */

const useClaimRefund = () => {
    const chainId = useChainId();
    const { address } = useAccount();
    const yoyoAuctionAddress = chainsToContractAddress[chainId].yoyoAuctionAddress;
    const { writeContract, data: hash, isPending: isWritePending, error: writeError } = useWriteContract();
    const {
        isLoading: isConfirming,
        isSuccess: isConfirmed,
        error: confirmError,
    } = useWaitForTransactionReceipt({ hash });

    // Function to call the claimFailedRefunds contract method
    const claimRefund = () => {
        writeContract({
            address: yoyoAuctionAddress,
            abi: yoyoAuctionABI,
            functionName: 'claimFailedRefunds',
        });
    };

    // Query to check if the user has unclaimed refunds
    const { data: hasUnclaimedRefund } = useQuery({
        queryKey: ['claimRefund', address],
        queryFn: async () => {
            const result = await Promise.all([
                getBidderRefundsByAddress(address!),
                getBidderFailedRefundsByAddress(address!),
            ]);
            const [successfulRefunds, failedRefunds] = result;
            return getUnclaimedRefund(successfulRefunds, failedRefunds);
        },
        enabled: !!address,
        refetchOnWindowFocus: true,
    });

    return {
        claimRefund,
        isWritePending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError || confirmError,
        hasUnclaimedRefund,
    };
};

export default useClaimRefund;
