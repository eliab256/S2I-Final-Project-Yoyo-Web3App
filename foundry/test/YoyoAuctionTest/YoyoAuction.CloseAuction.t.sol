//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct } from '../../src/YoyoTypes.sol';
import { Vm } from 'forge-std/Vm.sol';

contract YoyoAuctionCloseAuctionTest is YoyoAuctionBaseTest {
    function testCloseAuctionWorksWithDutchAuctionAndMintNft() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            auctionId,
            currentAuction.tokenId,
            currentAuction.startPrice,
            currentAuction.startTime,
            block.timestamp,
            USER_1,
            newBidPlaced
        );
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__AuctionFinalized(auctionId, currentAuction.tokenId, USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        vm.roll(block.number + 1);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.FINALIZED);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), USER_1);
    }

    function testCloseAuctionWorksWithEnglishAuctionAndMintNft() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 bidAmount = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        placeBidHelper(auctionId, USER_1, bidAmount);

        vm.roll(block.number + 1);
        vm.warp(endTime);
        //PerformUpkeep check conditions and call closeAuction function
        vm.startPrank(keeperMock);
        yoyoAuction.performUpkeep(abi.encode(auctionId, endTime));
        vm.stopPrank();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        assertTrue(currentAuction.state == AuctionState.FINALIZED);
        assertEq(currentAuction.nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), USER_1);
    }

    function testWhenFailingMintUpdatesMapping() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.setThrowPanicError(false);

        //Place a bid on the auction
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        vm.roll(block.number + 1);

        AuctionStruct memory updatedAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertTrue(updatedAuction.state == AuctionState.CLOSED);
        assertEq(updatedAuction.nftOwner, address(yoyoAuction));
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(yoyoAuction));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 0);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);
    }

    function testWhenFailingMintEmitEvents() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);

        vm.recordLogs();
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        Vm.Log[] memory events = vm.getRecordedLogs();
        vm.stopPrank();

        //Event Signatures
        bytes32 placeBifSig = events[0].topics[0];
        bytes32 auctionCloseSig = events[1].topics[0];
        bytes32 mintFailedSig = events[2].topics[0];

        vm.roll(block.number + 1);
    }

    // function testIfCloseAuctionFailMintWithoutErrorAndEmitEvents() public {
    //     //Deploy the mock contract
    //     YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
    //     //deploy new istance of YoyoAuction with the mock contract
    //     YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
    //     yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

    //     uint256 tokenId = 5;
    //     AuctionType auctionType = AuctionType.DUTCH;

    //     yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

    //     //Set Mock to panic

    //     yoyoNftMockFailingMint.setShouldPanic(true);

    //     //Place a Bid and trigger close auction
    //     vm.startPrank(USER_1);
    //     uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
    //     vm.expectEmit(true, true, true, true);
    //     emit YoyoAuction__AuctionClosed(
    //         1,
    //         tokenId,
    //         yoyoAuctionWithMock.getAuctionFromAuctionId(1).startPrice,
    //         yoyoAuctionWithMock.getAuctionFromAuctionId(1).startTime,
    //         block.timestamp,
    //         USER_1,
    //         newBidPlaced
    //     );
    //     vm.expectEmit(true, true, true, false);
    //     emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, 'unknown error');
    //     yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
    //     vm.stopPrank();

    //     AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
    //     assertTrue(currentAuction.state == AuctionState.CLOSED);
    //     assertEq(currentAuction.nftOwner, address(0));
    // }

    // function testIfCloseAuctionFailMintWithErrorAndEmitEvents() public {
    //     //Deploy the mock contract
    //     YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
    //     //deploy new istance of YoyoAuction with the mock contract
    //     YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
    //     yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

    //     uint256 tokenId = 5;
    //     AuctionType auctionType = AuctionType.DUTCH;

    //     yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

    //     //Set Mock to fail mint
    //     string memory reason = 'mint failed';
    //     yoyoNftMockFailingMint.setShouldFailMint(true, reason);

    //     //Place a Bid and trigger close auction
    //     vm.startPrank(USER_1);
    //     uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
    //     vm.expectEmit(true, true, true, true);
    //     emit YoyoAuction__AuctionClosed(
    //         1,
    //         tokenId,
    //         yoyoAuctionWithMock.getAuctionFromAuctionId(1).startPrice,
    //         yoyoAuctionWithMock.getAuctionFromAuctionId(1).startTime,
    //         block.timestamp,
    //         USER_1,
    //         newBidPlaced
    //     );
    //     vm.expectEmit(true, true, true, false);
    //     emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, reason);
    //     yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
    //     vm.stopPrank();

    //     AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
    //     assertTrue(currentAuction.state == AuctionState.CLOSED);
    //     assertEq(currentAuction.nftOwner, address(0));
    // }
}
