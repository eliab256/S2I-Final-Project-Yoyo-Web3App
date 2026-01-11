import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useChainId } from 'wagmi';

function usePlaceBid() {
    const chainId = useChainId();
    const yoyoAuctionAddress = chainsToContractAddress[chainId].yoyoAuctionAddress;

    const { writeContract, data: hash, isPending: isWritePending, error: writeError } = useWriteContract();

    const {
        isLoading: isConfirming,
        isSuccess: isConfirmed,
        error: confirmError,
    } = useWaitForTransactionReceipt({ hash });

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
