import { useWriteContract, useWaitForTransactionReceipt, useChainId, useAccount } from 'wagmi';
import { yoyoAuctionABI } from '../contracts/yoyoAuctionAbi';
import { chainsToContractAddress } from '../contracts/addresses';
import { useQuery } from '@tanstack/react-query';
import { getBidderRefundsByAddress, getBidderFailedRefundsByAddress } from '../graphql/client';
import getUnclaimedRefund from '../utils/unclaimedRefund';

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
