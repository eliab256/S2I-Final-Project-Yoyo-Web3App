//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DeployYoyoAuctionAndYoyoNft } from '../script/DeployYoyoAuctionAndYoyoNft.s.sol';
import { HelperConfig, CodeConstants } from '../script/HelperConfig.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { Test, console } from 'forge-std/Test.sol';

contract DeployYoyoAuctionAndYoyoNftTest is Test, CodeConstants {
    YoyoAuction public yoyoAuction;
    YoyoNft public yoyoNft;
    HelperConfig public helperConfig;

    address public deployer;
    address public keeperMock;

    function testDeployContractsOnLocalEnv() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();

        console.log('YoyoAuction deployed at:', address(yoyoAuction));
        console.log('YoyoNft deployed at:', address(yoyoNft));

        assert(address(yoyoAuction) != address(0));
        assert(address(yoyoNft) != address(0));

        assertEq(yoyoAuction.owner(), ANVIL_DEPLOYER_ADDRESS);
        assertEq(yoyoNft.owner(), ANVIL_DEPLOYER_ADDRESS);
        assertEq(deployer, ANVIL_DEPLOYER_ADDRESS);

        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));

        assertEq(address(yoyoAuction.i_registry()), helperConfig.getKeepersRegistry());
        assert(address(yoyoAuction.i_registry()) != address(0));
        assert(address(yoyoAuction.i_registry()) != SEPOLIA_KEEPERS_REGISTRY);
        assert(address(yoyoAuction.i_registry()) != MAINNET_KEEPERS_REGISTRY);

        assertEq(yoyoNft.getBasicMintPrice(), ANVIL_BASIC_MINT_PRICE);
    }

    function testDeployContractsOnSepolia() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();

        console.log('YoyoAuction deployed at:', address(yoyoAuction));
        console.log('YoyoNft deployed at:', address(yoyoNft));

        assert(address(yoyoAuction) != address(0));
        assert(address(yoyoNft) != address(0));

        assertEq(yoyoAuction.owner(), SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(yoyoNft.owner(), SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(deployer, SEPOLIA_DEPLOYER_ADDRESS);

        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));

        assertEq(address(yoyoAuction.i_registry()), helperConfig.getKeepersRegistry());
        assert(address(yoyoAuction.i_registry()) != address(0));
        assert(address(yoyoAuction.i_registry()) == SEPOLIA_KEEPERS_REGISTRY);
        assert(address(yoyoAuction.i_registry()) != MAINNET_KEEPERS_REGISTRY);

        assertEq(yoyoNft.getBasicMintPrice(), SEPOLIA_BASIC_MINT_PRICE);
    }

    function testDeployContractsOnMainnet() public {
        vm.createSelectFork('mainnet');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();

        console.log('YoyoAuction deployed at:', address(yoyoAuction));
        console.log('YoyoNft deployed at:', address(yoyoNft));

        assert(address(yoyoAuction) != address(0));
        assert(address(yoyoNft) != address(0));

        assertEq(yoyoAuction.owner(), MAINNET_DEPLOYER_ADDRESS);
        assertEq(yoyoNft.owner(), MAINNET_DEPLOYER_ADDRESS);
        assertEq(deployer, MAINNET_DEPLOYER_ADDRESS);

        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));

        assertEq(address(yoyoAuction.i_registry()), helperConfig.getKeepersRegistry());
        assert(address(yoyoAuction.i_registry()) != address(0));
        assert(address(yoyoAuction.i_registry()) != SEPOLIA_KEEPERS_REGISTRY);
        assert(address(yoyoAuction.i_registry()) == MAINNET_KEEPERS_REGISTRY);

        assertEq(yoyoNft.getBasicMintPrice(), MAINNET_BASIC_MINT_PRICE);
    }

    function testDeployFailsWithInvalidNetwork() public {
        vm.createSelectFork('optimism');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();

        vm.expectRevert(HelperConfig.HelperConfig__InvalidChainId.selector);
        deployerScript.run();
    }
}

//vm.createSelectFork("Sepolia", numBloc); aggiungere le reti al toml
