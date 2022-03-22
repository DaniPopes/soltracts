// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./ERC721A.t.sol";
import "./utils/mocks/MockERC721AUpgradeable.sol";

contract TestERC721AUpgradeable is TestERC721A {
    MockERC721AUpgradeable internal logic;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public override {
        logic = new MockERC721AUpgradeable();
        proxy = new TransparentUpgradeableProxy(
            address(logic),
            DEAD_ADDRESS,
            abi.encodeWithSignature("initialize()")
        );
        erc721a = MockERC721A(address(proxy));

        vm.label(address(logic), "Logic");
        vm.label(address(proxy), "Proxy");
        vm.label(address(this), "TestERC721AUpgradeable");
    }
}
