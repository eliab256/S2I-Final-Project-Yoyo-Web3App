//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IYoyoAuction } from '../../src/YoyoAuction/IYoyoAuction.sol';
import { IERC721Receiver } from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

contract EthAndNftRefuseMock is IERC721Receiver {
    IYoyoAuction public auctionContract;
    bool canReceiveEth = false;
    bool canReceiveNft = false;
    bool throwPanicError = false;
    bool causeOutOfGas = false;

    uint256 private gasWaster;

    constructor(address _auctionContractAddress) {
        auctionContract = IYoyoAuction(_auctionContractAddress);
    }

    function placeBid(uint256 auctionId) public payable {
        auctionContract.placeBidOnAuction{ value: msg.value }(auctionId);
    }

    function claimRefund() public {
        auctionContract.claimFailedRefunds();
    }

    function claimNftFromAuction(uint256 _auctionId) public {
        auctionContract.claimNftForWinner(_auctionId);
    }

    function setCanReceiveEth(bool _canReceive) public {
        canReceiveEth = _canReceive;
    }

    function setCanReceiveNft(bool _canReceive) public {
        canReceiveNft = _canReceive;
    }

    function setThrowPanicError(bool _throwPanic) public {
        throwPanicError = _throwPanic;
    }

    function setCauseOutOfGas(bool _causeOutOfGas) public {
        causeOutOfGas = _causeOutOfGas;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if (causeOutOfGas) {
            _causeOutOfGasFunction();
            return 0x00000000; // Never reached
        }

        if (!canReceiveNft) {
            if (throwPanicError) {
                _causePanicError();
                return 0x00000000; // Never reached
            } else {
                return 0x00000000;
            }
        }

        return IERC721Receiver.onERC721Received.selector;
    }

    function _causePanicError() private pure {
        uint256 x = 1;
        uint256 y = 0;
        x = x / y;
    }

    function _causeOutOfGasFunction() private {
        while (true) {
            gasWaster++;
        }
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
