import NftCard from '../nft/NftCard';
import nftData from '../../data/nftCardData';
import type { NftData } from '../../types/nftTypes';
import { useSelector, useDispatch } from 'react-redux';
import { useEffect } from 'react';
import { type NftTokenId, setSelectedNft } from '../../redux/selectedNftSlice';
import NftDetails from '../nft/NftDetails';

const Gallery: React.FC = () => {
    const dispatch = useDispatch();
    const currentNftSelected = useSelector((state: { selectedNft: { id: NftTokenId } }) => state.selectedNft.id);
    const selectedNft: NftData | undefined = nftData.find(nft => nft.tokenId === currentNftSelected);

    useEffect(() => {
        if (currentNftSelected !== null) {
            document.body.classList.add('overflow-hidden');
        } else {
            document.body.classList.remove('overflow-hidden');
        }
        return () => {
            document.body.classList.remove('overflow-hidden');
        };
    }, [currentNftSelected]);

    return (
        <div className="flex flex-col items-center text-center w-full relative">
            <div className="flex items-center justify-center min-h-screen w-full px-2 sm:px-4 ">
                <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold">
                    Get your pass to the future of inner
                    <br></br>peace and mindful movement
                </h1>
            </div>

            <div className="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 px-4 pb-8 ">
                {nftData.map(nft => (
                    <NftCard key={nft.tokenId} {...nft} onClick={tokenId => dispatch(setSelectedNft(tokenId))} />
                ))}
            </div>

            {currentNftSelected !== null && selectedNft && (
                <div className="fixed inset-0 z-50 flex justify-center items-center">
                    <NftDetails {...selectedNft} />
                </div>
            )}
        </div>
    );
};

export default Gallery;
