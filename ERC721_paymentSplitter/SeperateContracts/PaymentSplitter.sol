// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

//["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
// owner  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";


/*
Example:  pass list of account for splitter. and a list of shares.

address[]  _payees = [
        0x7df9322048082b79C24682c9d3835e438c21e0d6, //account 1
        0x0e06f846ECBC8a8A3088866Fb51e090eBC028C33 //account 2
    ];
uint256[]  _payeeShares = [40, 60];

["0x7df9322048082b79C24682c9d3835e438c21e0d6", "0x0e06f846ECBC8a8A3088866Fb51e090eBC028C33"]
["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
 */


contract SplitPayments is PaymentSplitter {
    constructor (address[] memory _payees, uint256[] memory _payeeShares) PaymentSplitter(_payees, _payeeShares) payable {}
}