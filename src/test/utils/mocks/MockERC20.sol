// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../tokens/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("TestName", "TestSymbol", 18) {}

    function mint(address to, uint256 amount) external payable {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external payable {
        _burn(from, amount);
    }
}
