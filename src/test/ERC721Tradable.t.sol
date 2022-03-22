// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import { MockProxyRegistry } from "./utils/mocks/MockProxyRegistry.sol";
import { MockERC721Tradable } from "./utils/mocks/MockERC721Tradable.sol";
import { MockTransferManagerERC721 } from "./utils/mocks/MockTransferManagerERC721.sol";

contract TestERC721Tradable is BaseTest {
    MockERC721Tradable internal erc721aTradable;
    MockProxyRegistry internal proxyRegistry;
    MockTransferManagerERC721 internal transferManagerERC721;

    function setUp() public virtual {
        proxyRegistry = new MockProxyRegistry();
        transferManagerERC721 = new MockTransferManagerERC721();
        erc721aTradable = new MockERC721Tradable(
            address(proxyRegistry),
            address(transferManagerERC721)
        );

        vm.label(address(proxyRegistry), "OpenSea Proxy Registry");
        vm.label(address(transferManagerERC721), "LooksRare Transfer Manager (ERC721)");
        vm.label(address(erc721aTradable), "ERC721ATradable");
        vm.label(address(this), "TestERC721Tradable");
    }

    function test_marketplaceApprovalForAll() public {
        vm.startPrank(alice);

        erc721aTradable.safeMint(alice, 5);

        address proxy = proxyRegistry.registerProxy(alice);

        assertTrue(erc721aTradable.isApprovedForAll(alice, proxy));
        assertTrue(erc721aTradable.isApprovedForAll(alice, address(transferManagerERC721)));

        erc721aTradable.setMarketplaceApprovalForAll(false);

        assertFalse(erc721aTradable.isApprovedForAll(alice, proxy));
        assertFalse(erc721aTradable.isApprovedForAll(alice, address(transferManagerERC721)));

        erc721aTradable.setApprovalForAll(proxy, true);
        erc721aTradable.setApprovalForAll(address(transferManagerERC721), true);

        assertTrue(erc721aTradable.isApprovedForAll(alice, proxy));
        assertTrue(erc721aTradable.isApprovedForAll(alice, address(transferManagerERC721)));
    }

    function testGas_deploy() public {
        new MockERC721Tradable(alice, bob);
    }
}
