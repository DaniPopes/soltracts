// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../access/Ownable.sol";

contract MockOwnable is Ownable {
    function call() external view onlyOwner {}
}
