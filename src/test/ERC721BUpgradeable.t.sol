// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./ERC721B.t.sol";
import "./utils/mocks/MockERC721BUpgradeable.sol";

contract TestERC721BUpgradeable is TestERC721B {
    MockERC721BUpgradeable internal logic;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public override {
        logic = new MockERC721BUpgradeable();
        proxy = new TransparentUpgradeableProxy(
            address(logic),
            DEAD_ADDRESS,
            abi.encodeWithSignature("initialize()")
        );
        erc721b = MockERC721B(address(proxy));

        vm.label(address(logic), "Logic");
        vm.label(address(proxy), "Proxy");
        vm.label(address(this), "TestERC721BUpgradeable");
    }
}
