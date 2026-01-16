import useClaimRefund from '../hooks/useClaimRefund';
import { useState } from 'react';
import SuccessBox from './SuccessBox';
import ErrorBox from './ErrorBox';
import WarningBox from './WarningBox';

const ClaimFailedRefundButton: React.FC = () => {
    const { claimRefund, isWritePending, isConfirming, isConfirmed, hash, error, hasUnclaimedRefund } =
        useClaimRefund();
    const [showNoClaimPopup, setShowNoClaimPopup] = useState(false);

    const handleClick = () => {
        if (!hasUnclaimedRefund) {
            setShowNoClaimPopup(true);
        } else {
            claimRefund();
        }
    };
    return (
        <>
            <button
                onClick={handleClick}
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

            {/* Success Box when transaction is confirmed */}
            {!isWritePending && !isConfirming && isConfirmed && hash && (
                <SuccessBox
                    title="Refund Claimed Successfully!"
                    message="Your refund has been successfully claimed on the blockchain."
                    txHash={hash}
                    onClose={() => window.location.reload()}
                />
            )}

            {/* Warning Box when there is an error */}
            {error && !isWritePending && !isConfirming && (
                <ErrorBox
                    title="Claim Refund Failed"
                    message={error.message}
                    onClose={() => window.location.reload()}
                />
            )}

            {/* Popup for no unclaimed refunds */}
            {showNoClaimPopup && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center"
                    onClick={() => setShowNoClaimPopup(false)}
                >
                    <WarningBox title="No Refunds Available" message="You don't have any unclaimed refunds at the moment." />
                    
                </div>
            )}
        </>
    );
};

export default ClaimFailedRefundButton;
