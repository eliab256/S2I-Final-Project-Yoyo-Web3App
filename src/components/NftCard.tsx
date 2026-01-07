import React from 'react';
import type { NftData } from '../types/nftTypes';

const NftCard: React.FC<NftData> = ({ tokenId, image, metadata }) => {
    return (
        <div className="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-2xl transition-shadow duration-300">
            {/* Immagine NFT */}
            <div className="relative aspect-square">
                <img src={image} alt={metadata?.name || `NFT #${tokenId}`} className="w-full h-full object-cover" />
            </div>

            {/* Nome e Token ID */}
            <div className="p-4">
                <h3 className="text-lg font-semibold text-gray-800 mb-2">{metadata?.name || 'Unknown NFT'}</h3>
                <p className="text-sm text-gray-500">Token ID: {tokenId}</p>
            </div>
        </div>
    );
};

export default NftCard;
