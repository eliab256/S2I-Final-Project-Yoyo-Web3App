// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LinkTokenInterface } from '@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol';

struct RegistrationParams {
    string name;
    bytes encryptedEmail;
    address upkeepContract;
    uint32 gasLimit;
    address adminAddress;
    uint8 triggerType;
    bytes checkData;
    bytes triggerConfig;
    bytes offchainConfig;
    uint96 amount;
}
interface AutomationRegistrarInterface {
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256);
}

contract AutomationRegistration {
    LinkTokenInterface public immutable i_link;
    AutomationRegistrarInterface public immutable i_registrar;

    constructor(address linkToken, address registrar) {
        i_link = LinkTokenInterface(linkToken);
        i_registrar = AutomationRegistrarInterface(registrar);
    }

    /**
     * @notice Registers a new upkeep on Chainlink Automation
     * @param upkeepContract Address of the contract to automate
     * @param name Name of the upkeep
     * @param gasLimit Gas limit for performUpkeep
     * @param adminAddress Admin address (owner of the upkeep)
     * @param fundingAmount Amount of LINK to fund the upkeep
     * @return upkeepID ID of the registered upkeep
     */
    function registerAndFundUpkeep(
        address upkeepContract,
        string memory name,
        uint32 gasLimit,
        address adminAddress,
        uint96 fundingAmount
    ) external returns (uint256) {
        // 1. Approve LINK to the registrar
        i_link.approve(address(i_registrar), fundingAmount);

        // 2. Prepare registration parameters
        RegistrationParams memory params = RegistrationParams({
            name: name,
            encryptedEmail: hex'', // empty
            upkeepContract: upkeepContract,
            gasLimit: gasLimit,
            adminAddress: adminAddress,
            triggerType: 0, // 0 = Conditional, 1 = Log trigger
            checkData: hex'', // empty for your case
            triggerConfig: hex'', // empty
            offchainConfig: hex'', // empty
            amount: fundingAmount
        });

        // 3. Register the upkeep
        uint256 upkeepID = i_registrar.registerUpkeep(params);

        if (upkeepID == 0) {
            revert('AutomationRegistration: Upkeep registration failed');
        } else {
            return upkeepID;
        }
    }
}
