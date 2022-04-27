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
    constructor(address _tokenAddress) public {
        require(_tokenAddress != address(0));
        tokenAddress = _tokenAddress;
        token = Token(tokenAddress);
    }

    /// FUNCTIONS ///

    /// @notice                 Adds liquidity to token pool for enabling trades
    /// @dev                    msg.sender must call the approve() function to 
    ///                         Approve the exchange spending their tokens
    /// @param _tokenAmount     Amount of tokens to add to liquidity pool
    function addLiquidity(uint256 _tokenAmount) public payable {
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    /// @notice                 Returns the balance of tokens in the liquidity pool
    /// @return                 Balance of tokens in liquidity pool
    function getReserve() public view returns (uint256) {
        return Token(tokenAddress).balanceOf(address(this));
    }

    /// @notice                 Constant product price calculator
    /// @return                 Ether price per token
    function getPrice(uint256 y, uint256 x) public pure returns (uint256) {
        require(y > 0 && x > 0, "invalid input/output reserve");
        return ( y * 1000) / x;
    }

    /// @notice                Output amount for desired token during trades
    /// @return                Price of Ether or token 
    function getAmount(uint256 inputAmount, uint256 y, uint256 x) private pure returns (uint256) {
        require(y > 0 && x > 0, "invalid input/output reserve");
        return ((inputAmount * x * 1000000000000000000) / (y + inputAmount));
    }

    /// @notice                 Calculates amount of token that can be purchased with eth
    /// @return                 Tokens purchased
    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is invalid");
        uint256 tokenReserve = getReserve();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    /// @notice                 Calculates amount of eth that can be purchased with tokens
    /// @return                 Eth purchased
    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is invalid");
        uint256 tokenReserve = getReserve();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    /// @notice                 Swaps ether for tokens
    function swapEthToToken(uint256 _baseTokensRequested) public payable {
        uint256 reserve = getReserve();
        uint256 tokenQuote = getAmount(msg.value, address(this).balance - msg.value, reserve);
        require(tokenQuote >= _baseTokensRequested, "Insufficient liquidity to perform this trade");
        token.transfer(msg.sender, tokenQuote);
    }

    /// @notice                 Swaps tokens for ether
    function swapTokenToEth(uint256 _tokenSold, uint256 _baseEthRequested) public payable {
        uint256 reserve = getReserve();
        uint256 ethQuote = getAmount(_tokenSold, reserve, address(this).balance);
        require(ethQuote >= _baseEthRequested, "Insufficient liquidity");
        token.transferFrom(msg.sender, address(this).balance, _tokenSold);
        payable(msg.sender).transfer(ethQuote);
    }
}