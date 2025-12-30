//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct } from '../../src/YoyoTypes.sol';
import { Ownable } from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import { EthAndNftRefuseMock } from '../Mocks/EthAndNftRefuseMock.sol';
import { console } from 'forge-std/console.sol';

contract YoyoAuctionMintPriceAndGettersTest is YoyoAuctionBaseTest {
    function testChangeMintPriceRevertsIfNotOwner() public {
        vm.prank(USER_1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER_1));
        yoyoAuction.changeMintPrice(0.2 ether);
    }

    function testChangeMintPriceRevertsIfContractIsNotSet() public {
        YoyoAuction notSetYoyoAuction = new YoyoAuction(keeperMock);

        vm.expectRevert(YoyoAuction__NftContractNotSet.selector);
        notSetYoyoAuction.changeMintPrice(0.2 ether);
    }

    function testChangeMintPriceRevertsIfNewPriceIsZero() public {
        uint256 minimumPossibleMintPrice = yoyoAuction.getMinimumPossibleMintPrice();
        vm.prank(deployer);
        vm.expectRevert(YoyoAuction__InvalidValue.selector);
        yoyoAuction.changeMintPrice(minimumPossibleMintPrice);
    }

    function testChangeMintPriceRevertsIfAuctionIsNotFinalized() public {
        uint256 auctionId = openEnglishAuctionHelper();

        assert(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.OPEN);

        vm.prank(deployer);
        vm.expectRevert(YoyoAuction__CannotChangeMintPriceDuringOpenAuction.selector);
        yoyoAuction.changeMintPrice(0.2 ether);

        // Place a bid whit a non receiver contract to close auction without finalize the auction
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.placeBid{ value: 1 ether }(auctionId);
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        vm.stopPrank();

        vm.warp(endTime);
        vm.prank(keeperMock);
        yoyoAuction.performUpkeep(abi.encode(auctionId, endTime));

        assert(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.CLOSED);

        vm.prank(deployer);
        vm.expectRevert(YoyoAuction__CannotChangeMintPriceDuringOpenAuction.selector);
        yoyoAuction.changeMintPrice(0.2 ether);
    }

    function testChangeMintPriceWorks() public {
        uint256 newMintPrice = 0.2 ether;

        vm.prank(deployer);
        yoyoAuction.changeMintPrice(newMintPrice);

        uint256 minimumBidChangeAmount = yoyoAuction.getMinimumBidChangeAmount();
        uint256 expectedMinimumBidChangeAmount = (newMintPrice * yoyoAuction.getMinimumBidChangePercentage()) /
            yoyoAuction.getPercentageDenominator();

        assertEq(yoyoNft.getBasicMintPrice(), newMintPrice);
        assertEq(minimumBidChangeAmount, expectedMinimumBidChangeAmount);
    }

    //getters tests
    function testGetNftContract() public {
        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
    }

    function testGetAuctionCounter() public {
        assertEq(yoyoAuction.getAuctionCounter(), 0);
        openEnglishAuctionHelper();
        assertEq(yoyoAuction.getAuctionCounter(), 1);
    }

    function testGetAuctionDuration() public {
        assertEq(yoyoAuction.getAuctionDuration(), 24 hours);
    }

    function testGetMinimumBidChangeAmount() public {
        uint256 expected = (yoyoNft.getBasicMintPrice() * 25) / 1000;
        assertEq(yoyoAuction.getMinimumBidChangeAmount(), expected);
    }

    function testGetMinimumBidChangePercentage() public {
        assertEq(yoyoAuction.getMinimumBidChangePercentage(), 25);
    }

    function testGetDutchAuctionStartPriceMultiplier() public {
        assertEq(yoyoAuction.getDutchAuctionStartPriceMultiplier(), 13);
    }

    function testGetPercentageDenominator() public {
        assertEq(yoyoAuction.getPercentageDenominator(), 1000);
    }

    function testGetMinimumPossibleMintPrice() public {
        assertEq(yoyoAuction.getMinimumPossibleMintPrice(), 40); // 1000/25
    }

    function testGetDutchAuctionNumberOfIntervals() public {
        assertEq(yoyoAuction.getDutchAuctionNumberOfIntervals(), 48);
    }

    function testGetGracePeriod() public {
        assertEq(yoyoAuction.getGracePeriod(), 6 hours);
    }

    function testGetAuctionFromAuctionId() public {
        uint256 auctionId = openEnglishAuctionHelper();
        AuctionStruct memory auction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(auction.auctionId, auctionId);
    }

    function testGetCurrentAuction() public {
        uint256 auctionId = openEnglishAuctionHelper();
        AuctionStruct memory auction = yoyoAuction.getCurrentAuction();
        assertEq(auction.auctionId, auctionId);
    }

    function testGetCurrentAuctionPrice() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 expected = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getAuctionFromAuctionId(auctionId).minimumBidChangeAmount;
        assertEq(yoyoAuction.getCurrentAuctionPrice(), expected);
    }

    function testGetFailedRefundAmount() public {
        assertEq(yoyoAuction.getFailedRefundAmount(USER_1), 0);
    }

    function testGetElegibilityForClaimingNft() public {
        uint256 auctionId = openDutchAuctionHelper();
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, USER_1), false);

        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.placeBid{ value: 1 ether }(auctionId);
        vm.stopPrank();

        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);
    }
}
