import { useAccount } from 'wagmi';
import NftCard from './NftCard';
import useUserNFTIds from '../hooks/useUserNFTs';

const MyNfts: React.FC = () => {
    const { isConnected, address } = useAccount();
    const { tokenIds, isLoading, error } = useUserNFTIds();

    const hasNfts = tokenIds && tokenIds.length > 0;

    return (
        <div className="w-full lg:min-h-[calc(100vh-var(--headerAndFooterHeight)*2)]">
            <div className="px-2 sm:px-4 text-center">
                <h1>My Nfts</h1>
            </div>
            <div>
                {/* wallet is not connected */}
                {!isConnected && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse ">
                        <div className="border-red-500 border-2 bg-white  rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">
                                Wallet not connected
                            </h2>
                            <p className="text-red-600">Please connect your wallet to view your products.</p>
                        </div>
                    </div>
                )}
                {/* loading state */}
                {isConnected && isLoading && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4">
                        <div className="bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4 mx-auto"></div>
                            <h2 className="text-xl md:text-2xl font-semibold text-gray-700 mb-2">
                                Loading your NFTs...
                            </h2>
                            <p className="text-gray-600">Please wait while we fetch your collection.</p>
                        </div>
                    </div>
                )}
                {/* error state */}
                {isConnected && error && !isLoading && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse">
                        <div className="border-red-500 border-2 bg-white rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">Error loading NFTs</h2>
                            <p className="text-red-600">Failed to fetch your NFTs. Please try again later.</p>
                        </div>
                    </div>
                )}
                {/* wallet is connected but the user hasn't never bought a product */}
                {isConnected && address && !hasNfts && !isLoading && !error && (
                    <div className="relative flex justify-center items-center min-h-[50vh] px-4 animate-pulse ">
                        <div className="border-red-500 border-2 bg-white  rounded-2xl shadow-lg p-6 w-full max-w-md text-center">
                            <h2 className="text-xl md:text-2xl font-semibold text-red-700 mb-2">
                                You don't hold any NFTs yet
                            </h2>
                            <p className="text-red-600">
                                Go to the auction page and place a bid to win your first NFT.
                            </p>
                        </div>
                    </div>
                )}
                {/* wallet is connected and the user has bought products */}
                {isConnected && hasNfts && (
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 px-4 py-8">
                        {/* {tokenIds.map(tokenId => (
                            <NftCard key={tokenId} tokenId={tokenId} />
                        ))} */}
                    </div>
                )}
            </div>
        </div>
    );
};

export default MyNfts;
