// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script, console } from 'forge-std/Script.sol';
import { YoyoAuction } from '../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../src/YoyoNft/YoyoNft.sol';
import { ConstructorParams } from '../src/YoyoTypes.sol';
import { HelperConfig, CodeConstants } from './HelperConfig.sol';
import {
    IKeeperRegistryMaster
} from '@chainlink/contracts/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol';
import { AutomationRegistration } from './AutomationRegistration.sol';
import { LinkTokenInterface } from '@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol';

contract DeployYoyoAuctionAndYoyoNft is Script, CodeConstants {
    error InsufficientLinkBalance(uint256 required, uint256 available);
    function run()
        public
        returns (YoyoAuction, YoyoNft, address deployer, HelperConfig, uint256 upkeepId, address forwarder)
    {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getActiveNetworkConfig();
        deployer = config.deployerAccount;

        bool isNotAnvil = block.chainid != ANVIL_CHAIN_ID;

        vm.startBroadcast(deployer);

        console.log('======================= Contracts Deployment =================');
        // 1. Deploy YoyoAuction contract
        YoyoAuction yoyoAuction = new YoyoAuction();
        if (isNotAnvil) console.log('YoyoAuction deployed at:', address(yoyoAuction));

        // 2. Create constructor params
        ConstructorParams memory params = helperConfig.getConstructorParams(address(yoyoAuction));

        // 3. Deploy the NFT contract
        YoyoNft yoyoNft = new YoyoNft(params);
        if (isNotAnvil) console.log('YoyoNft deployed at:', address(yoyoNft));
        console.log('==============================================================');
        console.log('');

        console.log('======================== Contracts Settings ==================');
        // 4. Set the YoyoNft contract address inside YoyoAuction
        yoyoAuction.setNftContract(address(yoyoNft));
        if (isNotAnvil) console.log('YoyoNft contract set in YoyoAuction at:', address(yoyoAuction.getNftContract()));

        // 5. If not Anvil, register the auction contract for Chainlink Automation
        if (isNotAnvil) {
            upkeepId = registerAutomation(address(yoyoAuction), 'YoyoAuctionAutomation', config);
        }

        // 6. Set the upkeep ID in the YoyoAuction contract to retreive forwarder address later
        yoyoAuction.setUpkeepId(upkeepId);

        console.log('Upkeep registered successfully!');
        console.log('Upkeep ID:', yoyoAuction.getUpkeepId());

        // 7. Get forwarder address from HelperConfig and set it in YoyoAuction
        forwarder = helperConfig.getForwarderFromUpkeepId(upkeepId);

        if (forwarder != address(0)) {
            yoyoAuction.setChainlinkForwarder(forwarder);
            console.log('Chainlink Forwarder address:', forwarder);
        } else {
            console.log('Chainlink Automation NOT configured for YoyoAuction contract!');
        }
        console.log('==============================================================');
        console.log('');
        vm.stopBroadcast();

        return (yoyoAuction, yoyoNft, deployer, helperConfig, upkeepId, forwarder);
    }

    /**
     * @notice Register upkeep on Chainlink Automation
     * @dev Handles the entire registration process
     * @dev It use the activeNetworkConfig parameters
     * @param _upkeepContract Address of the contract to automate
     * @param _name Name of the upkeep
     * @return upkeepId ID of the registered upkeep
     */
    function registerAutomation(address _upkeepContract, string memory _name, HelperConfig.NetworkConfig memory _config) public returns (uint256 upkeepId) {
        console.log('');
        console.log('==================== Registering Chainlink Automation ====================');
        console.log('Registering Chainlink Automation...');
        console.log('Upkeep Contract:', _upkeepContract);
        console.log('Admin:', _config.deployerAccount);
        console.log(
            'Admin Link Balance: ',
            LinkTokenInterface(_config.linkToken).balanceOf(_config.deployerAccount) / 1e18,
            ' LINK'
        );
        console.log('Funding Amount:', _config.fundingAmount / 1e18, 'LINK');

        // 1. Deploy AutomationRegistration helper
        AutomationRegistration registration = new AutomationRegistration(
            _config.linkToken,
            _config.automationRegistrar
        );
        console.log('AutomationRegistration deployed at:', address(registration));

        // 2. Check LINK balance
        LinkTokenInterface link = LinkTokenInterface(_config.linkToken);
        uint256 linkBalance = link.balanceOf(_config.deployerAccount);

        if (linkBalance < _config.fundingAmount) {
            revert InsufficientLinkBalance(_config.fundingAmount, linkBalance);
        }

        // 3. Transfer LINK to the registration contract
        link.approve(address(registration), _config.fundingAmount);
        console.log('Transferred', _config.fundingAmount / 1e18, 'LINK to registration contract');
        console.log('==========================================================================');
        console.log('');

        // 4. Register the upkeep
        upkeepId = registration.registerAndFundUpkeep(
            _upkeepContract,
            _name,
            _config.gasLimit,
            _config.deployerAccount,
            _config.fundingAmount
        );

        return upkeepId;
    }
}
