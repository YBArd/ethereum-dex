//// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.6;

import "./token.sol";

/// @title                      An exchange for a trading pair of tokens
/// @author                     Yuval B. Ardenbaum 
/// @notice                     Based off Uniswap factory-exchange model             
/// @dev                        Only ETH-token pairs for now like Uniswap V1
contract Exchange is Token {
    
    /// FIELDS ///

    address public tokenAddress;
    Token public token;
    address public factoryAddress;

    /// CONSTRUCTORS ///

    /// @notice                 Initializes instance of a token-ETH exchange
    /// @dev                    Requires that the address of the token is not the 0 address
    /// @dev                    Sets state variable tokenAddress to argument _tokenAddress
    /// @param _tokenAddress    Address of token contract
    constructor(address _tokenAddress) Token('LP Token', 'LP', 18, 0) public {
        require(_tokenAddress != address(0));
        tokenAddress = _tokenAddress;
        token = Token(tokenAddress);
        factoryAddress = msg.sender;
    }

    /// FUNCTIONS ///

    /// @notice                 Adds liquidity to token pool for enabling trades
    /// @dev                    msg.sender must call the approve() function to 
    ///                         Approve the exchange spending their tokens
    /// @param _tokenAmount     Amount of tokens to add to liquidity pool
    function addLiquidity(uint256 _tokenAmount) public payable returns (uint256) {
        if(getTokenReserves() == 0) {
            token.transferFrom(msg.sender, address(this), _tokenAmount);
            uint256 lpBalance = address(this).balance;
            _mint(msg.sender, lpBalance);
            return lpBalance;
        }
        else {
            uint256 ethLiquidity = address(this).balance - msg.value;
            uint256 tokenLiquidity = getTokenReserves();
            uint256 tokenDeposit = (msg.value * tokenLiquidity) / ethLiquidity;
            require(_tokenAmount >= tokenDeposit, "Insufficient token deposit to add liquidity");
            token.transferFrom(msg.sender, address(this), tokenDeposit);     
            uint256 lpBalance = (token.getTotalSupply() * msg.value) / ethLiquidity;
            _mint(msg.sender, lpBalance);
            return lpBalance;
        }
    }

    /// @notice                 Returns the balance of tokens in the liquidity pool
    /// @return                 Balance of tokens in liquidity pool
    function getTokenReserves() public view returns (uint256) {
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
        require(y > 0 && x > 0, "insufficient eth/token liquidity");
        uint256 feeAdjustedInput = inputAmount * 99;
        uint256 numerator = feeAdjustedInput * x;
        uint256 denominator = (y * 100) + feeAdjustedInput;
        return (numerator/denominator);
    }

    /// @notice                 Calculates amount of token that can be purchased with eth
    /// @return                 Tokens purchased
    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is invalid");
        uint256 tokenReserve = getTokenReserves();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    /// @notice                 Calculates amount of eth that can be purchased with tokens
    /// @return                 Eth purchased
    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is invalid");
        uint256 tokenReserve = getTokenReserves();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    /// @notice                 Swaps ether for tokens
    function swapEthToToken(uint256 _baseTokensRequested) public payable {
        uint256 reserve = getTokenReserves();
        uint256 tokenQuote = getAmount(msg.value, address(this).balance - msg.value, reserve);
        require(tokenQuote >= _baseTokensRequested, "Insufficient liquidity to perform this trade");
        token.transfer(msg.sender, tokenQuote);
    }

    /// @notice                 Swaps tokens for ether
    function swapTokenToEth(uint256 _tokenSold, uint256 _baseEthRequested) public payable {
        uint256 reserve = getTokenReserves();
        uint256 ethQuote = getAmount(_tokenSold, reserve, address(this).balance);
        require(ethQuote >= _baseEthRequested, "Insufficient liquidity");
        token.transferFrom(msg.sender, address(this), _tokenSold);
        payable(msg.sender).transfer(ethQuote);
    }

    /// @notice                 Removes eth/token liquidity from exchange contract proportionally
    /// @param _amount          Amount of LP tokens representing share of liquidity to remove                  
    /// @return                 Returns ether amount and token amount removed from LPs
    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount > 0, "Can't remove zero liquidity");
        uint256 ethers = (address(this).balance * _amount) / getTotalSupply(); // ratio of ethers to total LP reserves
        uint256 tokens = (getTokenReserves() * _amount) / getTotalSupply(); // ratio of tokens to total LP reserves
        _burn(msg.sender, _amount); // burns lp tokens
        payable(msg.sender).transfer(ethers);
        token.transfer(msg.sender, tokens);
        return (ethers, tokens);
    }

    /// @notice                         Facilitates token-to-token swaps via 
    ///                                 rerouting ethers to different exchange contract
    /// @param _tokenSold               Amount of tokens being sold for ether
    /// @param _baseTokensRequested     Minimum number of tokens requested to execute purchase order
    /// @param _tokenAddress            Address of tokens to be purchased
    function tokenSwap(uint256 _tokenSold, uint256 _baseTokensRequested, address _tokenAddress) public {
        address exchangeAddress = IFactory(factoryAddress).getExchange(_tokenAddress);
        require(exchangeAddress != address(this) && exchangeAddress != address(0), "Exchange address must exist and can't be the same token's exchange");
        
    }             
}