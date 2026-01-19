import { type Address } from 'viem';

interface ContractsConfig {
    [chainId: number]: {
        yoyoNftAddress: Address;
        yoyoAuctionAddress: Address;
    };
}

export const chainsToContractAddress: ContractsConfig = {
    11155111: {
        //Sepolia
        yoyoNftAddress: '0xbf993f5eE3b657Ce8Def22D14fE2733C9e37Bbd5',
        yoyoAuctionAddress: '0xFC188F25EE67D68BC61C74714DAA431d0719D1fe',
    },
};
