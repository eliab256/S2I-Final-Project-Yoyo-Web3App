// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from 'forge-std/Script.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';
import { HelperConfig, CodeConstants } from './HelperConfig.sol';
import { IKeeperRegistryMaster } from '@chainlink/contracts/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol';

contract DeployYoyoAuctionAndYoyoNft is Script, CodeConstants {
    function run() public returns (YoyoAuction, YoyoNft, address deployer, HelperConfig, uint256 upkeepId) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getActiveNetworkConfig();
        deployer = config.deployerAccount;

        bool isNotAnvil = block.chainid != ANVIL_CHAIN_ID;

        vm.startBroadcast(deployer);

        // 1. Deploy YoyoAuction contract
        YoyoAuction yoyoAuction = new YoyoAuction();
        if (isNotAnvil) console.log('YoyoAuction deployed at:', address(yoyoAuction));

        // 2. Create constructor params
        ConstructorParams memory params = helperConfig.getConstructorParams(address(yoyoAuction));

        // 3. Deploy the NFT contract
        YoyoNft yoyoNft = new YoyoNft(params);
        if (isNotAnvil) console.log('YoyoNft deployed at:', address(yoyoNft));

        // 4. Set the YoyoNft contract address inside YoyoAuction
        yoyoAuction.setNftContract(address(yoyoNft));
        if (isNotAnvil) console.log('YoyoNft contract set in YoyoAuction at:', address(yoyoAuction.getNftContract()));

        // 5. If not Anvil, register the auction contract for Chainlink Automation
        if (isNotAnvil) {
            upkeepId = helperConfig.registerAutomation(address(yoyoAuction), 'YoyoAuctionAutomation', config);
        }

        // 6. Set the upkeep ID in the YoyoAuction contract to retreive forwarder address later
        yoyoAuction.setUpkeepId(upkeepId);

        address forwarder = IKeeperRegistryMaster(config.automationRegistry).getForwarder(upkeepId);
        console.log('Chainlink Forwarder address:', forwarder);
        vm.stopBroadcast();

        return (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId);
    }
}
