// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from 'forge-std/Script.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';
import { HelperConfig, CodeConstants } from './HelperConfig.sol';

contract DeployYoyoAuctionAndYoyoNft is Script, CodeConstants {
    function run() public returns (YoyoAuction, YoyoNft, address deployer, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        address keepersRegistry = helperConfig.getKeepersRegistry();
        deployer = helperConfig.getDeployerAccount();

        bool isNotAnvil = block.chainid != ANVIL_CHAIN_ID;

        vm.startBroadcast(deployer);

        // 1. Deploy YoyoAuction contract
        YoyoAuction yoyoAuction = new YoyoAuction(keepersRegistry);
        if (isNotAnvil) console.log('YoyoAuction deployed at:', address(yoyoAuction));

        // 2. Create constructor params
        ConstructorParams memory params = helperConfig.getConstructorParams(address(yoyoAuction));

        // 3. Deploy the NFT contract
        YoyoNft yoyoNft = new YoyoNft(params);
        if (isNotAnvil) console.log('YoyoNft deployed at:', address(yoyoNft));

        // 4. Set the YoyoNft contract address inside YoyoAuction
        yoyoAuction.setNftContract(address(yoyoNft));
        if (isNotAnvil) console.log('YoyoNft contract set in YoyoAuction at:', address(yoyoAuction.getNftContract()));

        vm.stopBroadcast();

        return (yoyoAuction, yoyoNft, deployer, helperConfig);
    }
}
