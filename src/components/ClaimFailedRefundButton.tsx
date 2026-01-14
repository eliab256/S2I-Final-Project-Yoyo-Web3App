import useClaimRefund from '../hooks/useClaimRefund';
import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { setTxConfirmed, setError } from '../redux/confirmAndErrorManagerSlice';


const ClaimFailedRefundButton: React.FC = () => {
    const dispatch = useDispatch();
    const { claimRefund, isWritePending, isConfirming, isConfirmed, hash, error, hasUnclaimedRefund } =
        useClaimRefund();

         // When the transaction is confirmed, send the confirmation to Redux
    useEffect(() => {
        if (isConfirmed && hash) {
            dispatch(setTxConfirmed({ 
                title: 'Refund Claimed Successfully!',
                hash: hash 
            }));
        }
    }, [isConfirmed, hash, dispatch]);

    // When there is an error, send the error message to Redux
    useEffect(() => {
        if (error) {
            dispatch(setError({ 
                title: 'Claim Refund Failed',
                error: error.message 
            }));
        }
    }, [error, dispatch]);

    return (
        <button
            onClick={claimRefund}
            disabled={isWritePending || isConfirming}
            className={`px-8 py-3 rounded-lg transition-all duration-200 ${
                !isWritePending && !isConfirming
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
                'Claim Refund'
            )}
        </button>
    );

   
};

export default ClaimFailedRefundButton;
