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

    function test_mint() public {
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidRecipient.selector);
        erc721a.mint(address(0), amount);
        vm.expectRevert(ERC721A.invalidAmount.selector);
        erc721a.mint(alice, 0);

        erc721a.mint(alice, amount);
        assertEq(erc721a.balanceOf(alice), amount);
    }

    function test_safeMint() public {
        uint256 startId = 1;
        uint256 amount = 5;

        // vm.expectCall(address(this), abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"));
        // strict match
        for (uint256 i; i < amount; i++) {
            vm.expectCall(
                address(this),
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    address(this),
                    address(0),
                    startId + i,
                    ""
                )
            );
        }
        erc721a.safeMint(address(this), amount);
    }

    function test_totalSupply() public {
        uint256 startSupply = 0;
        uint256 amount = 5;

        assertEq(erc721a.totalSupply(), startSupply);

        erc721a.mint(alice, amount);
        assertEq(erc721a.totalSupply(), startSupply + amount);

        // TODO: add and test burn
    }

    function test_tokenOfOwnerByIndex() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidIndex.selector);
        erc721a.tokenOfOwnerByIndex(alice, 0);

        erc721a.mint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.tokenOfOwnerByIndex(alice, i), startId++);
        }
    }

    function test_tokenByIndex() public {
        uint256 startIndex = 1;
        uint256 amount = 1;

        vm.expectRevert(ERC721A.invalidIndex.selector);
        erc721a.tokenByIndex(startIndex);

        erc721a.mint(alice, amount);
        assertEq(erc721a.tokenByIndex(startIndex), startIndex);
    }

    function test_balanceOf() public {
        // uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721A.invalidOwner.selector);
        erc721a.balanceOf(address(0));

        assertEq(erc721a.balanceOf(alice), 0);
        erc721a.mint(alice, amount);
        assertEq(erc721a.balanceOf(alice), amount);
    }

    function test_ownerOf() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.ownerOf(0);
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.ownerOf(1);

        erc721a.mint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(startId + i), alice);
        }
    }

    function test_transferFrom() public {
        vm.startPrank(alice);

        // doesn't exist
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.transferFrom(alice, bob, 0);
        // not minted yet
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721a.transferFrom(alice, bob, 1);

        // mint id 1,2 to alice
        erc721a.mint(alice, 2);
        // not owner of ids
        vm.stopPrank();
        vm.startPrank(bob);
        vm.expectRevert(ERC721A.wrongFrom.selector);
        erc721a.transferFrom(bob, alice, 1);
        vm.expectRevert(ERC721A.wrongFrom.selector);
        erc721a.transferFrom(bob, alice, 2);
        vm.stopPrank();

        vm.startPrank(alice);
        // assert balances and owners after mint
        uint256 aliceBalance = erc721a.balanceOf(alice);
        uint256 bobBalance = erc721a.balanceOf(bob);
        address owner1 = erc721a.ownerOf(1);
        address owner2 = erc721a.ownerOf(2);
        assertEq(aliceBalance, 2);
        assertEq(bobBalance, 0);
        assertEq(owner1, alice);
        assertEq(owner2, alice);

        // xfr to address(0)
        vm.expectRevert(ERC721A.invalidRecipient.selector);
        erc721a.transferFrom(alice, address(0), 1);

        // transfer id 1 to bob
        erc721a.transferFrom(alice, bob, 1);

        aliceBalance = erc721a.balanceOf(alice);
        bobBalance = erc721a.balanceOf(bob);
        owner1 = erc721a.ownerOf(1);
        owner2 = erc721a.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, bob);
        assertEq(owner2, alice);

        // transfer id 2 to bob
        erc721a.transferFrom(alice, bob, 2);

        aliceBalance = erc721a.balanceOf(alice);
        bobBalance = erc721a.balanceOf(bob);
        owner1 = erc721a.ownerOf(1);
        owner2 = erc721a.ownerOf(2);
        assertEq(aliceBalance, 0);
        assertEq(bobBalance, 2);
        assertEq(owner1, bob);
        assertEq(owner2, bob);
    }

    function test_safeTransferFrom() public {
        vm.startPrank(alice);

        uint256 id = 1;
        erc721a.mint(alice, 1);

        vm.expectCall(
            address(this),
            abi.encodeWithSignature(
                "onERC721Received(address,address,uint256,bytes)",
                alice,
                alice,
                id,
                ""
            )
        );
        erc721a.safeTransferFrom(alice, address(this), id);
    }

    function test_approvals() public {
        // mint id 1,2 to bob
        erc721a.mint(bob, 2);

        // bob approves alice to transfer id 2
        vm.prank(bob);
        erc721a.approve(alice, 2);

        assertEq(erc721a.getApproved(1), address(0));
        assertEq(erc721a.getApproved(2), alice);

        vm.startPrank(alice);
        // fail to transfer id 1 as not approved for it
        vm.expectRevert(ERC721.notAuthorized.selector);
        erc721a.transferFrom(bob, alice, 1);

        // transfer id 2 using alice from bob to alice
        erc721a.transferFrom(bob, alice, 2);

        // check approval has been removed
        assertEq(erc721a.getApproved(1), address(0));
        assertEq(erc721a.getApproved(2), address(0));

        // check token transferred correctly
        uint256 aliceBalance = erc721a.balanceOf(alice);
        uint256 bobBalance = erc721a.balanceOf(bob);
        address owner1 = erc721a.ownerOf(1);
        address owner2 = erc721a.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, bob);
        assertEq(owner2, alice);
    }

    function test_approvalForAll() public {
        // mint id 1,2 to bob
        erc721a.mint(bob, 2);

        // bob approves alice for all ids
        vm.prank(bob);
        erc721a.setApprovalForAll(alice, true);

        assertTrue(erc721a.isApprovedForAll(bob, alice));

        vm.startPrank(alice);
        // transfer id 1 using alice from bob to alice
        erc721a.transferFrom(bob, alice, 1);

        // check token transferred correctly
        uint256 aliceBalance = erc721a.balanceOf(alice);
        uint256 bobBalance = erc721a.balanceOf(bob);
        address owner1 = erc721a.ownerOf(1);
        address owner2 = erc721a.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, alice);
        assertEq(owner2, bob);

        // revoke approval
        vm.stopPrank();
        vm.prank(bob);
        erc721a.setApprovalForAll(alice, false);

        assertFalse(erc721a.isApprovedForAll(bob, alice));

        // now fails with the other token because not approved anymore
        vm.startPrank(alice);
        vm.expectRevert(ERC721.notAuthorized.selector);
        erc721a.transferFrom(bob, alice, 2);
    }

    function testGas_deploy() public {
        unchecked {
            new MockERC721A("abcdefg", "xyz", "https://example.com/12345/");
        }
    }

    function testGas_safeMint1() public {
        unchecked {
            erc721a.mint(alice, 1);
        }
    }

    function testGas_safeMint2() public {
        unchecked {
            erc721a.mint(alice, 2);
        }
    }

    function testGas_safeMint3() public {
        unchecked {
            erc721a.mint(alice, 3);
        }
    }

    function testGas_safeMint4() public {
        unchecked {
            erc721a.mint(alice, 4);
        }
    }

    function testGas_safeMint5() public {
        unchecked {
            erc721a.mint(alice, 5);
        }
    }

    function testGas_safeMintA() public {
        unchecked {
            erc721a.mint(alice, 10);
        }
    }

    function testGas_transferFrom() public {
        vm.startPrank(alice);

        erc721a.mint(alice, 2);

        startMeasuringGas("First transfer");
        erc721a.transferFrom(alice, bob, 1);
        stopMeasuringGas();

        startMeasuringGas("Second transfer");
        erc721a.transferFrom(alice, bob, 2);
        stopMeasuringGas();
    }

    function testGas_safeTransferFrom() public {
        vm.startPrank(alice);

        erc721a.mint(alice, 2);

        startMeasuringGas("First transfer");
        erc721a.safeTransferFrom(alice, bob, 1);
        stopMeasuringGas();

        startMeasuringGas("Second transfer");
        erc721a.safeTransferFrom(alice, bob, 2);
        stopMeasuringGas();
    }
}
