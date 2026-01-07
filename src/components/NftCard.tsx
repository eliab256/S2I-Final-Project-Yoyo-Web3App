import React from 'react';
import nftData from '../data/nftCardData';

interface NftCardProps {
    tokenId: number;
}

const NftCard: React.FC<NftCardProps> = ({ tokenId }) => {
    const nft = nftData[tokenId];
    const { image, metadata } = nft || {};

    return (
        <div className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-2xl transition-shadow duration-300 max-w-sm mx-auto">
            {/* Immagine NFT */}
            <div className="relative aspect-square">
                <img src={image} alt={metadata?.name || `NFT #${tokenId}`} className="w-full h-full object-cover" />
            </div>

            {/* Nome e Token ID */}
            <div className="p-2 text-center">
                <h3 className="text-3xl font-semibold text-gray-800 mb-2">{metadata?.name || 'Unknown NFT'}</h3>
                <p className="text-2xl text-gray-500">Token ID: {tokenId}</p>
            </div>
        </div>
    );
};

export default NftCard;
