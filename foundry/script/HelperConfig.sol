// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from 'forge-std/Script.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';
import { AutomationRegistration } from './AutomationRegistration.sol';
import { LinkTokenInterface } from '@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol';
import {
    IKeeperRegistryMaster
} from '@chainlink/contracts/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol';

/**
 * @title CodeConstants
 * @notice Contains chain-specific configuration constants
 */
abstract contract CodeConstants {
    // Chain IDs
    //uint256 public constant MAINNET_CHAIN_ID = 1;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ANVIL_CHAIN_ID = 31337;

    // Chainlink Automation Registry addresses
    //address public constant MAINNET_KEEPERS_REGISTRY = 0x6593c7De001fC8542bB1703532EE1E5aA0D458fD;
    address public constant SEPOLIA_KEEPERS_REGISTRY = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;

    //Chainlink Automation Registrar address
    //address public constant MAINNET_KEEPERS_REGISTRAR = 0x6B0B234fB2f380309D47A7E9391E29E9a179395a;
    address public constant SEPOLIA_KEEPERS_REGISTRAR = 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976;

    //LINK Token addresses
    //address public constant MAINNET_LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address public constant SEPOLIA_LINK_TOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    //Gas Limits
    uint32 public constant SEPOLIA_GAS_LIMIT = 2_000_000;
    uint32 public constant ANVIL_GAS_LIMIT = 2_000_000;

    //FundingAmounts
    uint96 public constant MAINNET_FUNDING_AMOUNT = 0 ether; // 0 LINK
    uint96 public constant SEPOLIA_FUNDING_AMOUNT = 50 ether; // 50 LINK
    uint96 public constant ANVIL_FUNDING_AMOUNT = 0 ether; // 0 LINK

    //UpkeepName
    string public constant UPKEEP_NAME = 'YoyoAuctionAutomation';

    // NFT Configuration
    //uint256 public constant MAINNET_BASIC_MINT_PRICE = 0.01 ether;
    uint256 public constant SEPOLIA_BASIC_MINT_PRICE = 0.01 ether;
    uint256 public constant ANVIL_BASIC_MINT_PRICE = 0.0001 ether;

    // Deployer Accounts
    //address public constant MAINNET_DEPLOYER_ADDRESS = 0xB7bC9D74681eB832902d1B7464F695F6F9546de7;
    address public constant SEPOLIA_DEPLOYER_ADDRESS = 0xB7bC9D74681eB832902d1B7464F695F6F9546de7;
    address public constant ANVIL_DEPLOYER_ADDRESS = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
}

/**
 * @title HelperConfig
 * @notice Manages chain-specific configuration
 * @dev Returns appropriate config based on current chain
 */
contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();
    error HelperConfig__InsufficientLinkBalance(uint256 required, uint256 available);

    struct NetworkConfig {
        address automationRegistry;
        address automationRegistrar;
        address linkToken;
        uint32 gasLimit;
        uint96 fundingAmount;
        uint256 basicMintPrice;
        string baseUri;
        address deployerAccount;
    }

    NetworkConfig public activeNetworkConfig;
    address public registryMock;
    address public registrarMock;
    address public forwarderMock;
    address public linkTokenMock;

    /**
     * @notice Initializes HelperConfig and sets active network configuration based on current chain
     * @dev Automatically detects chain ID and loads appropriate configuration
     * @dev Reverts with HelperConfig__InvalidChainId if chain is not supported
     */
    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == ANVIL_CHAIN_ID) {
            activeNetworkConfig = getAnvilConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    /**
     * @notice Returns network configuration for Sepolia testnet
     * @dev Reads BASE_URI from environment variables
     * @dev Uses lower mint price suitable for testnet
     * @return NetworkConfig Configuration struct with Sepolia testnet parameters
     */
    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                automationRegistry: SEPOLIA_KEEPERS_REGISTRY,
                automationRegistrar: SEPOLIA_KEEPERS_REGISTRAR,
                linkToken: SEPOLIA_LINK_TOKEN,
                gasLimit: SEPOLIA_GAS_LIMIT,
                fundingAmount: SEPOLIA_FUNDING_AMOUNT,
                basicMintPrice: SEPOLIA_BASIC_MINT_PRICE,
                baseUri: vm.envString('BASE_URI'),
                deployerAccount: SEPOLIA_DEPLOYER_ADDRESS
            });
    }

    /**
     * @notice Returns network configuration for Anvil local network
     * @dev Uses fallback BASE_URI if environment variable is not set
     * @dev Keepers registry is set to anvil account to simulate Chainlink functionality
     * @dev Uses very low mint price suitable for local development
     * @return NetworkConfig Configuration struct with Anvil local network parameters
     */
    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (forwarderMock != address(0)) {
            return
                NetworkConfig({
                    automationRegistry: registryMock,
                    automationRegistrar: registrarMock,
                    linkToken: address(0),
                    gasLimit: 2_000_000,
                    fundingAmount: 0,
                    basicMintPrice: ANVIL_BASIC_MINT_PRICE,
                    baseUri: vm.envString('BASE_URI'),
                    deployerAccount: ANVIL_DEPLOYER_ADDRESS
                });
        }

        forwarderMock = makeAddr('forwarderMock');
        registryMock = makeAddr('registryMock');
        registrarMock = makeAddr('registrarMock');

        return
            NetworkConfig({
                automationRegistry: registryMock,
                automationRegistrar: registrarMock,
                linkToken: linkTokenMock,
                gasLimit: ANVIL_GAS_LIMIT,
                fundingAmount: ANVIL_FUNDING_AMOUNT,
                basicMintPrice: ANVIL_BASIC_MINT_PRICE,
                baseUri: vm.envString('BASE_URI'),
                deployerAccount: ANVIL_DEPLOYER_ADDRESS
            });
    }

    /**
     * @notice Returns network configuration for a specific chain ID
     * @dev Allows retrieving configuration for chains other than the current one
     * @dev Useful for testing deployment on multiple chains
     * @param chainId The chain ID to get configuration for
     * @return NetworkConfig Configuration struct for the specified chain
     * @custom:throws HelperConfig__InvalidChainId if chainId is not supported
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == SEPOLIA_CHAIN_ID) {
            return getSepoliaConfig();
        } else if (chainId == ANVIL_CHAIN_ID) {
            return getAnvilConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /**
     * @notice Builds complete ConstructorParams for YoyoNft deployment on current chain
     * @dev Uses activeNetworkConfig to build parameters automatically
     * @dev This is the primary function to use during deployment scripts
     * @param auctionContractAddress Address of the deployed YoyoAuction contract
     * @return ConstructorParams Complete constructor parameters ready for YoyoNft deployment
     */
    function getConstructorParams(address auctionContractAddress) public view returns (ConstructorParams memory) {
        return
            ConstructorParams({
                baseURI: activeNetworkConfig.baseUri,
                auctionContract: auctionContractAddress,
                basicMintPrice: activeNetworkConfig.basicMintPrice
            });
    }

    /**
     * @notice Builds ConstructorParams for a specific chain
     * @param chainId Chain ID to get config for
     * @param auctionContractAddress Address of the deployed YoyoAuction contract
     * @return ConstructorParams Complete constructor parameters for YoyoNft
     */
    function getConstructorParamsByChainId(
        uint256 chainId,
        address auctionContractAddress
    ) public returns (ConstructorParams memory) {
        NetworkConfig memory config = getConfigByChainId(chainId);

        return
            ConstructorParams({
                baseURI: config.baseUri,
                auctionContract: auctionContractAddress,
                basicMintPrice: config.basicMintPrice
            });
    }

    /**
     * @notice Register upkeep on Chainlink Automation
     * @dev Handles the entire registration process
     * @dev It use the activeNetworkConfig parameters
     * @param _upkeepContract Address of the contract to automate
     * @param _name Name of the upkeep
     * @return upkeepId ID of the registered upkeep
     */
    function registerAutomation(address _upkeepContract, string memory _name) public returns (uint256 upkeepId) {
        console.log('');
        console.log('==================== Registering Chainlink Automation ====================');
        console.log('Registering Chainlink Automation...');
        console.log('Upkeep Contract:', _upkeepContract);
        console.log('Admin:', activeNetworkConfig.deployerAccount);
        console.log(
            'Admin Link Balance: ',
            LinkTokenInterface(activeNetworkConfig.linkToken).balanceOf(activeNetworkConfig.deployerAccount) / 1e18,
            ' LINK'
        );
        console.log('Funding Amount:', activeNetworkConfig.fundingAmount / 1e18, 'LINK');

        // 1. Deploy AutomationRegistration helper
        AutomationRegistration registration = new AutomationRegistration(
            activeNetworkConfig.linkToken,
            activeNetworkConfig.automationRegistrar
        );
        console.log('AutomationRegistration deployed at:', address(registration));

        // 2. Check LINK balance
        LinkTokenInterface link = LinkTokenInterface(activeNetworkConfig.linkToken);
        uint256 linkBalance = link.balanceOf(activeNetworkConfig.deployerAccount);

        if (linkBalance < activeNetworkConfig.fundingAmount) {
            revert HelperConfig__InsufficientLinkBalance(activeNetworkConfig.fundingAmount, linkBalance);
        }

        // 3. Transfer LINK to the registration contract
        link.approve(address(registration), activeNetworkConfig.fundingAmount);
        console.log('Transferred', activeNetworkConfig.fundingAmount / 1e18, 'LINK to registration contract');
        console.log('==========================================================================');
        console.log('');

        // 4. Register the upkeep
        upkeepId = registration.registerAndFundUpkeep(
            _upkeepContract,
            _name,
            activeNetworkConfig.gasLimit,
            activeNetworkConfig.deployerAccount,
            activeNetworkConfig.fundingAmount
        );

        return upkeepId;
    }

    /**
     */

    function getForwarderFromUpkeepId(uint256 _upkeepId) public view returns (address) {
        if (block.chainid != ANVIL_CHAIN_ID) {
            IKeeperRegistryMaster registry = IKeeperRegistryMaster(activeNetworkConfig.automationRegistry);
            return registry.getForwarder(_upkeepId);
        } else {
            return forwarderMock;
        }
    }

    /**
     * @notice Returns the Chainlink Automation Registrar address for current chain
     * @dev Returns address(0) for chains without Chainlink Automation support (like Anvil)
     * @return address Chainlink Automation Registrar address
     */
    function getAutomationRegistrar() public view returns (address) {
        if (block.chainid != ANVIL_CHAIN_ID) {
            return activeNetworkConfig.automationRegistrar;
        } else {
            return registrarMock;
        }
    }

    /**
     * @notice Returns the Chainlink Automation Registry address for current chain
     * @dev Returns address(0) for chains without Chainlink Automation support (like Anvil)
     * @return address Chainlink Automation Registry address
     */
    function getAutomationRegistry() public view returns (address) {
        if (block.chainid != ANVIL_CHAIN_ID) {
            return activeNetworkConfig.automationRegistry;
        } else {
            return registryMock;
        }
    }

    /**
     * @notice Returns the basic mint price for current chain
     * @dev Price varies by network (higher on mainnet, lower on testnets)
     * @return uint256 Basic mint price in wei
     */
    function getBasicMintPrice() public view returns (uint256) {
        return activeNetworkConfig.basicMintPrice;
    }

    /**
     * @notice Returns the deployer account address for current chain
     * @dev Used to sign deployment transactions
     * @return address Deployer account address
     */
    function getDeployerAccount() public view returns (address) {
        return activeNetworkConfig.deployerAccount;
    }
}
