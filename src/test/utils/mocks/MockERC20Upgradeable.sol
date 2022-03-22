// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../upgradable/tokens/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MockERC20Upgradeable is ERC20Upgradeable {
    function initialize() external initializer {
        __ERC20_init("TestName", "TestSymbol", 18);
    }

    function mint(address to, uint256 amount) external payable {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external payable {
        _burn(from, amount);
    }
}
