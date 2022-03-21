// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/stdlib.sol";
import { console } from "forge-std/console.sol";
import { DSTestPlus } from "solmate/test/utils/DSTestPlus.sol";

abstract contract BaseTest is DSTestPlus, stdCheats {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function getRandomAddress(uint256 salt) internal virtual returns (address) {
        return address(uint160(getRandom256(salt)));
    }

    function getRandom256(uint256 salt) internal virtual returns (uint256) {
        return uint256(keccak256(abi.encodePacked(salt)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
