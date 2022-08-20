// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";

contract Math {

    using SafeMath for uint;

    uint private _nonce = 0;

    function _random(uint nonce) internal returns (uint) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, ++_nonce, blockhash(block.number - 1), nonce)));
    }

    function _max(uint number1, uint number2) internal pure returns (uint) {
        return number1 > number2 ? number1 : number2;
    }

    function _min(uint number1, uint number2) internal pure returns (uint) {
        return number1 < number2 ? number1 : number2;
    }

}
