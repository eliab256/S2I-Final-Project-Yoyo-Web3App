import { useWriteContract, useWaitForTransactionReceipt, useChainId } from 'wagmi';
import { yoyoNftABI } from '../contracts/yoyoNftAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import type { Address } from 'viem';

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
