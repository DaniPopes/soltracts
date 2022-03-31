// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./ERC20.t.sol";
import "./utils/mocks/MockERC20Upgradeable.sol";

contract TestERC20Upgradeable is TestERC20 {
    MockERC20Upgradeable internal logic;
    TransparentUpgradeableProxy internal proxy;

    function setUp() public override {
        logic = new MockERC20Upgradeable();
        proxy = new TransparentUpgradeableProxy(
            address(logic),
            DEAD_ADDRESS,
            abi.encodeWithSignature("initialize()")
        );
        token = MockERC20(address(proxy));

        vm.label(address(logic), "Logic");
        vm.label(address(proxy), "Proxy");
        vm.label(address(this), "TestERC20Upgradeable");
    }

    function testGas_deploy() public override {
        uint256 g = gasleft();
        address t = address(new MockERC20Upgradeable());
        uint256 g2 = gasleft();
        new TransparentUpgradeableProxy(t, bob, abi.encodeWithSignature("initialize()"));
        uint256 g3 = gasleft();

        console.log("Logic gas", g - g2);
        console.log("Proxy gas", g2 - g3);
        console.log("Total gas", (g - g2) + (g2 - g3));
    }
}
