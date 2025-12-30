//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct, ConstructorParams } from '../../src/YoyoTypes.sol';

contract YoyoAuctionKeepersTest is YoyoAuctionBaseTest {
    // keeperMock is sent on helperConfig inside getAnvilConfig()
    // to simulate Chainlink Automation network calling checkUpkeep and performUpkeep functions
    function testPerformeUpkeepCanOnlyRunIfCheckUpkeepReturnsTrue() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        bytes memory performDataTest = abi.encode(auctionId, endTime);

        (bool upkeepNeeded, bytes memory performData) = yoyoAuction.checkUpkeep('');
        assertFalse(upkeepNeeded);
        assertEq(performDataTest, performData);

        vm.warp(endTime);

        (upkeepNeeded, ) = yoyoAuction.checkUpkeep('');
        assertTrue(upkeepNeeded);
        assertEq(performDataTest, performData);
    }

    function testPerformUpkeepCanBeCalledOnlyByKeeperRegistryBeforeGracePeriod() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        bytes memory performDataTest = abi.encode(auctionId, endTime);

        vm.warp(endTime);

        vm.prank(USER_1);
        vm.expectRevert(YoyoAuction__OnlyChainlinkAutomationOrOwner.selector);
        yoyoAuction.performUpkeep(performDataTest);

        vm.prank(deployer);
        vm.expectRevert(YoyoAuction__OnlyChainlinkAutomationOrOwner.selector);
        yoyoAuction.performUpkeep(performDataTest);
    }

    function testOwnercanCallPerformUpkeepAfterGracePeriod() public {
        uint256 gracePeriod = yoyoAuction.getGracePeriod();
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        bytes memory performDataTest = abi.encode(auctionId, endTime);

        vm.warp(endTime);

        vm.prank(USER_1);
        vm.expectRevert(YoyoAuction__OnlyChainlinkAutomationOrOwner.selector);
        yoyoAuction.performUpkeep(performDataTest);

        vm.prank(deployer);
        vm.expectRevert(YoyoAuction__OnlyChainlinkAutomationOrOwner.selector);
        yoyoAuction.performUpkeep(performDataTest);

        uint256 ownerKeeperCallTimestamp = endTime + gracePeriod + 1 hours;
        vm.warp(ownerKeeperCallTimestamp);

        vm.prank(USER_1);
        vm.expectRevert(YoyoAuction__OnlyChainlinkAutomationOrOwner.selector);
        yoyoAuction.performUpkeep(performDataTest);

        uint256 snapshotId = vm.snapshotState();

        // After grace period, deployer can call performUpkeep (fallback mechanism)
        vm.prank(deployer);
        vm.expectEmit(true, true, false, true);
        emit YoyoAuction__ManualUpkeepExecuted(auctionId, deployer, ownerKeeperCallTimestamp);
        yoyoAuction.performUpkeep(performDataTest);

        vm.revertToState(snapshotId); // Revert to before deployer call to test keeperMock call after grace period

        vm.prank(keeperMock);
        vm.expectEmit(true, true, false, true);
        emit YoyoAuction__ManualUpkeepExecuted(auctionId, keeperMock, ownerKeeperCallTimestamp);
        yoyoAuction.performUpkeep(performDataTest);
    }

    function testPerformUpkeepRevertsIfUpkeepNeededIsFalse() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;

        bytes memory performDataTest = abi.encode(auctionId, endTime);

        vm.prank(keeperMock);
        vm.expectRevert(YoyoAuction__UpkeepNotNeeded.selector);
        yoyoAuction.performUpkeep(performDataTest);
    }

    function testPerformUpkeepCallCloseAuctionIfBidderIsNotZeroAddress() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 bidAmount = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();
        placeBidHelper(auctionId, USER_1, bidAmount);

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        bytes memory performDataTest = abi.encode(auctionId, currentAuction.endTime);

        vm.roll(block.number + 1);
        vm.warp(currentAuction.endTime);

        vm.prank(keeperMock);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionClosed(
            auctionId,
            currentAuction.tokenId,
            currentAuction.startPrice,
            currentAuction.startTime,
            currentAuction.endTime,
            USER_1,
            bidAmount
        );
        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.FINALIZED);
    }

    function testPerformUpkeepCallRestartEnglishAuctionCorrectlyIfBidderIsZeroAddress() public {
        uint256 auctionId = openEnglishAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        uint256 oldStartTime = currentAuction.startTime;
        bytes memory performDataTest = abi.encode(auctionId, currentAuction.endTime);

        vm.roll(block.number + 1);
        vm.warp(currentAuction.endTime);

        uint256 newStartTime = block.timestamp;
        uint256 newEndTime = newStartTime + yoyoAuction.getAuctionDuration();

        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionRestarted(
            auctionId,
            currentAuction.tokenId,
            newStartTime,
            currentAuction.startPrice,
            newEndTime,
            yoyoAuction.getMinimumBidChangeAmount()
        );
        vm.prank(keeperMock);
        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.OPEN);
        assertTrue(oldStartTime < newStartTime);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startTime, newStartTime);
    }

    function testPerformUpkeepCallRestartDutchAuctionCorrectlyIfBidderIsZeroAddress() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        uint256 oldStartTime = currentAuction.startTime;
        bytes memory performDataTest = abi.encode(auctionId, currentAuction.endTime);

        vm.roll(block.number + 1);
        vm.warp(currentAuction.endTime);

        uint256 newStartTime = block.timestamp;
        uint256 newEndTime = newStartTime + yoyoAuction.getAuctionDuration();

        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionRestarted(
            auctionId,
            currentAuction.tokenId,
            newStartTime,
            currentAuction.startPrice,
            newEndTime,
            yoyoAuction.getMinimumBidChangeAmount()
        );
        vm.prank(keeperMock);
        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.OPEN);
        assertTrue(oldStartTime < newStartTime);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).startTime, newStartTime);
    }
}
