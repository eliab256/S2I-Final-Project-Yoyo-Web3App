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
        <div className="flex flex-col items-center text-center w-full lg:min-h-[calc(100vh-var(--headerAndFooterHeight)*2)]">
            <div className="m-0 p-0 px-2 sm:px-4">
                <h1 className="h-full">Get your pass to the future of inner peace and mindful movement</h1>
            </div>
            <div className="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 mt-4 sm:mt-6">
                {nftData.map(nft => (
                    <NftCard key={nft.tokenId} {...nft} />
                ))}
            </div>
        </div>
    );
};

export default Gallery;
