//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IYoyoAuction } from '../../src/YoyoAuction/IYoyoAuction.sol';
import { IYoyoNft } from '../../src/YoyoNft/IYoyoNft.sol';
import { IERC721Receiver } from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';

/**
 * @title EthAndNftRefuseMock
 * @notice Mock contract for testing ETH and NFT transfer failure scenarios
 * @dev Simulates different failure modes including revert, panic, and out-of-gas errors
 */
contract EthAndNftRefuseMock is IERC721Receiver {
    /**
     * @notice Reference to the YoyoAuction contract
     */
    IYoyoAuction public auctionContract;

    /**
     * @notice Reference to the YoyoNft contract
     */
    IYoyoNft public nftContract;

    /**
     * @notice Flag to control whether this contract can receive ETH
     * @dev When false, receive() and fallback() will revert
     */
    bool canReceiveEth = false;

    /**
     * @notice Flag to control whether this contract can receive NFTs
     * @dev When false, onERC721Received will return invalid selector
     */
    bool canReceiveNft = false;

    /**
     * @notice Flag to trigger panic errors during NFT reception
     * @dev When true, causes division by zero panic in onERC721Received
     */
    bool throwPanicError = false;

    /**
     * @notice Flag to trigger out-of-gas errors during NFT reception
     * @dev When true, enters infinite loop to consume all gas
     */
    bool causeOutOfGas = false;

    /**
     * @notice Counter variable to waste gas in infinite loop
     * @dev Incremented continuously in _causeOutOfGasFunction
     */
    uint256 private gasWaster;

    /**
     * @notice Initializes the mock with references to auction and NFT contracts
     * @param _auctionContractAddress Address of the YoyoAuction contract
     * @param _nftContractAddress Address of the YoyoNft contract
     */
    constructor(address _auctionContractAddress, address _nftContractAddress) {
        auctionContract = IYoyoAuction(_auctionContractAddress);
        nftContract = IYoyoNft(_nftContractAddress);
    }

    ////// SETTERS //////

    /**
     * @notice Controls whether the contract can receive ETH transfers
     * @param _canReceive True to accept ETH, false to revert on ETH reception
     */
    function setCanReceiveEth(bool _canReceive) public {
        canReceiveEth = _canReceive;
    }

    /**
     * @notice Controls whether the contract can receive NFT transfers
     * @param _canReceive True to accept NFTs, false to reject NFT reception
     */
    function setCanReceiveNft(bool _canReceive) public {
        canReceiveNft = _canReceive;
    }

    /**
     * @notice Controls whether to throw panic errors when receiving NFTs
     * @param _throwPanic True to cause division by zero panic, false for normal operation
     */
    function setThrowPanicError(bool _throwPanic) public {
        throwPanicError = _throwPanic;
    }

    /**
     * @notice Controls whether to cause out-of-gas errors when receiving NFTs
     * @param _causeOutOfGas True to enter infinite loop, false for normal operation
     */
    function setCauseOutOfGas(bool _causeOutOfGas) public {
        causeOutOfGas = _causeOutOfGas;
    }

    ////// AUCTION CONTRACT INTERACTIONS//////

    /**
     * @notice Places a bid on a specific auction
     * @dev Forwards msg.value to the auction contract
     * @param auctionId The ID of the auction to bid on
     */
    function placeBid(uint256 auctionId) public payable {
        auctionContract.placeBidOnAuction{ value: msg.value }(auctionId);
    }

    /**
     * @notice Claims failed refunds from the auction contract
     * @dev Calls claimFailedRefunds on the auction contract
     */
    function claimRefund() public {
        auctionContract.claimFailedRefunds();
    }

    /**
     * @notice Claims an NFT from an auction as the winner
     * @param _auctionId The ID of the auction to claim NFT from
     */
    function claimNftFromAuction(uint256 _auctionId) public {
        auctionContract.claimNftForWinner(_auctionId);
    }

    /////// NFT CONTRACT INTERACTIONS//////

    /**
     * @notice Deposits ETH to the NFT contract
     * @dev Forwards msg.value to the NFT contract's deposit function
     */
    function depositOnNftContract() public payable {
        nftContract.deposit{ value: msg.value }();
    }

    /**
     * @notice Withdraws funds from the NFT contract
     * @dev Calls withdraw on the NFT contract (owner only on NFT contract)
     */
    function withdrawFromNftContract() public {
        nftContract.withdraw();
    }

    /**
     * @notice Handles the receipt of an NFT
     * @dev Implements IERC721Receiver to accept or reject NFT transfers based on test flags
     * @dev Can simulate three failure modes:
     *      - Out of gas (if causeOutOfGas is true)
     *      - Panic error (if throwPanicError is true)
     *      - Invalid selector (if canReceiveNft is false)
     * @return bytes4 The function selector if accepting, 0x00000000 if rejecting
     */
    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
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

    /**
     * @notice Causes a panic error by division by zero
     * @dev Used to test panic error handling in NFT transfers
     */
    function _causePanicError() private pure {
        uint256 x = 1;
        uint256 y = 0;
        x = x / y;
    }

    /**
     * @notice Causes an out-of-gas error by infinite loop
     * @dev Enters infinite loop incrementing gasWaster until gas runs out
     */
    function _causeOutOfGasFunction() private {
        while (true) {
            gasWaster++;
        }
    }

    /**
     * @notice Fallback function for handling calls to non-existent functions
     * @dev Reverts if canReceiveEth is false, otherwise accepts the ETH
     */
    fallback() external payable {
        if (canReceiveEth) {
            return;
        }
        revert('EthRefuseMock__ThisContractDoesntAcceptEth');
    }

    /**
     * @notice Receive function for handling plain ETH transfers
     * @dev Reverts if canReceiveEth is false, otherwise accepts the ETH
     */
    receive() external payable {
        if (canReceiveEth) {
            return;
        }
        revert('EthRefuseMock__ThisContractDoesntAcceptEth');
    }
}
