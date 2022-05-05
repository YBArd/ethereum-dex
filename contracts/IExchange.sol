//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

interface IExchange {
	function ethTokenTransfer(uint256 _baseTokensRequested, address _user) external payable;
}