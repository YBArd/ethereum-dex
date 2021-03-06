//// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title                      A basic token
/// @author                     Yuval B. Ardenbaum
/// @notice                     Implements an ERC20-type token
contract Token is Ownable {

    /// FIELDS ///

    string public name; // token name
    string public symbol; // token symbol/ticker
    uint256 public decimals; // Number of decimals 
    uint256 public totalSupply; // total supply of token

    /// MAPPINGS ///

    mapping (address => uint256) public balanceOf; // token balances of accounts
    mapping (address => mapping(address => uint256)) public allowance; // mapping of accounts approved by each holder to spend

    /// EVENTS ///

    /// @notice                 Emitted when tokens are transferred from one address to another
    /// @param from             The sender' address
    /// @param to               The recipient's address
    /// @param value            The value of tokens to be transferred
    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    ); 

    /// @notice                 Emitted when an address is approved to spend tokens on the caller's behalf
    /// @param owner            Owner of the tokens
    /// @param spender          Address approved to spend caller's tokens
    /// @param value            Value of tokens spender is approved to spend
    event Approval(
        address indexed owner, 
        address indexed spender, 
        uint256 value
    ); 

    /// CONSTRUCTORS ///

    /// @notice                 Constructor to initialize token instance
    /// @dev                    Initializes the totalSupply as being owned by contract deployer    
    /// @param _name            The name of the token
    /// @param _symbol          The symbol of the token
    /// @param _decimals        The number of decimal places (the base unit)
    /// @param _totalSupply     The total existing supply of tokens
    constructor(string memory _name, string memory _symbol, uint _decimals, uint _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
    }

    /// FUNCTIONS ///

    /// @notice                 External function to call _transfer with a certain value of tokens from one address to another
    /// @dev                    Requires balance of sender to be greater than or equal to the value to be transferred 
    /// @param _to              The recipient address
    /// @param _value           The value of tokens to be transferred
    /// @return success         Returns true if transfer successful
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }  

    /// @notice                 Subtracts value of tokens from sender's balance and adds to recipient's balance
    /// @dev                    Requires that recipient can't be 0 address    
    /// @param _from            Sender address
    /// @param _to              Recipient address
    /// @param _value           Value of tokens being transferred
    /// @return success         Returns true if successful         
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));
        balanceOf[_from] = balanceOf[_from] - (_value);
        balanceOf[_to] = balanceOf[_to] + (_value);
        emit Transfer(_from, _to, _value);
    }

    /// @notice                 Approves an address to spend on the caller address's behalf
    /// @dev                    Requires that the spender's address is not the 0 address
    /// @param _spender         The address approved to spend on behalf of caller address
    /// @param _value           The value that the spender is approved to spend
    /// @return bool            Returns true if approval successful
    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice                 Approved spender transfers tokens up to approved value from one address to another
    /// @param _from            Sender's address
    /// @param _to              Recipient's address
    /// @param _value           Value of tokens transferred
    /// @return bool            Returns true if transfer successful
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        return true;
    }

    /// @notice                 External function to call _mint                
    /// @param account          Recipient address of minted tokens
    /// @param amount           Amount of tokens to be minted to account
    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Minting to zero address burns the tokens");
        _mint(account, amount);
    }

    /// @notice                 Mints tokens from zero address to recipient 
    /// @param account          Recipient address of minted tokens
    /// @param amount           Amount of tokens to be minted to account
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Minting to zero address burns the tokens");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /// @notice                 Returns total supply of token
    /*function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }*/

    /// @notice                  External function to call _burn
    function burn(address account, uint256 amount) external {
        require(account != address(0), "Can't burn tokens at the zero address");
        _burn(account, amount);
    }

    /// @notice                 Burns tokens from given account by transferring them to zero address
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Can't burn tokens at the zero address");
        uint256 accBalance = balanceOf[account];
        require(accBalance >= amount, "Cannot burn more than balance of account");

        unchecked {
            balanceOf[account] = accBalance - amount;
        }

        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}