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
        yoyoNftContractAddress: '0x81a9B713128A4DF3349D9Bc363CEE1D77accDCA3',
        yoyoAuctionContractAddress: '0x51eaAa1a6b1cF652B58da67cB32a0f7999263619',
    },
};
