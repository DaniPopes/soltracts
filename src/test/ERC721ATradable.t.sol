// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { console } from "./utils/Console.sol";
import { BaseTest } from "./utils/BaseTest.sol";
import { MockProxyRegistry } from "./utils/mocks/MockProxyRegistry.sol";
import { MockERC721Tradable } from "./utils/mocks/MockERC721Tradable.sol";
import { MockTransferManagerERC721 } from "./utils/mocks/MockTransferManagerERC721.sol";

contract TestERC721ATradable is BaseTest {
	MockERC721Tradable private erc721aTradable;
	MockProxyRegistry private proxyRegistry;
	MockTransferManagerERC721 private transferManagerERC721;

	function setUp() public {
		proxyRegistry = new MockProxyRegistry();
		transferManagerERC721 = new MockTransferManagerERC721();
		erc721aTradable = new MockERC721Tradable("testname", "testsymbol", address(proxyRegistry), address(transferManagerERC721));
	}

	function testDeployGas() public {
		unchecked {
			new MockERC721Tradable("abcdefg", "xyz", getRandomAddress(0x69), getRandomAddress(0x420));
		}
	}

	function testIsApprovedForAll() public {
		address from = address(0x69);
		vm.startPrank(from);

		erc721aTradable.safeMint(from, 5);

		address proxy = proxyRegistry.registerProxy(from);

		assertTrue(erc721aTradable.isApprovedForAll(from, proxy));
		assertTrue(erc721aTradable.isApprovedForAll(from, address(transferManagerERC721)));

		erc721aTradable.setMarketplaceApprovalForAll(false);

		assertFalse(erc721aTradable.isApprovedForAll(from, proxy));
		assertFalse(erc721aTradable.isApprovedForAll(from, address(transferManagerERC721)));

		erc721aTradable.setApprovalForAll(proxy, true);
		erc721aTradable.setApprovalForAll(address(transferManagerERC721), true);

		assertTrue(erc721aTradable.isApprovedForAll(from, proxy));
		assertTrue(erc721aTradable.isApprovedForAll(from, address(transferManagerERC721)));
	}
}
