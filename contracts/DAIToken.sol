//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract DAIToken is ERC20 {
    constructor() ERC20("DAIToken", "DAI") {
        _mint(msg.sender, 100 * 10**uint256(decimals()));
    }

    function mint(address _address, uint256 _amount) external {
        _mint(_address, _amount);
    }
}
