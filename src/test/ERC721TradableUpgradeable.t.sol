// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./ERC721Tradable.t.sol";
import "./utils/mocks/MockERC721TradableUpgradeable.sol";

contract TestERC721TradableUpgradeable is TestERC721Tradable {
    MockERC721TradableUpgradeable internal logic;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public override {
        proxyRegistry = new MockProxyRegistry();
        transferManagerERC721 = new MockTransferManagerERC721();
        logic = new MockERC721TradableUpgradeable();
        proxy = new TransparentUpgradeableProxy(
            address(logic),
            DEAD_ADDRESS,
            abi.encodeWithSignature(
                "initialize(address,address)",
                address(proxyRegistry),
                address(transferManagerERC721)
            )
        );
        erc721aTradable = MockERC721Tradable(address(proxy));

        vm.label(address(logic), "Logic");
        vm.label(address(proxy), "Proxy");
        vm.label(address(this), "TestERC721TradableUpgradeable");
    }
}
