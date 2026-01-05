import React, { useState } from 'react';
import { chainsToContractAddress } from '../contracts/addresses';
//import { yoyoNftABI } from '../contracts/yoyoNftAbi';
import { useChainId, useAccount, useReadContract } from 'wagmi';

interface NftCardProps {
    tokenId: number;
}

const NftCard: React.FC<NftCardProps> = ({ tokenId }) => {
    const { address } = useAccount();
    const chainId = useChainId();
    const nftContractAddress = chainsToContractAddress[chainId].yoyoNftContractAddress;

    return (
        <div className={`bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-2xl`}>
            {/* {loading && (
                <div className="absolute inset-0 flex items-center justify-center bg-gray-100 z-10">
                    <div className="text-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-2 mx-auto"></div>
                        <span className="text-sm text-gray-500">Loading video...</span>
                    </div>
                </div>
            )}

            {error && (
                <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-gray-100 to-gray-200">
                    <div className="text-center">
                        <div className="text-4xl mb-2">🧘‍♀️</div>
                        <span className="text-gray-500 text-sm">Error: {error}</span>
                    </div>
                </div>
            )} */}
        </div>
    );
};

export default NftCard;
