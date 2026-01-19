//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DeployYoyoAuctionAndYoyoNft } from '../script/DeployYoyoAuctionAndYoyoNft.s.sol';
import { HelperConfig, CodeConstants } from '../script/HelperConfig.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { Test, console, Vm } from 'forge-std/Test.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';
import { LinkTokenInterface } from '@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol';

contract DeployYoyoAuctionAndYoyoNftTest is Test, CodeConstants {
    YoyoAuction public yoyoAuction;
    YoyoNft public yoyoNft;
    HelperConfig public helperConfig;
    LinkTokenInterface public linkToken;

    address public deployer;
    address public forwarder;
    uint256 public upkeepId;

    function testDeployContractsOnLocalEnv() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();

        console.log('YoyoAuction deployed at:', address(yoyoAuction));
        console.log('YoyoNft deployed at:', address(yoyoNft));

        assert(address(yoyoAuction) != address(0));
        assert(address(yoyoNft) != address(0));

        assertEq(yoyoAuction.owner(), ANVIL_DEPLOYER_ADDRESS);
        assertEq(yoyoNft.owner(), ANVIL_DEPLOYER_ADDRESS);
        assertEq(deployer, ANVIL_DEPLOYER_ADDRESS);

        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));

        assertEq(address(yoyoAuction.getChainlinkForwarderAddress()), forwarder);
        assertEq(address(yoyoAuction.getChainlinkForwarderAddress()), makeAddr('forwarderMock'));

        assertEq(helperConfig.getAutomationRegistry(), makeAddr('registryMock'));
        assertEq(helperConfig.getAutomationRegistrar(), makeAddr('registrarMock'));

        assertEq(yoyoNft.getBasicMintPrice(), ANVIL_BASIC_MINT_PRICE);
    }

    function testDeployContractsOnSepolia() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();
        linkToken = LinkTokenInterface(SEPOLIA_LINK_TOKEN);

        assert(address(yoyoAuction) != address(0));
        assert(address(yoyoNft) != address(0));

        assertEq(yoyoAuction.owner(), SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(yoyoNft.owner(), SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(deployer, SEPOLIA_DEPLOYER_ADDRESS);

        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));

        assertEq(address(yoyoAuction.getChainlinkForwarderAddress()), forwarder);

        assertEq(yoyoNft.getBasicMintPrice(), SEPOLIA_BASIC_MINT_PRICE);
    }

    function testDeployFailsWithInvalidNetwork() public {
        vm.createSelectFork('optimism');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();

        vm.expectRevert(HelperConfig.HelperConfig__InvalidChainId.selector);
        deployerScript.run();
    }

    function testDeployFailsWithInsufficientLinkBalance() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();

        // Simulate insufficient LINK balance by setting deployer's LINK balance to 0
        linkToken = LinkTokenInterface(SEPOLIA_LINK_TOKEN);
        vm.prank(SEPOLIA_DEPLOYER_ADDRESS);
        linkToken.transfer(address(0), linkToken.balanceOf(SEPOLIA_DEPLOYER_ADDRESS));

        vm.expectRevert(abi.encodeWithSelector(DeployYoyoAuctionAndYoyoNft.InsufficientLinkBalance.selector, SEPOLIA_FUNDING_AMOUNT, 0));
        deployerScript.run();
    }

    function testGetSepoliaConfig() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory sepoliaConfig = helperConfig.getSepoliaConfig();

        assertEq(sepoliaConfig.deployerAccount, SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(sepoliaConfig.automationRegistry, SEPOLIA_KEEPERS_REGISTRY);
        assertEq(sepoliaConfig.basicMintPrice, SEPOLIA_BASIC_MINT_PRICE);
        assert(bytes(sepoliaConfig.baseUri).length > 0);
    }

    function testGetAnvilConfigWithMockKeeperAlreadySet() public {
        helperConfig = new HelperConfig();
        address registryMockTest = makeAddr('registryMock');
        HelperConfig.NetworkConfig memory anvilConfig = helperConfig.getAnvilConfig();

        assertEq(anvilConfig.deployerAccount, ANVIL_DEPLOYER_ADDRESS);
        assertEq(anvilConfig.automationRegistry, registryMockTest);
        assertEq(anvilConfig.basicMintPrice, ANVIL_BASIC_MINT_PRICE);
        assert(bytes(anvilConfig.baseUri).length > 0);
    }

    function testGetAnvilConfigWithoutMockKeeperSet() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory anvilConfig = helperConfig.getAnvilConfig();

        assertEq(anvilConfig.deployerAccount, ANVIL_DEPLOYER_ADDRESS);
        assertEq(anvilConfig.automationRegistry, makeAddr('registryMock'));
        assertEq(anvilConfig.basicMintPrice, ANVIL_BASIC_MINT_PRICE);
        assert(bytes(anvilConfig.baseUri).length > 0);
    }

    function testGetConfigByChainId() public {
        helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory anvilConfig = helperConfig.getConfigByChainId(ANVIL_CHAIN_ID);
        assertEq(anvilConfig.basicMintPrice, ANVIL_BASIC_MINT_PRICE);

        HelperConfig.NetworkConfig memory sepoliaConfig = helperConfig.getConfigByChainId(SEPOLIA_CHAIN_ID);
        assertEq(sepoliaConfig.basicMintPrice, SEPOLIA_BASIC_MINT_PRICE);

        vm.expectRevert(HelperConfig.HelperConfig__InvalidChainId.selector);
        helperConfig.getConfigByChainId(9999);
    }

    function testGetConstructorParamsByChainId() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        // Test Anvil config

        (yoyoAuction, , , helperConfig, , ) = deployerScript.run();
        ConstructorParams memory anvilParams = helperConfig.getConstructorParamsByChainId(ANVIL_CHAIN_ID, address(0));
        assertEq(anvilParams.basicMintPrice, ANVIL_BASIC_MINT_PRICE);

        // Test Sepolia config
        vm.createSelectFork('sepolia');

        (yoyoAuction, , , helperConfig, , ) = deployerScript.run();
        ConstructorParams memory sepoliaParams = helperConfig.getConstructorParamsByChainId(
            SEPOLIA_CHAIN_ID,
            address(0)
        );
        assertEq(sepoliaParams.basicMintPrice, SEPOLIA_BASIC_MINT_PRICE);
    }

    function testGetKeeperRegistry() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();
        address keeperRegistryFromHelper = helperConfig.getAutomationRegistry();
        assertEq(keeperRegistryFromHelper, SEPOLIA_KEEPERS_REGISTRY);
    }

    function testGetKeeperRegistrar() public {
        vm.createSelectFork('sepolia');
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();
        address keeperRegistrarFromHelper = helperConfig.getAutomationRegistrar();
        assertEq(keeperRegistrarFromHelper, SEPOLIA_KEEPERS_REGISTRAR);
    }

    function testGetBasicMintPrice() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();
        uint256 basicMintPriceFromHelper = helperConfig.getConstructorParams(address(yoyoAuction)).basicMintPrice;
        uint256 basicMintPriceFromNft = yoyoNft.getBasicMintPrice();
        assertEq(basicMintPriceFromHelper, basicMintPriceFromNft);
    }

    function testGetDeployerAccount() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder) = deployerScript.run();
        address deployerFromHelper = helperConfig.getDeployerAccount();
        assertEq(deployerFromHelper, deployer);
    }

    function testConstructorSepolia() public {
        vm.chainId(SEPOLIA_CHAIN_ID);
        HelperConfig config = new HelperConfig();
        assertEq(config.getDeployerAccount(), SEPOLIA_DEPLOYER_ADDRESS);
        assertEq(config.getBasicMintPrice(), SEPOLIA_BASIC_MINT_PRICE);
        assertEq(config.getAutomationRegistry(), SEPOLIA_KEEPERS_REGISTRY);
    }

    function testConstructorAnvil() public {
        vm.chainId(ANVIL_CHAIN_ID);
        HelperConfig config = new HelperConfig();
        assertEq(config.getDeployerAccount(), ANVIL_DEPLOYER_ADDRESS);
        assertEq(config.getBasicMintPrice(), ANVIL_BASIC_MINT_PRICE);
        assertEq(config.getAutomationRegistry(), makeAddr('registryMock'));
        assertEq(config.getAutomationRegistrar(), makeAddr('registrarMock'));
    }
}
