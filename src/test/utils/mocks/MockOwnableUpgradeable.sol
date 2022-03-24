// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../upgradeable/access/OwnableUpgradeable.sol";

contract MockOwnableUpgradeable is OwnableUpgradeable {
    function initialize() external initializer {
        __Ownable_init();
    }

    function call() external view onlyOwner {}
}
