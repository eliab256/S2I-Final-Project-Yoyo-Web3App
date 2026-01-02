import { type Address } from 'viem';

interface ContractsConfig {
    [chainId: number]: {
        yoyoNftContractAddress: Address;
        yoyoAuctionContractAddress: Address;
    };
}

export const chainsToContractAddress: ContractsConfig = {
    11155111: {
        //Sepolia
        yoyoNftContractAddress: '',
        yoyoAuctionContractAddress: '',
    },
};
