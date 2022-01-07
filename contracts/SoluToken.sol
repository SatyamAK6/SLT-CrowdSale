pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract SoluToken is ERC20, ERC20Detailed  {
    constructor(uint256 _initialSupply) ERC20Detailed('SoluToken', 'SLT', 18) public {
        _mint(msg.sender, _initialSupply * 10 ** 18);
    }
}