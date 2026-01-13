import { useAccount } from 'wagmi';
import NftCard from './NftCard';
import useUserNFTs from '../hooks/useUserNFTs';
import WarningBox from './WarningBox';
import { useSelector } from 'react-redux';
import { type NftTokenId } from '../redux/selectedNftSlice';
import nftData from '../data/nftCardData';
import type { NftData } from '../types/nftTypes';
import NftDetails from './NftDetails';

const MyNfts: React.FC = () => {
    const { isConnected, address } = useAccount();
    const { data: nfts, isLoading, error } = useUserNFTs();

    const currentNftSelected = useSelector((state: { selectedNft: { id: NftTokenId } }) => state.selectedNft.id);
    const selectedNft: NftData | undefined = nftData.find(nft => nft.tokenId === currentNftSelected);

    // Extract tokenIds from nfts
    const tokenIds = nfts?.map(nft => nft.tokenId) ?? [];
    const hasNfts = tokenIds.length > 0;

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
                    <WarningBox title="Error loading NFTs" message={`${error}. Please try again later.`} />
                )}
                {/* wallet is connected but the user hasn't never bought a product */}
                {isConnected && address && !hasNfts && !isLoading && !error && (
                    <WarningBox
                        title="You don't hold any NFTs yet"
                        message="Go to the auction page and place a bid to win your first NFT."
                    />
                )}
                {/* wallet is connected and the user has bought products */}
                {isConnected && hasNfts && (
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 px-4 py-8">
                        {tokenIds.map(tokenId => (
                            <NftCard key={tokenId} tokenId={Number(tokenId)} />
                        ))}
                    </div>
                )}
            </div>

            {currentNftSelected !== null && <NftDetails {...selectedNft as NftData} />}
        </div>
    );
};

export default MyNfts;
