//import type { AuctionStruct } from '../types/contractsTypes';
import { useDispatch, useSelector } from 'react-redux';
import {
    resetConfirmPlaceBid,
    setAlreadyHigherBidder,
    setHasUnclaimedTokens,
    setInsufficientBalance,
    selectConfirmPlaceBid,
} from '../../redux/confirmPlaceBidSlice';
import useCurrentAuction from '../../hooks/useCurrentAuction';
import usePlaceBid from '../../hooks/usePlaceBid';
import { useEffect } from 'react';
import { useBalance, useAccount } from 'wagmi';
import BidStatusCheck from '../auction/BidStatusCheck';
import ErrorBox from '../ui/ErrorBox';
import SuccessBox from '../ui/SuccessBox';
import  useClaimNft  from '../../hooks/useClaimNft';

interface BidResumeProps {
    bidAmount: string;
}

const BidResume: React.FC<BidResumeProps> = ({ bidAmount }) => {
    const dispatch = useDispatch();
    const { address } = useAccount();
    const { data: balanceData, isLoading: isBalanceLoading } = useBalance({
        address,
        query: { enabled: !!address },
    });
    const { auction, isLoading } = useCurrentAuction();
    const { insufficientBalance, alreadyHigherBidder, hasUnclaimedTokens } = useSelector(selectConfirmPlaceBid);
    const { placeBid, isWritePending, isConfirming, isConfirmed, hash, error } = usePlaceBid();
    const { unclaimedNftId } = useClaimNft();

    const { higherBidder, higherBid } = auction || {};

    useEffect(() => {
        const bidPlacedInWei: bigint = BigInt(Math.floor(parseFloat(bidAmount) * 1e18));
        let userBalance: bigint;
        if (balanceData === undefined) {
            userBalance = BigInt(0);
        } else {
            userBalance = balanceData.value;
        }
        if (userBalance <= bidPlacedInWei) {
            //set not enough balance true on redux
            dispatch(setInsufficientBalance(true));
        }

        if (higherBidder === address) {
            //set already higher bidder true on redux
            dispatch(setAlreadyHigherBidder(true));
        }

        //mannca il check per gli unclaimed tokens
        const hasUnclaimedToken: boolean = unclaimedNftId !== null; 
        if (hasUnclaimedToken) {
            dispatch(setHasUnclaimedTokens(true));
        }
    }, [bidAmount, dispatch, higherBid, higherBidder, unclaimedNftId]);

    const handleConfirmBid = () => {
        if (!auction?.auctionId) return;
        placeBid(bidAmount, auction.auctionId);
    };

    const canConfirmBid = !insufficientBalance && !alreadyHigherBidder && !hasUnclaimedTokens;

    //if transaction is confirmed show success box
    if (isConfirmed && hash) {
        return (
            <SuccessBox
                title="Bid Placed Successfully!"
                message="Your bid has been successfully placed on the blockchain."
                txHash={hash}
                onClose={() => dispatch(resetConfirmPlaceBid())}
            />
        );
    }

    // if there is an error show warning box
    if (error) {
        return (
            <ErrorBox
                title="Bid Placement Failed"
                message={error.message}
                onClose={() => dispatch(resetConfirmPlaceBid())}
            />
        );
        
    }

    //otherwise show modal with bid resume
    return (
        <>
            <div
                className="fixed inset-0 z-50 flex items-center justify-center"
                onClick={() => dispatch(resetConfirmPlaceBid())}
            >
                <div className="absolute inset-0 bg-black/50"></div>

                <div
                    className="relative w-1/2 max-h-[80vh] bg-white rounded-lg shadow-2xl p-6 overflow-y-auto"
                    onClick={e => e.stopPropagation()}
                >
                    <h2 className="text-center mb-4">Bid Resume</h2>
                    {isLoading || isBalanceLoading ? (
                        <div className="flex items-center justify-center min-h-[50vh]">
                            <div className="text-xl">Loading current auction...</div>
                        </div>
                    ) : (
                        <>
                            {/* Bid Details */}
                            <div className="mb-6 p-4 bg-gray-50 rounded-lg text-center">
                                <p className="text-lg mb-2">
                                    <span className="font-semibold">Your Bid:</span> {bidAmount} ETH
                                </p>
                                <p className="text-lg">
                                    <span className="font-semibold">Current Highest Bid:</span>{' '}
                                    {higherBid ? (Number(higherBid) / 1e18).toFixed(4) : '0'} ETH
                                </p>
                            </div>

                            {/* Status Checks */}
                            <div className="space-y-3 mb-6 px-12">
                                <BidStatusCheck
                                    isValid={!insufficientBalance}
                                    validMessage="Sufficient Balance"
                                    invalidMessage="Insufficient Balance"
                                    additionalInfo={`Your balance: ${
                                        balanceData ? (Number(balanceData.value) / 1e18).toFixed(4) : '0'
                                    } ETH`}
                                    delay={0}
                                />

                                <BidStatusCheck
                                    isValid={!alreadyHigherBidder}
                                    validMessage="Ready to bid"
                                    invalidMessage="You are already the highest bidder"
                                    icon={{ valid: '✅', invalid: '⚠️' }}
                                    delay={0.5}
                                />

                                <BidStatusCheck
                                    isValid={!hasUnclaimedTokens}
                                    validMessage="No unclaimed tokens"
                                    invalidMessage="You have unclaimed tokens"
                                    additionalInfo={
                                        hasUnclaimedTokens
                                            ? 'Please claim your tokens before placing a new bid'
                                            : undefined
                                    }
                                    icon={{ valid: '✅', invalid: '⚠️' }}
                                    delay={1}
                                />
                            </div>

                            {/* Action Buttons */}
                            <div className="flex justify-center gap-4">
                                <button
                                    onClick={() => dispatch(resetConfirmPlaceBid())}
                                    className="px-8 py-3 bg-white border-2 border-gray-300 text-gray-800 rounded-lg hover:bg-red-500 hover:text-white hover:border-red-500 transition-all duration-200"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={handleConfirmBid}
                                    disabled={!canConfirmBid || isWritePending || isConfirming}
                                    className={`px-8 py-3 rounded-lg transition-all duration-200 ${
                                        canConfirmBid && !isWritePending && !isConfirming
                                            ? 'bg-[#825FAA] text-white hover:bg-[rgb(90,160,130)] active:shadow-[inset_0_4px_8px_rgba(0,0,0,0.3)] cursor-pointer'
                                            : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                                    }`}
                                >
                                    {isWritePending ? (
                                        'Waiting for wallet...'
                                    ) : isConfirming ? (
                                        <span className="flex items-center gap-2">
                                            <span className="inline-block w-4 h-4 border-2 border-[#825FAA] border-t-transparent rounded-full animate-spin"></span>
                                            Confirming...
                                        </span>
                                    ) : (
                                        'Confirm Bid'
                                    )}
                                </button>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </>
    );
};

export default BidResume;
