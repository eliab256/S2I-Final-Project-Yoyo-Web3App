import { clearSelectedNft } from '../../redux/selectedNftSlice';
import { XMarkIcon } from '@heroicons/react/24/solid';
import { useDispatch, useSelector } from 'react-redux';
import type { NftData } from '../../types/nftTypes';
import useTransferNft from '../../hooks/useTransferNft';
import { useState } from 'react';
import type { Address } from 'viem';
import { isAddress } from 'viem';
import { useAccount } from 'wagmi';
import SuccessBox from '../ui/SuccessBox';
import ErrorBox from '../ui/ErrorBox';
import { selectCurrentPage } from '../../redux/pagesSlice';

/**
 * Use MyNfts page selector to conditionally render Transfer button, if is not on MyNfts page hide it
 *
 */

const NftDetails: React.FC<NftData> = ({ tokenId, metadata, image }) => {
    const dispatch = useDispatch();
    const currentPage = useSelector(selectCurrentPage);
    const { address: userAddress } = useAccount();
    const [recipientAddress, setRecipientAddress] = useState<string>('');
    const [showTransferPopup, setShowTransferPopup] = useState(false);
    // Metadata deconstruction
    const { name, description, attributes, properties } = metadata;

    // Properties deconstruction
    const { category, course_type, accessibility_level, redeemable, instructor_certified, style } = properties;

    const { transferNft, isWritePending, isConfirming, isConfirmed, hash, error } = useTransferNft(tokenId);

    const handleTransfer = () => {
        if (!isAddress(recipientAddress) || recipientAddress === userAddress) {
            return;
        }
        setShowTransferPopup(false);
        transferNft(recipientAddress as Address);
    };

    const handleAddressChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setRecipientAddress(e.target.value);
    };

    return (
        <div
            className="relative flex flex-col items-center rounded-xl bg-white/95 backdrop-blur-sm
            p-2 sm:p-3 md:p-4 lg:p-10 w-[95%] sm:w-[90%] md:w-4/5 lg:w-1/2 mx-auto my-3 sm:my-4 md:my-5 lg:my-6
            border border-gray-300 shadow-lg min-h-[calc(100vh-48px)] max-h-[100vh] overflow-y-auto cursor-default"
        >
            {/* Close Button */}
            <div
                className="absolute top-3 right-3 bg-red-500 rounded-full active:scale-95 active:bg-red-600 
                transition-transform duration-150 shadow-md cursor-pointer p-2"
                onClick={() => dispatch(clearSelectedNft())}
            >
                <XMarkIcon className="h-4 w-4 text-white" />
            </div>
            {/* Title and Token ID */}
            <div className="flex flex-col items-center w-full mb-2">
                <h2 className="text-xl sm:text-2xl md:text-3xl lg:text-4xl font-bold text-center">{name}</h2>
                <p className="text-xs sm:text-sm text-gray-500 mt-1">Token ID: #{tokenId}</p>
            </div>

            {/* Image */}
            <div className="flex flex-col items-center w-full mb-3 pt-2">
                <img
                    src={image}
                    alt={name}
                    className="w-full max-w-[120px] sm:max-w-[150px] md:max-w-[180px] lg:max-w-[160px] xl:max-w-[200px] h-auto object-cover rounded-md"
                />
            </div>

            {/* Description */}
            <div className="flex flex-col items-center w-full mb-4 px-4 sm:px-6 md:px-8 text-sm sm:text-lg md:text-xl">
                <p className="text-gray-600 text-justify">{description}</p>
            </div>

            {/* Properties Section */}
            <div className="w-full px-4 sm:px-6 md:px-8 mb-4">
                <h3 className="text-lg sm:text-xl md:text-2xl font-bold mb-3 text-gray-800">Course Properties</h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                    {/* Category */}
                    <div className="bg-blue-50 rounded-lg p-3 border border-blue-200">
                        <p className="text-base text-blue-600 font-semibold mb-1">Category</p>
                        <p className="text-lg sm:text-xl text-blue-900 font-medium">{category}</p>
                    </div>

                    {/* Course Type */}
                    <div className="bg-green-50 rounded-lg p-3 border border-green-200">
                        <p className="text-base text-green-600 font-semibold mb-1">Course Type</p>
                        <p className="text-lg sm:text-xl text-green-900 font-medium">{course_type}</p>
                    </div>

                    {/* Accessibility Level */}
                    <div className="bg-yellow-50 rounded-lg p-3 border border-yellow-200">
                        <p className="text-base text-yellow-600 font-semibold mb-1">Accessibility Level</p>
                        <p className="text-lg sm:text-xl text-yellow-900 font-medium">{accessibility_level}</p>
                    </div>

                    {/* Style */}
                    <div className="bg-pink-50 rounded-lg p-3 border border-pink-200">
                        <p className="text-base text-pink-600 font-semibold mb-1">Style</p>
                        <p className="text-lg sm:text-xl text-pink-900 font-medium">{style}</p>
                    </div>

                    {/* Redeemable */}
                    <div className="bg-purple-50 rounded-lg p-3 border border-purple-200">
                        <p className="text-base text-purple-600 font-semibold mb-1">Redeemable</p>
                        <p className="text-lg sm:text-xl text-purple-900 font-medium">{redeemable ? 'Yes' : 'No'}</p>
                    </div>

                    {/* Instructor Certified */}
                    <div className="bg-indigo-50 rounded-lg p-3 border border-indigo-200">
                        <p className="text-base text-indigo-600 font-semibold mb-1">Instructor Certified</p>
                        <p className="text-lg sm:text-xl text-indigo-900 font-medium">
                            {instructor_certified ? 'Yes' : 'No'}
                        </p>
                    </div>
                </div>
            </div>

            {/* Attributes Section */}
            <div className="w-full px-4 sm:px-6 md:px-8 mb-4">
                <h3 className="text-lg sm:text-xl md:text-2xl font-bold mb-3 text-gray-800">Attributes</h3>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                    {attributes.map((attr, index) => (
                        <div
                            key={index}
                            className="bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg p-3 border border-gray-200 hover:shadow-md transition-shadow"
                        >
                            <p className="text-xs text-gray-500 font-semibold mb-1 truncate" title={attr.trait_type}>
                                {attr.trait_type}
                            </p>
                            <p
                                className="text-sm sm:text-base text-gray-900 font-bold truncate"
                                title={String(attr.value)}
                            >
                                {attr.value}
                            </p>
                        </div>
                    ))}
                </div>
            </div>
            {/* Transfer Button */}
            {currentPage === 'myNfts' && (
                <button
                    onClick={() => setShowTransferPopup(true)}
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
                        'Transfer your NFT'
                    )}
                </button>
            )}

            {/* Transfer Popup */}
            {showTransferPopup && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
                    onClick={() => setShowTransferPopup(false)}
                >
                    <div
                        className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md"
                        onClick={e => e.stopPropagation()}
                    >
                        <h3 className="text-2xl font-bold text-gray-800 mb-4">Transfer NFT</h3>
                        <p className="text-gray-600 mb-6">Enter the recipient's address to transfer this NFT.</p>

                        <label className="block text-sm font-medium text-gray-700 mb-2">Recipient Address</label>
                        <input
                            type="text"
                            value={recipientAddress}
                            onChange={handleAddressChange}
                            placeholder="0x....."
                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#825FAA] mb-6"
                        />

                        <div className="flex gap-3">
                            <button
                                onClick={() => {
                                    setShowTransferPopup(false);
                                    setRecipientAddress('');
                                }}
                                className="flex-1 px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors cursor-pointer"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleTransfer}
                                disabled={!isAddress(recipientAddress)}
                                className={`flex-1 px-6 py-3 rounded-lg transition-all duration-200 ${
                                    isAddress(recipientAddress)
                                        ? 'bg-[#825FAA] text-white hover:bg-[rgb(90,160,130)] cursor-pointer'
                                        : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                                }`}
                            >
                                Confirm Transfer
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Success Box when transaction is confirmed */}
            {!isWritePending && !isConfirming && isConfirmed && hash && (
                <SuccessBox
                    title="NFT Transferred Successfully!"
                    message="Your NFT has been successfully transferred on the blockchain."
                    txHash={hash}
                    onClose={() => window.location.reload()}
                />
            )}

            {/* Warning Box when there is an error */}
            {error && !isWritePending && !isConfirming && (
                <ErrorBox
                    title="Transfer NFT Failed"
                    message={error.message}
                    onClose={() => window.location.reload()}
                />
            )}
        </div>
    );
};
export default NftDetails;
