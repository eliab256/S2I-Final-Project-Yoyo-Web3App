import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import useClaimNft from '../hooks/useClaimNft';

const ClaimFailedRefundButton: React.FC = () => {
    const dispatch = useDispatch();
    const { claimNft, isWritePending, isConfirming, isConfirmed, hash, error } = useClaimNft();
    return (
        <button
            onClick={claimNft}
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
    );
};

export default ClaimFailedRefundButton;
