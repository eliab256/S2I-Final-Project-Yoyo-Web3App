// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoNftBaseTest } from '../YoyoNftTest/YoyoNft.Base.t.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { YoyoNft } from '../../src/YoyoNft/YoyoNft.sol';
import { ConstructorParams } from '../../src/YoyoTypes.sol';

import '../../src/YoyoNft/YoyoNftErrors.sol';
import '../../src/YoyoNft/YoyoNftEvents.sol';

contract YoyoNftOwnerFunctionsTest is YoyoNftBaseTest {
    /*//////////////////////////////////////////////////////////////
            Test the constructor parameters assignments
    //////////////////////////////////////////////////////////////*/
    function testNameAndSymbol() public {
        string memory expectedName = 'Yoyo Collection';
        string memory expectedSymbol = 'YOYO';

        assertEq(yoyoNft.name(), expectedName);
        assertEq(yoyoNft.symbol(), expectedSymbol);
    }

    function testContructorParameters() public {
        assertEq(yoyoNft.getAuctionContract(), AUCTION_CONTRACT);
        assertEq(yoyoNft.getBaseURI(), BASE_URI_EXAMPLE);
        assertEq(yoyoNft.owner(), deployer);
        assertEq(yoyoNft.getTotalMinted(), 0);
    }

    function testIfDeployRevertDueToZeroBaseURI() public {
        ConstructorParams memory incorrectParams = ConstructorParams({
            baseURI: '',
            auctionContract: AUCTION_CONTRACT,
            basicMintPrice: BASIC_MINT_PRICE
        });
        vm.expectRevert(YoyoNft__ValueCantBeZero.selector);
        new YoyoNft(incorrectParams);
    }

    function testIfDeployRevertDueToInvalidAuctionContract() public {
        ConstructorParams memory incorrectParams = ConstructorParams({
            baseURI: BASE_URI_EXAMPLE,
            auctionContract: address(0),
            basicMintPrice: BASIC_MINT_PRICE
        });
        vm.expectRevert(YoyoNft__InvalidAddress.selector);
        new YoyoNft(incorrectParams);
    }

    /*//////////////////////////////////////////////////////////////
            Test receive and fallback functions
    //////////////////////////////////////////////////////////////*/
    function testIfReceiveFunctionReverts() public {
        vm.expectRevert(YoyoNft__ThisContractDoesntAcceptDeposit.selector);
        address(yoyoNft).call{ value: 1 ether }('');
    }

    function testIfFallbackFunctionReverts() public {
        vm.expectRevert(YoyoNft__CallValidFunctionToInteractWithContract.selector);
        address(yoyoNft).call{ value: 1 ether }('metadata');
    }

    /*//////////////////////////////////////////////////////////////
                        Test modifiers
    //////////////////////////////////////////////////////////////*/
    function testIfYoyoOnlyOwnerModifierWorks() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER_1));
        vm.prank(USER_1);
        yoyoNft.withdraw();
    }

    function testIfYoyoOnlyAuctionContractModifierWorks() public {
        vm.expectRevert(YoyoNft__NotAuctionContract.selector);
        vm.prank(USER_1);
        yoyoNft.mintNft{ value: 1 ether }(USER_2, VALID_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                Test deposit and withdraw functions  
    //////////////////////////////////////////////////////////////*/

    function testIfDepositWorksAndEmitsEvent() public {
        uint256 depositAmount = 0.001 ether;

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit YoyoNft__DepositCompleted(depositAmount, block.timestamp);
        yoyoNft.deposit{ value: depositAmount }();
        assertEq(address(yoyoNft).balance - STARTING_BALANCE_YOYO_CONTRACT, depositAmount);
    }

    function testIfDepositRevertsIfValueIsZero() public {
        vm.prank(deployer);
        vm.expectRevert(YoyoNft__ValueCantBeZero.selector);
        yoyoNft.deposit{ value: 0 }();
    }

    function testIfWithdrawWorksAndEmitsEvent() public {
        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit YoyoNft__WithdrawCompleted(STARTING_BALANCE_YOYO_CONTRACT, block.timestamp);
        yoyoNft.withdraw();
        assertEq(address(yoyoNft).balance, 0);
        assertEq(deployer.balance, STARTING_BALANCE_DEPLOYER + STARTING_BALANCE_YOYO_CONTRACT);
    }

    function testIfWithdrawRevertsIfContractBalanceIsZero() public {
        vm.deal(address(yoyoNft), 0);
        vm.prank(deployer);
        vm.expectRevert(YoyoNft__ContractBalanceIsZero.selector);
        yoyoNft.withdraw();
    }

    function testIfWithdrawRevertsDueToFailedTransfer() public {
        vm.prank(deployer);
        yoyoNft.transferOwnership(address(ethAndNftRefuseMock));
        //call deposit from YoyoNft contract
        ethAndNftRefuseMock.depositOnNftContract{ value: 0.1 ether }();

        vm.expectRevert(YoyoNft__WithdrawFailed.selector);
        //call withdraw from YoyoNft contract
        ethAndNftRefuseMock.withdrawFromNftContract();
    }

    /*//////////////////////////////////////////////////////////////
                Test mintPrice functions 
    //////////////////////////////////////////////////////////////*/

    function testIfSetBasicMintPriceRevertsifPriceIsZero() public {
        vm.prank(yoyoNft.getAuctionContract());
        vm.expectRevert(YoyoNft__ValueCantBeZero.selector);
        yoyoNft.setBasicMintPrice(0);
    }

    function testIfsetBasicMintPriceWorksAndEmitsEvent() public {
        uint256 newPrice = 0.003 ether;

        vm.prank(yoyoNft.getAuctionContract());
        vm.expectEmit(true, true, true, true);
        emit YoyoNft__MintPriceUpdated(newPrice, block.timestamp);
        yoyoNft.setBasicMintPrice(newPrice);

        assertEq(yoyoNft.getBasicMintPrice(), newPrice);
    }
}
