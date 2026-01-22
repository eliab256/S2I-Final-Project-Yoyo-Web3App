import { useWriteContract, useWaitForTransactionReceipt, useChainId } from 'wagmi';
import { yoyoNftABI } from '../contracts/yoyoNftAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import type { Address } from 'viem';

/**
 * Custom hook to transfer YoYo NFTs to another wallet address.
 *
 * @remarks
 * This hook provides NFT transfer functionality for users who own YoYo NFTs and want to
 * send them to another address. It implements a complete transaction flow:
 *
 * **Token-Specific Initialization**: The hook is initialized with a specific `tokenId`,
 * binding the transfer function to that particular NFT. This design ensures type safety
 * and prevents accidental transfers of the wrong token.
 *
 * **Smart Contract Interaction**: Calls the `transferNft` function on the YoYoNFT contract,
 * passing the recipient address and the token ID. The contract validates ownership before
 * executing the transfer, ensuring only the rightful owner can move the NFT.
 *
 * **Multi-Chain Support**: The hook is chain-aware and automatically uses the correct
 * NFT contract address based on the currently connected network via `chainsToContractAddress`.
 *
 * **Transaction State Management**: Provides granular transaction states (pending, confirming,
 * confirmed) and error handling for both the write operation and confirmation phases, enabling
 * precise UI feedback during the transfer process.
 *
 * **Address Validation**: The `transferNft` function accepts a typed `Address` parameter,
 * leveraging Viem's type system to ensure only valid Ethereum addresses can be used as
 * transfer recipients.
 *
 * @used-in
 *  - NftDetails.tsx - Enables users to transfer their YoYo NFTs from the NFT details page.
 *
 * @param {number} tokenId - The ID of the NFT to be transferred
 *
 * @returns Object containing the transfer function and transaction states
 * @returns {(to: Address) => void} transferNft - Function to transfer the NFT to the specified address
 * @returns {boolean} isWritePending - True while the transaction is being signed/submitted
 * @returns {boolean} isConfirming - True while waiting for transaction confirmation on-chain
 * @returns {boolean} isConfirmed - True once the transaction has been successfully confirmed
 * @returns {string | undefined} hash - Transaction hash, available after submission
 * @returns {Error | null} error - Error object from either write or confirmation failures
 */

const useTransferNft = (tokenId: number) => {
    const chainId = useChainId();
    const yoyoNftAddress = chainsToContractAddress[chainId].yoyoNftAddress;

    const { writeContract, data: hash, isPending: isWritePending, error: writeError } = useWriteContract();
    const {
        isLoading: isConfirming,
        isSuccess: isConfirmed,
        error: confirmError,
    } = useWaitForTransactionReceipt({ hash });

    const transferNft = (to: Address) => {
        writeContract({
            address: yoyoNftAddress,
            abi: yoyoNftABI,
            functionName: 'transferNft',
            args: [to, BigInt(tokenId)],
        });
    };

    return {
        transferNft,
        isWritePending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError || confirmError,
    };
};

export default useTransferNft;
