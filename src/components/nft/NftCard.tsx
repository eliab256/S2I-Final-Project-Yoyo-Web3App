import React from 'react';
import nftData from '../../data/nftCardData';

interface NftCardProps {
    tokenId: number;
    onClick?: (tokenId: number) => void;
}

const NftCard: React.FC<NftCardProps> = ({ tokenId, onClick }) => {
    const nft = nftData[tokenId];
    const { image, metadata } = nft || {};

    return (
        <div
            onClick={() => onClick?.(tokenId)}
            className="bg-white rounded-xl overflow-hidden transition-shadow duration-300 max-w-sm mx-auto"
            style={{ boxShadow: '0 10px 25px -5px rgba(130, 95, 170, 0.5), 0 8px 10px -6px rgba(130, 95, 170, 0.3)' }}
        >
            {/* Immagine NFT */}
            <div className="relative aspect-square">
                <img src={image} alt={metadata?.name || `NFT #${tokenId}`} className="w-full h-full object-cover" />
            </div>

            {/* Nome e Token ID */}
            <div className="p-2 text-center">
                <h2 className="text-2xl font-semibold text-gray-800 mb-1">{metadata?.name || 'Unknown NFT'}</h2>
                <p className="text-lg text-black-500">Token ID: {tokenId}</p>
            </div>
        </div>
    );
};

export default NftCard;
