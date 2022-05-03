//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

import "./token.sol";
import "./exchange.sol";

/// @title					A registry for all token-pair exchanges
/// @author					Yuval B. Ardenbaum
/// @notice					Based on Uniswap V1 
/// @dev 					Restricted to eth-token pairs
contract Factory {
	mapping(address => address) public tokenToExchange;

	function makeExchange(address _tokenAddress) public returns (address) {
		require(_tokenAddress != address(0), "No token contract at the zero address");
		require(tokenToExchange[_tokenAddress] == address(0), "this exchange has already been deployed");
		Exchange exchange = new Exchange(_tokenAddress);
		tokenToExchange[_tokenAddress] = address(exchange);
		return address(exchange);
	}

	
}