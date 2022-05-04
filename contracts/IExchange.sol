//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

interface IExchange {
	function swapEthToToken(uint256 _baseTokensRequested) public payable;
}