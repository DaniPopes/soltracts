// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/mocks/MockOwnableUpgradeable.sol";
import { MockOwnable, TestOwnable } from "./Ownable.t.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TestOwnableUpgradeable is TestOwnable {
    MockOwnableUpgradeable internal logic;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public override {
        logic = new MockOwnableUpgradeable();
        vm.prank(alice, alice);
        proxy = new TransparentUpgradeableProxy(
            address(logic),
            DEAD_ADDRESS,
            abi.encodeWithSignature("initialize()")
        );
        mock = MockOwnable(address(proxy));

        vm.label(address(logic), "Logic");
        vm.label(address(proxy), "Proxy");
        vm.label(address(this), "TestOwnableUpgradeable");
    }
}
