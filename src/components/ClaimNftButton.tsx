import { useEffect, useState } from 'react';
import useClaimNft from '../hooks/useClaimNft';
import SuccessBox from './SuccessBox';
import ErrorBox from './ErrorBox';
import WarningBox from './WarningBox';

const ClaimNftButton: React.FC = () => {
    const { claimNft, isWritePending, isConfirming, isConfirmed, hash, error, unclaimedNftId } = useClaimNft();
    const [showNoClaimPopup, setShowNoClaimPopup] = useState(false);

    const handleClick = () => {
        if (unclaimedNftId === null) {
            setShowNoClaimPopup(true);
        } else {
            claimNft();
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
                    'Claim NFT'
                )}
            </button>

            {/* Success Box when transaction is confirmed */}
            {!isWritePending && !isConfirming && isConfirmed && hash && (
                <SuccessBox
                    title="NFT Claimed Successfully!"
                    message="Your NFT token has been successfully claimed on the blockchain."
                    txHash={hash}
                    onClose={() => window.location.reload()}
                />
            )}

            {/* Warning Box when there is an error */}
            {error && !isWritePending && !isConfirming && (
                <ErrorBox title="Claim NFT Failed" message={error.message} onClose={() => window.location.reload()} />
            )}

            {/* Popup for no unclaimed NFTs */}
            {showNoClaimPopup && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center"
                    onClick={() => setShowNoClaimPopup(false)}
                >
                    <WarningBox title="No NFTs Available" message="You don't have any unclaimed NFTs at the moment." />
                </div>
            )}
        </>
    );
};

export default ClaimNftButton;
