//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

import "./exchange.sol";

/// @title						A registry for all token-pair exchanges
/// @author						Yuval B. Ardenbaum
/// @notice						Based on Uniswap V1 
/// @dev 						Restricted to eth-token pairs
contract Factory {

	/// MAPPINGS

	mapping(address => address) public tokenToExchange;

	/// FUNCTIONS

	/// @notice					Initializes exchange contract for a token
	/// @dev 					Requires all liquidity for a token to be concentrated in one exchange
	/// @param _tokenAddress	Address of token in the exchange
	/// @return 				Address of created exchange instance
	function makeExchange(address _tokenAddress) public returns (address) {
		require(_tokenAddress != address(0), "No token contract at the zero address");
		require(tokenToExchange[_tokenAddress] == address(0), "this exchange has already been deployed");
		Exchange exchange = new Exchange(_tokenAddress);
		tokenToExchange[_tokenAddress] = address(exchange);
		return address(exchange);
	}

	/// @notice					Returns address of exchange contract for _tokenAddress
	/// @dev					Can be used to query factory registry via interface in another contract
	/// @param _tokenAddress	Address of token in exchange
	/// @return  				Address of exchange for token
	function getExchange(address _tokenAddress) public view returns (address) {
		return tokenToExchange[_tokenAddress];
	}

}