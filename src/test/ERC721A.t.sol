// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./utils/mocks/MockERC721A.sol";

contract TestERC721A is BaseTest {
    MockERC721A internal erc721a;
    address internal alice;
    address internal bob;

    function setUp() public {
        alice = getRandomAddress(1);
        bob = getRandomAddress(2);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        erc721a = new MockERC721A("testname", "testsymbol", "https://example.com/12345/");
        vm.label(address(erc721a), "ERC721A");
        vm.label(address(this), "TestERC721A");
    }

    function testDeployGas() public {
        unchecked {
            new MockERC721A("abcdefg", "xyz", "https://example.com/12345/");
        }
    }

    function testSafeMintGas1() public {
        unchecked {
            erc721a.safeMint(alice, 1);
        }
    }

    function testSafeMintGas2() public {
        unchecked {
            erc721a.safeMint(alice, 2);
        }
    }

    function testSafeMintGas3() public {
        unchecked {
            erc721a.safeMint(alice, 3);
        }
    }

    function testSafeMintGas4() public {
        unchecked {
            erc721a.safeMint(alice, 4);
        }
    }

    function testSafeMintGas5() public {
        unchecked {
            erc721a.safeMint(alice, 5);
        }
    }

    function testSafeMintGasA() public {
        unchecked {
            erc721a.safeMint(alice, 10);
        }
    }

    function testTransferFromGas() public {
        address from = getRandomAddress(69420);
        address to = getRandomAddress(420123);
        vm.startPrank(from);

        erc721a.safeMint(from, 2);

        startMeasuringGas("First transfer");
        erc721a.transferFrom(from, to, 1);
        stopMeasuringGas();

        assertEq(erc721a.balanceOf(from), 1);
        assertEq(erc721a.balanceOf(to), 1);

        startMeasuringGas("Second transfer");
        erc721a.transferFrom(from, to, 2);
        stopMeasuringGas();

        assertEq(erc721a.balanceOf(from), 0);
        assertEq(erc721a.balanceOf(to), 2);
    }

    function testSafeTransferFromGas() public {
        address from = getRandomAddress(42069);
        address to = getRandomAddress(69000);
        vm.startPrank(from);

        erc721a.safeMint(from, 2);

        startMeasuringGas("First transfer");
        erc721a.safeTransferFrom(from, to, 1);
        stopMeasuringGas();

        assertEq(erc721a.balanceOf(from), 1);
        assertEq(erc721a.balanceOf(to), 1);

        startMeasuringGas("Second transfer");
        erc721a.safeTransferFrom(from, to, 2);
        stopMeasuringGas();
    }

    function testSafeMint(uint256 amount) public {
        vm.assume(amount > 0 && amount < type(uint128).max);
        erc721a.safeMint(alice, amount);
        assertEq(erc721a.balanceOf(alice), amount);
    }

    function testSafeMint() public {
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidRecipient.selector);
        erc721a.safeMint(address(0), amount);
        vm.expectRevert(ERC721A.invalidAmount.selector);
        erc721a.safeMint(alice, 0);

        erc721a.safeMint(alice, amount);
        assertEq(erc721a.balanceOf(alice), amount);
    }

    function testTotalSupply() public {
        uint256 startSupply = 0;
        uint256 amount = 5;

        assertEq(erc721a.totalSupply(), startSupply);

        erc721a.safeMint(alice, amount);
        assertEq(erc721a.totalSupply(), startSupply + amount);

        // TODO: add and test burn
    }

    function testTokenOfOwnerByIndex() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidIndex.selector);
        erc721a.tokenOfOwnerByIndex(alice, 0);

        erc721a.safeMint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.tokenOfOwnerByIndex(alice, i), startId++);
        }
    }

    function testTokenByIndex() public {
        uint256 startIndex = 1;
        uint256 amount = 1;

        vm.expectRevert(ERC721A.invalidIndex.selector);
        erc721a.tokenByIndex(startIndex);

        erc721a.safeMint(alice, amount);
        assertEq(erc721a.tokenByIndex(startIndex), startIndex);
    }

    function testBalanceOf() public {
        // uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidOwner.selector);
        erc721a.balanceOf(address(0));

        assertEq(erc721a.balanceOf(alice), 0);
        erc721a.safeMint(alice, amount);
        assertEq(erc721a.balanceOf(alice), amount);
    }

    function testOwnerOf() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.ownerOf(0);
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.ownerOf(1);

        erc721a.safeMint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(startId + i), alice);
        }
    }
}
