// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract YoyoAuctionSetupTest is YoyoAuctionBaseTest {
    function testIfDeployAuctionContractAssignOwnerAndAuctionCounter() public {
        assertEq(yoyoAuction.owner(), deployer);
        assertEq(yoyoAuction.getAuctionCounter(), 0);
    }

    function testIfDeployNftContractAssignOwnerAndAuctionContract() public {
        assertEq(yoyoNft.owner(), deployer);
        assertEq(yoyoAuction.owner(), deployer);
        assertEq(yoyoNft.getAuctionContract(), address(yoyoAuction));
        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
    }

    function testIfSetNftContractRevertsIfNotOwner() public {
        vm.startPrank(USER_1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER_1));
        yoyoAuction.setNftContract(address(yoyoNft));
        vm.stopPrank();
    }

    function testIfSetNftContractRevertsIfAlreadySet() public {
        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__NftContractAlreadySet.selector);
        yoyoAuction.setNftContract(address(yoyoNft));
        vm.stopPrank();
    }

    function testCorrectInitializationOfMinimumBidChangeAmount() public {
        uint256 expectedMinimumBidChangeAmount = (yoyoNft.getBasicMintPrice() *
            yoyoAuction.getMinimumBidChangePercentage()) / yoyoAuction.getPercentageDenominator();
        assertEq(yoyoAuction.getMinimumBidChangeAmount(), expectedMinimumBidChangeAmount);
    }

    //test fallback and receive functions
    function testIfReceiveFunctionReverts() public {
        vm.expectRevert(YoyoAuction__ThisContractDoesntAcceptDeposit.selector);
        address(yoyoAuction).call{ value: 1 ether }('');
    }

    function testIfFallbackFunctionReverts() public {
        vm.expectRevert(YoyoAuction__CallValidFunctionToInteractWithContract.selector);
        address(yoyoAuction).call{ value: 1 ether }('metadata');
    }
}
