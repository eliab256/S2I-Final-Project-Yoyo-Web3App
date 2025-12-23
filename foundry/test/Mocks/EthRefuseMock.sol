//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IYoyoAuction } from '../../src/YoyoAuction/IYoyoAuction.sol';

contract EthRefuseMock {
    IYoyoAuction public auctionContract;
    bool canReceiveEth = false;

    constructor(address _auctionContractAddress) payable {
        auctionContract = IYoyoAuction(_auctionContractAddress);
    }

    function placeBid(uint256 auctionId, uint256 bidAmount) public  {
        auctionContract.placeBidOnAuction{ value: bidAmount }(auctionId);
    }

    function claimRefund() public {
        auctionContract.claimFailedRefunds();
    }

    function setCanReceiveEth(bool _canReceive) public {
        canReceiveEth = _canReceive;
    }

    /**
     * @dev This function will always revert when receiving Ether.
     */

    receive() external payable {
        if (canReceiveEth) {
            return;
        }
        revert('EthRefuseMock__ThisContractDoesntAcceptEth');
    }
}
