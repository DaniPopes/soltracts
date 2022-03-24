// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "../access/Ownable.sol";

contract OwnableMock is Ownable {
    function call() external view onlyOwner {}
}

contract OwnableTest is BaseTest {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    OwnableMock internal mock;

    function setUp() public {
        vm.prank(alice);
        mock = new OwnableMock();
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

    function testFuzz_onlyOwner(address owner) public {
        vm.startPrank(owner);
        mock = new OwnableMock();
        assertEq(mock.owner(), owner);

        mock.call();
    }

    function testFailFuzz_notOwner(address owner, address caller) public {
        vm.assume(owner != caller);
        vm.prank(owner);
        mock = new OwnableMock();
        assertEq(mock.owner(), owner);

        vm.prank(caller);
        mock.call();
    }

    function test_transferOwnership(address from, address to) public {
        vm.assume(from != to);
        vm.startPrank(from);
        mock = new OwnableMock();
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(from, to);
        mock.transferOwnership(to);
        assertEq(mock.owner(), to);
    }
}
