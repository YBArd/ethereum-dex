//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

import "./token.sol";

/// @title                      An exchange for a trading pair of tokens
/// @author                     Yuval B. Ardenbaum 
/// @notice                     Based off Uniswap factory-exchange model             
/// @dev                        Only ETH-token pairs for now like Uniswap V1
contract Exchange {
    
    /// FIELDS ///

    address public tokenAddress;
    Token public token;

    /// CONSTRUCTORS ///

    /// @notice                 Initializes instance of a token-ETH exchange
    /// @dev                    Requires that the address of the token is not the 0 address
    /// @dev                    Sets state variable tokenAddress to argument _tokenAddress
    /// @param _tokenAddress    Address of token contract
    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0));
        tokenAddress = _tokenAddress;
    }

    /// FUNCTIONS ///

    /// @notice                 Adds liquidity to token pool for enabling trades
    /// @dev                    msg.sender must call the approve() function to 
    ///                         Approve the exchange spending their tokens
    /// @param _tokenAmount     Amount of tokens to add to liquidity pool
    function addLiquidity(uint256 _tokenAmount) public payable {
        token = Token(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    /// @notice                 Returns the balance of tokens in the liquidity pool
    /// @return                 Balance of tokens in liquidity pool
    function getReserve() public view returns (uint256) {
        return Token(tokenAddress).balanceOf(address(this));
    }

}