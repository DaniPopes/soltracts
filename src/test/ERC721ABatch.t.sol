// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { console } from "./utils/Console.sol";
import { BaseTest } from "./utils/BaseTest.sol";
import { MockERC721Batch } from "./utils/mocks/MockERC721Batch.sol";

contract TestERC721ABatch is BaseTest {
	MockERC721Batch private erc721aBatch;

	function setUp() public {
		erc721aBatch = new MockERC721Batch("testname", "testsymbol");
	}

	function testDeployGas() public {
		unchecked {
			new MockERC721Batch("abcdefg", "xyz");
		}
	}

	uint256 internal constant amount = 50;

	// average: 29000-30500 per token
	function testBatchTransferFrom1() public {
		address to = getRandomAddress(69420);

		erc721aBatch.safeMint(address(this), amount);

		uint256[] memory ids = new uint256[](amount);
		for (uint256 i; i < amount; i++) {
			ids[i] = i + 1;
		}

		uint256 g = gasleft();
		erc721aBatch.batchTransferFrom(address(this), to, ids);
		g -= gasleft();
		console.log("Transfer gas", g);
		console.log("Average", g / amount);

		assertEq(erc721aBatch.balanceOf(address(this)), 0);
		assertEq(erc721aBatch.balanceOf(to), amount);

		for (uint256 i; i < amount; i++) {
			assertEq(erc721aBatch.ownerOf(ids[i]), to);
		}
	}

	function testBatchTransferFrom2() public {
		address[] memory to = new address[](amount);
		for (uint256 i; i < amount; i++) {
			to[i] = getRandomAddress(i + 12345);
		}

		erc721aBatch.safeMint(address(this), amount);

		uint256[] memory ids = new uint256[](amount);
		for (uint256 i; i < amount; i++) {
			ids[i] = i + 1;
		}

		erc721aBatch.batchTransferFrom(address(this), to, ids);

		assertEq(erc721aBatch.balanceOf(address(this)), 0);

		for (uint256 i; i < amount; i++) {
			address addy = to[i];
			assertEq(erc721aBatch.balanceOf(addy), 1);
			assertEq(erc721aBatch.ownerOf(ids[i]), addy);
		}
	}

	function testBatchSafeTransferFrom1() public {
		address to = getRandomAddress(69420);

		erc721aBatch.safeMint(address(this), amount);

		uint256[] memory ids = new uint256[](amount);
		for (uint256 i; i < amount; i++) {
			ids[i] = i + 1;
		}

		uint256 g = gasleft();
		erc721aBatch.batchSafeTransferFrom(address(this), to, ids, "");
		g -= gasleft();
		console.log("Transfer gas", g);
		console.log("Average", g / amount);

		assertEq(erc721aBatch.balanceOf(address(this)), 0);
		assertEq(erc721aBatch.balanceOf(to), amount);

		for (uint256 i; i < amount; i++) {
			assertEq(erc721aBatch.ownerOf(ids[i]), to);
		}
	}

	function testBatchSafeTransferFrom2() public {
		address[] memory to = new address[](amount);
		for (uint256 i; i < amount; i++) {
			to[i] = getRandomAddress(i + 12345);
		}

		erc721aBatch.safeMint(address(this), amount);

		uint256[] memory ids = new uint256[](amount);
		for (uint256 i; i < amount; i++) {
			ids[i] = i + 1;
		}

		erc721aBatch.batchSafeTransferFrom(address(this), to, ids, "");

		assertEq(erc721aBatch.balanceOf(address(this)), 0);

		for (uint256 i; i < amount; i++) {
			address addy = to[i];
			assertEq(erc721aBatch.balanceOf(addy), 1);
			assertEq(erc721aBatch.ownerOf(ids[i]), addy);
		}
	}
}
