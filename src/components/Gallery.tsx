import NftCard from './NftCard';
import nftData from '../data/nftCardData';
// import { useSelector } from 'react-redux';
// import { type NftTokenId } from '../redux/selectedNftSlice';
// import type { FilterType, SortType, SortOrder } from '../types/filterTypes';
// import { useChainId, useReadContract } from 'wagmi';
// import { yoyoNftAbi, chainsToContractAddress } from '../data/smartContractsData';

const Gallery: React.FC = () => {
    // const currentNftSelected = useSelector(
    //     (state: { selectedExercise: { id: NftTokenId } }) => state.selectedExercise.id
    // );
    //const selectedNft = exercisesCardData.find(ex => ex.id === currentNftSelected);

    //const { nfts, loading, error, progress, refetch, totalMinted, maxSupply } = useNftCollection();

    return (
        <div className="flex flex-col items-center text-center w-full">
            <div className="flex items-center justify-center min-h-screen w-full px-2 sm:px-4 ">
                <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold">
                    Get your pass to the future of inner
                    <br></br>peace and mindful movement
                </h1>
            </div>

            <div className="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 px-4 pb-8 ">
                {nftData.map(nft => (
                    <NftCard key={nft.tokenId} {...nft} />
                ))}
            </div>
        </div>
    );
};

export default Gallery;
