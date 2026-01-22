import { useWriteContract, useWaitForTransactionReceipt, useChainId, useAccount } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQueryClient, useQuery } from '@tanstack/react-query';
import type { FailedMint } from '../types/queriesTypes';
import { getAllMintFailed, getAllFinalizedAuctions } from '../graphql/client';
import getUnclaimedTokens from '../utils/unclaimedTokens';
import { useEffect } from 'react';

/**
 * Custom hook to claim NFTs for users who won auctions but experienced failed mints.
 *
 * @remarks
 * This hook provides functionality to recover NFTs when the automatic minting process fails
 * after winning an auction. It implements a comprehensive solution that:
 *
 * **Detection of Failed Mints**: Queries the indexer database to identify auctions where
 * the user won but the NFT mint transaction failed. This is done by cross-referencing
 * finalized auctions with failed mint events for the connected wallet address.
 *
 * **Smart Contract Interaction**: Calls the `claimNftForWinner` function on the YoyoAuction
 * contract, passing the auctionId of the failed mint. This function verifies the user's
 * eligibility and mints the NFT on-chain.
 *
 * **Automatic Cache Invalidation**: After a successful claim transaction is confirmed,
 * the hook automatically invalidates and refetches the failed mints query to update the UI
 * and prevent duplicate claims.
 *
 * **Multi-Chain Support**: The hook is chain-aware and automatically uses the correct
 * contract address based on the currently connected network via `chainsToContractAddress`.
 *
 * @used-in
 * - `ClaimNftButton.tsx` - Renders the claim button with transaction states
 * - `bidResume.tsx` - Displays unclaimed NFT information in the bid summary
 *
 * @returns Object containing claim function, transaction states, and unclaimed NFT information
 * @returns {() => void} claimNft - Function to execute the NFT claim transaction on the blockchain
 * @returns {boolean} isWritePending - True while the transaction is being signed/submitted
 * @returns {boolean} isConfirming - True while waiting for transaction confirmation on-chain
 * @returns {boolean} isConfirmed - True once the transaction has been successfully confirmed
 * @returns {string | undefined} hash - Transaction hash, available after submission
 * @returns {Error | null} error - Error object from either write or confirmation failures
 * @returns {string | null} unclaimedNftId - The tokenId of the unclaimed NFT, or null if none exists
 */

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

    // Query to get failed mints for the connected user
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

    // Extract unclaimedNftId from the query data, if null set to null
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
