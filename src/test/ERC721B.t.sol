// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./utils/mocks/MockERC721B.sol";

contract TestERC721B is BaseTest {
    MockERC721B internal erc721b;

    function setUp() public virtual {
        erc721b = new MockERC721B("testname", "testsymbol", "https://example.com/12345/");
        vm.label(address(erc721b), "ERC721B");
        vm.label(address(this), "TestERC721B");
    }

    function test_mint() public {
        uint256 amount = 5;

        vm.expectRevert(ERC721B.invalidRecipient.selector);
        erc721b.mint(address(0), amount);
        vm.expectRevert(ERC721B.invalidAmount.selector);
        erc721b.mint(alice, 0);

        erc721b.mint(alice, amount);
        assertEq(erc721b.balanceOf(alice), amount);
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
        erc721b.safeMint(address(this), amount);
    }

    function test_totalSupply() public {
        uint256 startSupply = 0;
        uint256 amount = 5;

        assertEq(erc721b.totalSupply(), startSupply);

        erc721b.mint(alice, amount);
        assertEq(erc721b.totalSupply(), startSupply + amount);

        // TODO: add and test burn
    }

    function test_tokenOfOwnerByIndex() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721B.invalidIndex.selector);
        erc721b.tokenOfOwnerByIndex(alice, 0);

        erc721b.mint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721b.tokenOfOwnerByIndex(alice, i), startId++);
        }
    }

    function test_tokenByIndex() public {
        uint256 startIndex = 1;
        uint256 amount = 1;

        vm.expectRevert(ERC721B.invalidIndex.selector);
        erc721b.tokenByIndex(startIndex);

        erc721b.mint(alice, amount);
        assertEq(erc721b.tokenByIndex(startIndex), startIndex);
    }

    function test_balanceOf() public {
        // uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721B.invalidOwner.selector);
        erc721b.balanceOf(address(0));

        assertEq(erc721b.balanceOf(alice), 0);
        erc721b.mint(alice, amount);
        assertEq(erc721b.balanceOf(alice), amount);
    }

    function test_ownerOf() public {
        uint256 startId = 1;
        uint256 amount = 5;

        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721b.ownerOf(0);
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721b.ownerOf(1);

        erc721b.mint(alice, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721b.ownerOf(startId + i), alice);
        }
    }

    function test_transferFrom() public {
        vm.startPrank(alice);

        // doesn't exist
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721b.transferFrom(alice, bob, 0);
        // not minted yet
        vm.expectRevert(ERC721.nonExistentToken.selector);
        erc721b.transferFrom(alice, bob, 1);

        // mint id 1,2 to alice
        erc721b.mint(alice, 2);
        // not owner of ids
        vm.stopPrank();
        vm.startPrank(bob);
        vm.expectRevert(ERC721B.wrongFrom.selector);
        erc721b.transferFrom(bob, alice, 1);
        vm.expectRevert(ERC721B.wrongFrom.selector);
        erc721b.transferFrom(bob, alice, 2);
        vm.stopPrank();

        vm.startPrank(alice);
        // assert balances and owners after mint
        uint256 aliceBalance = erc721b.balanceOf(alice);
        uint256 bobBalance = erc721b.balanceOf(bob);
        address owner1 = erc721b.ownerOf(1);
        address owner2 = erc721b.ownerOf(2);
        assertEq(aliceBalance, 2);
        assertEq(bobBalance, 0);
        assertEq(owner1, alice);
        assertEq(owner2, alice);

        // xfr to address(0)
        vm.expectRevert(ERC721B.invalidRecipient.selector);
        erc721b.transferFrom(alice, address(0), 1);

        // transfer id 1 to bob
        erc721b.transferFrom(alice, bob, 1);

        aliceBalance = erc721b.balanceOf(alice);
        bobBalance = erc721b.balanceOf(bob);
        owner1 = erc721b.ownerOf(1);
        owner2 = erc721b.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, bob);
        assertEq(owner2, alice);

        // transfer id 2 to bob
        erc721b.transferFrom(alice, bob, 2);

        aliceBalance = erc721b.balanceOf(alice);
        bobBalance = erc721b.balanceOf(bob);
        owner1 = erc721b.ownerOf(1);
        owner2 = erc721b.ownerOf(2);
        assertEq(aliceBalance, 0);
        assertEq(bobBalance, 2);
        assertEq(owner1, bob);
        assertEq(owner2, bob);
    }

    function test_safeTransferFrom() public {
        vm.startPrank(alice);

        uint256 id = 1;
        erc721b.mint(alice, 1);

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
        erc721b.safeTransferFrom(alice, address(this), id);
    }

    function test_approvals() public {
        // mint id 1,2 to bob
        erc721b.mint(bob, 2);

        // bob approves alice to transfer id 2
        vm.prank(bob);
        erc721b.approve(alice, 2);

        assertEq(erc721b.getApproved(1), address(0));
        assertEq(erc721b.getApproved(2), alice);

        vm.startPrank(alice);
        // fail to transfer id 1 as not approved for it
        vm.expectRevert(ERC721.notAuthorized.selector);
        erc721b.transferFrom(bob, alice, 1);

        // transfer id 2 using alice from bob to alice
        erc721b.transferFrom(bob, alice, 2);

        // check approval has been removed
        assertEq(erc721b.getApproved(1), address(0));
        assertEq(erc721b.getApproved(2), address(0));

        // check token transferred correctly
        uint256 aliceBalance = erc721b.balanceOf(alice);
        uint256 bobBalance = erc721b.balanceOf(bob);
        address owner1 = erc721b.ownerOf(1);
        address owner2 = erc721b.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, bob);
        assertEq(owner2, alice);
    }

    function test_approvalForAll() public {
        // mint id 1,2 to bob
        erc721b.mint(bob, 2);

        // bob approves alice for all ids
        vm.prank(bob);
        erc721b.setApprovalForAll(alice, true);

        assertTrue(erc721b.isApprovedForAll(bob, alice));

        vm.startPrank(alice);
        // transfer id 1 using alice from bob to alice
        erc721b.transferFrom(bob, alice, 1);

        // check token transferred correctly
        uint256 aliceBalance = erc721b.balanceOf(alice);
        uint256 bobBalance = erc721b.balanceOf(bob);
        address owner1 = erc721b.ownerOf(1);
        address owner2 = erc721b.ownerOf(2);
        assertEq(aliceBalance, 1);
        assertEq(bobBalance, 1);
        assertEq(owner1, alice);
        assertEq(owner2, bob);

        // revoke approval
        vm.stopPrank();
        vm.prank(bob);
        erc721b.setApprovalForAll(alice, false);

        assertFalse(erc721b.isApprovedForAll(bob, alice));

        // now fails with the other token because not approved anymore
        vm.startPrank(alice);
        vm.expectRevert(ERC721.notAuthorized.selector);
        erc721b.transferFrom(bob, alice, 2);
    }

    function testGas_deploy() public {
        unchecked {
            new MockERC721B("abcdefg", "xyz", "https://example.com/12345/");
        }
    }

    function testGas_mint() public {
        // start slots warm
        startMeasuringGas("First mint");
        erc721b.mint(address(69), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 1");
        erc721b.mint(address(1), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 2");
        erc721b.mint(address(2), 2);
        stopMeasuringGas();

        startMeasuringGas("Mint 3");
        erc721b.mint(address(3), 3);
        stopMeasuringGas();

        startMeasuringGas("Mint 4");
        erc721b.mint(address(4), 4);
        stopMeasuringGas();

        startMeasuringGas("Mint 5");
        erc721b.mint(address(5), 5);
        stopMeasuringGas();

        startMeasuringGas("Mint 10");
        erc721b.mint(address(10), 10);
        stopMeasuringGas();
    }

    function testGas_safeMint() public {
        // start slots warm
        startMeasuringGas("First mint");
        erc721b.safeMint(address(69), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 1");
        erc721b.safeMint(address(1), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 2");
        erc721b.safeMint(address(2), 2);
        stopMeasuringGas();

        startMeasuringGas("Mint 3");
        erc721b.safeMint(address(3), 3);
        stopMeasuringGas();

        startMeasuringGas("Mint 4");
        erc721b.safeMint(address(4), 4);
        stopMeasuringGas();

        startMeasuringGas("Mint 5");
        erc721b.safeMint(address(5), 5);
        stopMeasuringGas();

        startMeasuringGas("Mint 10");
        erc721b.safeMint(address(10), 10);
        stopMeasuringGas();
    }

    function testGas_transferFrom() public {
        vm.startPrank(alice);

        erc721b.mint(alice, 2);

        startMeasuringGas("First transfer");
        erc721b.transferFrom(alice, bob, 1);
        stopMeasuringGas();

        startMeasuringGas("Second transfer");
        erc721b.transferFrom(alice, bob, 2);
        stopMeasuringGas();
    }

    function testGas_safeTransferFrom() public {
        vm.startPrank(alice);

        erc721b.mint(alice, 2);

        startMeasuringGas("First transfer");
        erc721b.safeTransferFrom(alice, bob, 1);
        stopMeasuringGas();

        startMeasuringGas("Second transfer");
        erc721b.safeTransferFrom(alice, bob, 2);
        stopMeasuringGas();
    }
}
