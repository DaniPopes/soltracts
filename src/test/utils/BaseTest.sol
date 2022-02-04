// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { DSTest } from "ds-test/test.sol";
import { Utilities } from "../utils/Utilities.sol";
import { Hevm } from "../utils/Hevm.sol";

import { DSTestPlus } from "@rari-capital/solmate/src/test/utils/DSTestPlus.sol";

// solhint-disable no-empty-blocks

abstract contract BaseTest is DSTestPlus {
	Hevm internal immutable vm = Hevm(HEVM_ADDRESS);

	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure virtual returns (bytes4) {
		return this.onERC721Received.selector;
	}

	function onERC1155Received(
		address,
		address,
		uint256,
		uint256,
		bytes calldata
	) external pure virtual returns (bytes4) {
		return this.onERC1155Received.selector;
	}

	function onERC1155BatchReceived(
		address,
		address,
		uint256[] calldata,
		uint256[] calldata,
		bytes calldata
	) external virtual returns (bytes4) {
		return this.onERC1155BatchReceived.selector;
	}

	receive() external payable virtual {}

	fallback() external payable virtual {}

	function getRandom256(uint256 salt) internal pure virtual returns (uint256) {
		return uint256(keccak256(abi.encodePacked(salt)));
	}

	function getRandomAddress(uint256 salt) internal virtual returns (address) {
		return address(uint160(getRandom256(salt)));
	}
}
