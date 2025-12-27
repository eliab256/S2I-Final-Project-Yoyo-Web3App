//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DeployYoyoAuctionAndYoyoNft } from '../script/DeployYoyoAuctionAndYoyoNft.s.sol';
import { HelperConfig, CodeConstants } from '../script/HelperConfig.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { Test, console, Vm } from 'forge-std/Test.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';

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

    function testGetMainnetConfig() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory mainnetConfig = helperConfig.getMainnetConfig();

        assertEq(mainnetConfig.deployerAccount, MAINNET_DEPLOYER_ADDRESS);
        assertEq(mainnetConfig.keepersRegistry, MAINNET_KEEPERS_REGISTRY);
        assertEq(mainnetConfig.basicMintPrice, MAINNET_BASIC_MINT_PRICE);
        assert(bytes(mainnetConfig.baseUri).length > 0);
    }

    function testGetSepoliaConfig() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory sepoliaConfig = helperConfig.getSepoliaConfig();

        assertEq(sepoliaConfig.deployerAccount, SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(sepoliaConfig.keepersRegistry, SEPOLIA_KEEPERS_REGISTRY);
        assertEq(sepoliaConfig.basicMintPrice, SEPOLIA_BASIC_MINT_PRICE);
        assert(bytes(sepoliaConfig.baseUri).length > 0);
    }

    function testGetAnvilConfigWithMockKeeperAlreadySet() public {
        helperConfig = new HelperConfig();
        address mockKeeper = makeAddr('keeperMock');
        HelperConfig.NetworkConfig memory anvilConfig = helperConfig.getAnvilConfig();

        assertEq(anvilConfig.deployerAccount, ANVIL_DEPLOYER_ADDRESS);
        assertEq(anvilConfig.keepersRegistry, mockKeeper);
        assertEq(anvilConfig.basicMintPrice, ANVIL_BASIC_MINT_PRICE);
        assert(bytes(anvilConfig.baseUri).length > 0);
    }

    function testGetAnvilConfigWithoutMockKeeperSet() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory anvilConfig = helperConfig.getAnvilConfig();

        assertEq(anvilConfig.deployerAccount, ANVIL_DEPLOYER_ADDRESS);
        assertEq(anvilConfig.keepersRegistry, makeAddr('keeperMock'));
        assertEq(anvilConfig.basicMintPrice, ANVIL_BASIC_MINT_PRICE);
        assert(bytes(anvilConfig.baseUri).length > 0);
    }

    function testGetConstructorParamsByChainId() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        // Test Anvil config

        (yoyoAuction, , , helperConfig) = deployerScript.run();
        ConstructorParams memory anvilParams = helperConfig.getConstructorParamsByChainId(ANVIL_CHAIN_ID, address(0));
        assertEq(anvilParams.basicMintPrice, ANVIL_BASIC_MINT_PRICE);

        // Test Sepolia config
        vm.createSelectFork('sepolia');

        (yoyoAuction, , , helperConfig) = deployerScript.run();
        ConstructorParams memory sepoliaParams = helperConfig.getConstructorParamsByChainId(
            SEPOLIA_CHAIN_ID,
            address(0)
        );
        assertEq(sepoliaParams.basicMintPrice, SEPOLIA_BASIC_MINT_PRICE);

        // Test Mainnet config
        vm.createSelectFork('mainnet');

        (yoyoAuction, , , helperConfig) = deployerScript.run();
        ConstructorParams memory mainnetParams = helperConfig.getConstructorParamsByChainId(
            MAINNET_CHAIN_ID,
            address(0)
        );
        assertEq(mainnetParams.basicMintPrice, MAINNET_BASIC_MINT_PRICE);
    }

    function testGetKeeperRegistry() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();
        address keeperRegistryFromHelper = helperConfig.getKeepersRegistry();
        address keeperRegistryFromAuction = address(yoyoAuction.i_registry());
        assertEq(keeperRegistryFromHelper, keeperRegistryFromAuction);
        assertEq(keeperRegistryFromHelper, SEPOLIA_KEEPERS_REGISTRY);
    }

    function testGetBasicMintPrice() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();
        uint256 basicMintPriceFromHelper = helperConfig.getConstructorParams(address(yoyoAuction)).basicMintPrice;
        uint256 basicMintPriceFromNft = yoyoNft.getBasicMintPrice();
        assertEq(basicMintPriceFromHelper, basicMintPriceFromNft);
    }

    function testGetDeployerAccount() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();
        address deployerFromHelper = helperConfig.getDeployerAccount();
        assertEq(deployerFromHelper, deployer);
    }
}
