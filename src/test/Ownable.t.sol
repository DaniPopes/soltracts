// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./utils/mocks/MockOwnable.sol";

contract TestOwnable is BaseTest {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    MockOwnable internal mock;

    function setUp() public virtual {
        vm.prank(alice);
        mock = new MockOwnable();
    }

    function test_onlyOwner() public {
        vm.prank(alice);
        mock.call();

        assertEq(mock.owner(), alice);
    }

    function testFail_notOwner() public {
        vm.prank(bob);
        mock.call();
    }

    function test_transferOwnership() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(alice, bob);
        mock.transferOwnership(bob);
        assertEq(mock.owner(), bob);
    }

    function testFailFuzz_notOwner(address caller) public {
        vm.prank(caller);
        mock.call();
    }

    function testFuzz_transferOwnership(address to) public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(alice, to);
        mock.transferOwnership(to);
        assertEq(mock.owner(), to);
    }
}
