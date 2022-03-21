// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import { MockERC721Batch } from "./utils/mocks/MockERC721Batch.sol";

contract TestERC721ABatch is BaseTest {
    MockERC721Batch private erc721aBatch;

    function setUp() public {
        erc721aBatch = new MockERC721Batch();

        vm.label(address(erc721aBatch), "ERC721ABatch");
        vm.label(address(this), "TestERC721ABatch");
    }

    uint256 internal constant amount = 50;

    // average: 29000-30500 per token
    function test_batchTransferFrom() public {
        vm.startPrank(alice);

        // mint amount to alice
        erc721aBatch.safeMint(alice, amount);

        // make id array
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = i + 1;
        }

        // batch transfer all ids to bob
        uint256 g = gasleft();
        erc721aBatch.batchTransferFrom(alice, bob, ids);
        g -= gasleft();
        console.log("Transfer gas", g);
        console.log("Average", g / amount);

        // check it was successful
        assertEq(erc721aBatch.balanceOf(alice), 0);
        assertEq(erc721aBatch.balanceOf(bob), amount);

        for (uint256 i; i < amount; i++) {
            assertEq(erc721aBatch.ownerOf(ids[i]), bob);
        }
    }

    function test_batchTransferFromArray() public {
        vm.startPrank(alice);

        // mint amount to alice
        erc721aBatch.safeMint(alice, amount);

        // make id array
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = i + 1;
        }

        // make to address array
        address[] memory to = new address[](amount);
        for (uint256 i; i < amount; i++) {
            to[i] = getRandomAddress(i + 12345);
        }

        // batch transfer all ids to the to address array
        erc721aBatch.batchTransferFrom(alice, to, ids);

        // check it was successful
        assertEq(erc721aBatch.balanceOf(alice), 0);

        for (uint256 i; i < amount; i++) {
            address addy = to[i];
            assertEq(erc721aBatch.balanceOf(addy), 1);
            assertEq(erc721aBatch.ownerOf(ids[i]), addy);
        }
    }

    function test_batchSafeTransferFrom() public {
        vm.startPrank(alice);

        // mint amount to alice
        erc721aBatch.safeMint(alice, amount);

        // make id array
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = i + 1;
        }

        // batch transfer all ids to bob
        uint256 g = gasleft();
        erc721aBatch.batchSafeTransferFrom(alice, bob, ids, "");
        g -= gasleft();
        console.log("Transfer gas", g);
        console.log("Average", g / amount);

        // check it was successful
        assertEq(erc721aBatch.balanceOf(alice), 0);
        assertEq(erc721aBatch.balanceOf(bob), amount);

        for (uint256 i; i < amount; i++) {
            assertEq(erc721aBatch.ownerOf(ids[i]), bob);
        }
    }

    function test_batchSafeTransferFromArray() public {
        vm.startPrank(alice);

        // mint amount to alice
        erc721aBatch.safeMint(alice, amount);

        // make id array
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = i + 1;
        }

        // make to address array
        address[] memory to = new address[](amount);
        for (uint256 i; i < amount; i++) {
            to[i] = getRandomAddress(i + 12345);
        }

        // batch transfer all ids to the to address array
        erc721aBatch.batchSafeTransferFrom(alice, to, ids, "");

        // check it was successful
        assertEq(erc721aBatch.balanceOf(alice), 0);

        for (uint256 i; i < amount; i++) {
            address addy = to[i];
            assertEq(erc721aBatch.balanceOf(addy), 1);
            assertEq(erc721aBatch.ownerOf(ids[i]), addy);
        }
    }

    function testGas_deploy() public {
        new MockERC721Batch();
    }
}
