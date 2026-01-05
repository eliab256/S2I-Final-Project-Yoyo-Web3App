import type { NftData } from '../types/nftTypes';
import images from './nftCardImgs';
import nftMetadata from './nftCardMetadata';

const nftData: NftData[] = nftMetadata.map((nft, index) => ({
    ...nft,
    tokenId: index,
    image: images[index],
}));

export default nftData;