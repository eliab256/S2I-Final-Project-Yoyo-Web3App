//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import { EthRefuseMock } from '../Mocks/EthRefuseMock.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct, ConstructorParams } from '../../src/YoyoTypes.sol';
import { console2 } from 'forge-std/console2.sol';

contract YoyoAuctionPlaceBidTest is YoyoAuctionBaseTest {
    EthRefuseMock public ethRefuseMock;

    function testIfPlaceBidOnAuctionRevertsIfDoesNotExist() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 invalidAuctionId = 10;
        assert(auctionId != invalidAuctionId);

        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__AuctionDoesNotExist.selector);
        yoyoAuction.placeBidOnAuction{ value: 0.1 ether }(invalidAuctionId);
        vm.stopPrank();
    }

    function testIfPlaceBidOnAuctionRevertsIfAuctionIsNotOpen() public {
        uint256 auctionId = openDutchAuctionHelper();
        uint256 currentAuctionPrice = yoyoAuction.getCurrentAuctionPrice();
        //Place a bid to close the auction
        vm.prank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: currentAuctionPrice }(auctionId);

        //Try to place a bid on the same auction after it has been closed
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__AuctionNotOpen.selector);
        yoyoAuction.placeBidOnAuction{ value: currentAuctionPrice }(auctionId);
        vm.stopPrank();
    }

    function testIfPlaceBidOnAuctionPlaceBidOnEnglishAuctionWorks() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice() + yoyoAuction.getMinimumBidChangeAmount();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(auctionId, USER_1, newBidPlaced, ENGLISH_TYPE);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(currentAuction.higherBidder, USER_1);
        assertEq(currentAuction.higherBid, newBidPlaced);
        //if auction is English, should stay open after a bid is placed
        assertTrue(currentAuction.state == AuctionState.OPEN);
    }

    function testIfPlaceBidOnEnglishAuctionRevertsIfBidTooLowAndHigherBidUpdateCorrectly() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 newBidPlaced = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();

        //place first bid on the auction
        vm.startPrank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        //Try to place a bid that is too low
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__BidTooLow.selector);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(currentAuction.higherBidder, USER_1);
        assertEq(currentAuction.higherBid, newBidPlaced);
    }

    function testIfPlaceBidOnDutchAuctionWorksAndCloseTheCurrentAuction() public {
        uint256 auctionId = openDutchAuctionHelper();
        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() * yoyoAuction.getDutchAuctionStartPriceMultiplier();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(auctionId, USER_1, newBidPlaced, DUTCH_TYPE);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(currentAuction.higherBidder, USER_1);
        assertEq(currentAuction.higherBid, newBidPlaced);
        //if auction is Dutch, should close after a bid is placed
        assertTrue(currentAuction.state == AuctionState.FINALIZED);
    }

    function testIfPlaceBidOnDutchAuctionRevertsIfBidTooLow() public {
        uint256 auctionId = openDutchAuctionHelper();

        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice() - 1;

        //place first bid on the auction
        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__BidTooLow.selector);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();
    }

    ////////// REFUND TESTS //////////

    function testIfPlaceBidOnEnglishAuctionRefundsPreviousBidder() public {
        uint256 auctionId = openEnglishAuctionHelper();

        uint256 firstBid = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();
        uint256 secondBid = firstBid + yoyoAuction.getMinimumBidChangeAmount();

        uint256 user1BalanceBeforeBid = USER_1.balance;

        placeBidHelper(auctionId, USER_1, firstBid);

        uint256 user1BalanceAfterFirstBid = USER_1.balance;

        //Place second bid on the auction
        vm.startPrank(USER_2);
        vm.expectEmit(false, false, true, true);
        emit YoyoAuction__BidderRefunded(USER_1, firstBid);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(auctionId, USER_2, secondBid, ENGLISH_TYPE);
        yoyoAuction.placeBidOnAuction{ value: secondBid }(auctionId);
        vm.stopPrank();

        uint256 user1balanceAfterRefund = USER_1.balance;

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(currentAuction.higherBidder, USER_2);
        assertEq(currentAuction.higherBid, secondBid);
        assertEq(user1BalanceAfterFirstBid, user1BalanceBeforeBid - firstBid);
        assertEq(user1BalanceBeforeBid, user1balanceAfterRefund);
    }

    function testIfUpdateRefundMappingDueToFailedRefund() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 firstBid = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();

        vm.startPrank(USER_1);
        ethRefuseMock = new EthRefuseMock{ value: firstBid }(address(yoyoAuction));
        ethRefuseMock.placeBid(auctionId, firstBid);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).higherBidder, address(ethRefuseMock));
        assertEq(yoyoAuction.getFailedRefundAmount(address(ethRefuseMock)), 0);
        assertEq(address(ethRefuseMock).balance, 0);

        uint256 secondBid = firstBid + yoyoAuction.getMinimumBidChangeAmount();

        vm.startPrank(USER_2);
        vm.expectEmit(false, false, true, true);
        emit YoyoAuction__BidderRefundFailed(address(ethRefuseMock), firstBid);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(auctionId, USER_2, secondBid, ENGLISH_TYPE);
        yoyoAuction.placeBidOnAuction{ value: secondBid }(auctionId);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertEq(currentAuction.higherBidder, USER_2);
        assertEq(yoyoAuction.getFailedRefundAmount(address(ethRefuseMock)), firstBid);
        assertEq(address(ethRefuseMock).balance, 0);
    }

    function testIfClaimFailedRefundWorks() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 firstBid = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();

        vm.startPrank(USER_1);
        ethRefuseMock = new EthRefuseMock{ value: firstBid }(address(yoyoAuction));
        ethRefuseMock.placeBid(auctionId, firstBid);
        vm.stopPrank();

        uint256 secondBid = firstBid + yoyoAuction.getMinimumBidChangeAmount();

        placeBidHelper(auctionId, USER_2, secondBid);
    }
}
