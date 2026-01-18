//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct } from '../../src/YoyoTypes.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { console2 } from 'forge-std/console2.sol';

contract YoyoAuctionOpenAuctionTest is YoyoAuctionBaseTest {
   
    function testIfOpenNewAuctionRevertsIfNotOwner() public {
        vm.startPrank(USER_1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER_1));
        yoyoAuction.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);
        vm.stopPrank();
    }

    function testIfOpenNewAuctionRevertsDueToNftContractNotSet() public {
        vm.startPrank(deployer);
        YoyoAuction yoyoAuctionWithoutNft = new YoyoAuction();

        vm.expectRevert(YoyoAuction__NftContractNotSet.selector);
        yoyoAuctionWithoutNft.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);
        vm.stopPrank();
    }

    function testIfOpenNewAuctionRevertsIfTokenIdIsNotMintable() public {
        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__InvalidTokenId.selector);
        yoyoAuction.openNewAuction(invalidTokenId, ENGLISH_TYPE);
        vm.stopPrank();
    }

    function testIfOpenNewAuctionRevertsIfThereIsAlreadyAnAuctionOpen() public {
        uint256 secondTokenId = VALID_TOKEN_ID + 1;

        vm.roll(1);
        vm.prank(deployer);
        yoyoAuction.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);

        vm.roll(20);
        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__AuctionStillOpen.selector);
        yoyoAuction.openNewAuction(secondTokenId, ENGLISH_TYPE);
        vm.stopPrank();
    }

    function testIfOpenNewAuctionWorks() public {
        uint256 startPrice = yoyoNft.getBasicMintPrice();
        uint256 auctionDuration = yoyoAuction.getAuctionDuration();
        uint256 initialAuctionCounter = yoyoAuction.getAuctionCounter();
        uint256 auctionId = initialAuctionCounter + 1;

        uint256 fakeTimestamp = block.timestamp + 1 days;
        vm.warp(fakeTimestamp);

        vm.startPrank(deployer);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionOpened(
            auctionId,
            VALID_TOKEN_ID,
            ENGLISH_TYPE,
            startPrice,
            fakeTimestamp,
            fakeTimestamp + auctionDuration,
            startPrice / 20
        );

        yoyoAuction.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);
        vm.stopPrank();

        //assertEq(yoyoAuction.getAuctionCounter(), auctionId);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).tokenId, VALID_TOKEN_ID);
        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).auctionType == ENGLISH_TYPE);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startTime, fakeTimestamp);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime, fakeTimestamp + auctionDuration);
    }

    function testIfOpenNewAuctionOpensNewEnglishAuction() public {
        uint256 startPrice = yoyoNft.getBasicMintPrice();
        uint256 auctionDuration = yoyoAuction.getAuctionDuration();

        uint256 initialAuctionCounter = yoyoAuction.getAuctionCounter();
        uint256 auctionId = initialAuctionCounter + 1;

        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionCounter(), auctionId);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).auctionId, auctionId);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).tokenId, VALID_TOKEN_ID);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).nftOwner, address(0));
        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.OPEN);
        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).auctionType == ENGLISH_TYPE);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startPrice, startPrice);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startTime, block.timestamp);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime, block.timestamp + auctionDuration);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).higherBidder, address(0));
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid, startPrice);
        assertEq(
            yoyoAuction.getAuctionFromAuctionId(auctionId).minimumBidChangeAmount,
            (startPrice * yoyoAuction.getMinimumBidChangePercentage()) / yoyoAuction.getPercentageDenominator()
        );
    }

    function testIfOpenNewAuctionOpnesNewDutchAuction() public {
        uint256 startPrice = yoyoNft.getBasicMintPrice() * yoyoAuction.getDutchAuctionStartPriceMultiplier();
        uint256 auctionDuration = yoyoAuction.getAuctionDuration();
        uint256 dropAmount = (startPrice - yoyoNft.getBasicMintPrice()) /
            yoyoAuction.getDutchAuctionNumberOfIntervals(); //48 is s_dutchAuctionNumberOfIntervals
        uint256 auctionId = yoyoAuction.getAuctionCounter() + 1;
        uint256 fakeTimestamp = block.timestamp + 1 days;
        vm.warp(fakeTimestamp);

        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(VALID_TOKEN_ID, DUTCH_TYPE);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionCounter(), auctionId);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).auctionId, auctionId);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).tokenId, VALID_TOKEN_ID);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).nftOwner, address(0));
        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.OPEN);
        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).auctionType == DUTCH_TYPE);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startPrice, startPrice);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startTime, fakeTimestamp);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime, fakeTimestamp + auctionDuration);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).higherBidder, address(0));
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid, startPrice);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).minimumBidChangeAmount, dropAmount);
    }
}
