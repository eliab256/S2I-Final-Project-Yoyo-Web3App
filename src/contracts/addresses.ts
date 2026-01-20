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

    //old auction
    //0x51eaAa1a6b1cF652B58da67cB32a0f7999263619
    //old nft
    //0x81a9B713128A4DF3349D9Bc363CEE1D77accDCA3

    //new auction
    //0xFC188F25EE67D68BC61C74714DAA431d0719D1fe
    //new nft
    //0xbf993f5eE3b657Ce8Def22D14fE2733C9e37Bbd5
};
