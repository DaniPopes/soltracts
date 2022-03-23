// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./utils/mocks/MockERC721A.sol";

// import "solmate/test/ERC721.t.sol";
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/test/ERC721.t.sol)
contract ERC721Recipient is ERC721TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/test/ERC721.t.sol)
contract RevertingERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(ERC721TokenReceiver.onERC721Received.selector)));
    }
}

/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/test/ERC721.t.sol)
contract WrongReturnDataERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        return 0xCAFEBEEF;
    }
}

/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/test/ERC721.t.sol)
contract NonERC721Recipient {

}

contract TestERC721A is BaseTest {
    MockERC721A internal erc721a;

    function setUp() public virtual {
        erc721a = new MockERC721A();
        vm.label(address(erc721a), "ERC721A");
        vm.label(address(this), "TestERC721A");
    }

    function invariant_metadata() public {
        assertEq(erc721a.name(), "TestName");
        assertEq(erc721a.symbol(), "TestSymbol");
    }

    function test_mint() public {
        erc721a.mint(alice, 1);
        assertEq(erc721a.balanceOf(alice), 1);
        assertEq(erc721a.totalSupply(), 1);
        assertEq(erc721a.ownerOf(1), alice);
    }

    function testFail_mint_toAddressZero() public {
        // vm.expectRevert(ERC721A.InvalidRecipient.selector);
        erc721a.mint(address(0), 1);
    }

    function testFail_mint_amountZero() public {
        // vm.expectRevert(ERC721A.InvalidAmount.selector);
        erc721a.mint(alice, 0);
    }

    function test_safeMint_toEOA() public {
        erc721a.safeMint(alice, 1);
        assertEq(erc721a.balanceOf(alice), 1);
        assertEq(erc721a.ownerOf(1), alice);
    }

    function test_safeMint_toERC721Recipient() public {
        vm.etch(alice, type(ERC721Recipient).runtimeCode);

        vm.expectCall(
            alice,
            abi.encodeWithSignature(
                "onERC721Received(address,address,uint256,bytes)",
                address(this),
                address(0),
                1,
                "TestData"
            )
        );

        erc721a.safeMint(alice, 1, "TestData");
        assertEq(erc721a.balanceOf(alice), 1);
        assertEq(erc721a.ownerOf(1), alice);
    }

    function testFail_safeMint_toRevertingERC721Recipient() public {
        vm.etch(alice, type(RevertingERC721Recipient).runtimeCode);

        // vm.expectRevert(ERC721A.UnsafeRecipient.selector);
        erc721a.safeMint(alice, 1);
    }

    function test_totalSupply() public {
        assertEq(erc721a.totalSupply(), 0);
        erc721a.mint(alice, 1);
        assertEq(erc721a.totalSupply(), 1);
    }

    function test_tokenOfOwnerByIndex() public {
        erc721a.mint(alice, 1);
        assertEq(erc721a.tokenOfOwnerByIndex(alice, 0), 1);
    }

    function testFail_tokenOfOwnerByIndex_unMinted() public view {
        // vm.expectRevert(ERC721A.InvalidIndex.selector);
        erc721a.tokenOfOwnerByIndex(alice, 0);
    }

    function test_tokenByIndex() public {
        erc721a.mint(alice, 1);
        assertEq(erc721a.tokenByIndex(1), 1);
    }

    function testFail_tokenByIndex_invalidIndex() public view {
        // vm.expectRevert(ERC721A.InvalidIndex.selector);
        erc721a.tokenByIndex(0);
    }

    function testFail_tokenByIndex_unMinted() public view {
        // vm.expectRevert(ERC721A.InvalidIndex.selector);
        erc721a.tokenByIndex(1);
    }

    function test_balanceOf() public {
        assertEq(erc721a.balanceOf(alice), 0);
        erc721a.mint(alice, 1);
        assertEq(erc721a.balanceOf(alice), 1);
    }

    function testFail_balanceOf_addressZero() public view {
        // vm.expectRevert(ERC721A.InvalidOwner.selector);
        erc721a.balanceOf(address(0));
    }

    function test_ownerOf() public {
        erc721a.mint(alice, 1);
        assertEq(erc721a.ownerOf(1), alice);
    }

    function testFail_ownerOf_nonExistentToken() public view {
        // vm.expectRevert(ERC721.NonExistentToken.selector);
        erc721a.ownerOf(0);
    }

    function testFail_ownerOf_unMinted() public view {
        // vm.expectRevert(ERC721.NonExistentToken.selector);
        erc721a.ownerOf(1);
    }

    function test_transferFrom() public {
        erc721a.mint(alice, 1);
        vm.prank(alice);
        erc721a.approve(bob, 1);

        vm.prank(bob);
        erc721a.transferFrom(alice, bob, 1);

        assertEq(erc721a.getApproved(1), address(0));
        assertEq(erc721a.balanceOf(alice), 0);
        assertEq(erc721a.balanceOf(bob), 1);
        assertEq(erc721a.ownerOf(1), bob);
    }

    function test_transferFrom_self() public {
        erc721a.mint(alice, 1);

        vm.prank(alice);
        erc721a.transferFrom(alice, bob, 1);

        assertEq(erc721a.balanceOf(alice), 0);
        assertEq(erc721a.balanceOf(bob), 1);
        assertEq(erc721a.ownerOf(1), bob);
    }

    function testFail_transferFrom_invalidToken() public {
        // vm.expectRevert(ERC721.NonExistentToken.selector);
        erc721a.transferFrom(alice, bob, 0);
    }

    function testFail_transferFrom_unMinted() public {
        // vm.expectRevert(ERC721.NonExistentToken.selector);
        erc721a.transferFrom(alice, bob, 1);
    }

    function testFail_transferFrom_wrongFrom() public {
        erc721a.mint(address(123), 1);
        // vm.expectRevert(ERC721.WrongFrom.selector);
        erc721a.transferFrom(alice, bob, 1);
    }

    function testFail_transferFrom_unAuthorized() public {
        erc721a.mint(alice, 1);
        vm.prank(bob);
        erc721a.transferFrom(alice, bob, 1);
    }

    function testFail_transferFrom_toAddressZero() public {
        erc721a.mint(alice, 1);
        vm.prank(alice);
        // vm.expectRevert(ERC721.InvalidRecipient.selector);
        erc721a.transferFrom(alice, address(0), 1);
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

    function test_approve() public {
        erc721a.mint(alice, 1);
        vm.prank(alice);
        erc721a.approve(bob, 1);
        assertEq(erc721a.getApproved(1), bob);
    }

    function testFail_approve_invalidToken() public {
        vm.prank(alice);
        erc721a.approve(bob, 0);
    }

    function testFail_approve_unMinted() public {
        vm.prank(alice);
        erc721a.approve(bob, 1);
    }

    function test_setApprovalForAll() public {
        vm.startPrank(alice);
        erc721a.setApprovalForAll(bob, true);
        assertTrue(erc721a.isApprovedForAll(alice, bob));
        erc721a.setApprovalForAll(bob, false);
        assertFalse(erc721a.isApprovedForAll(alice, bob));
    }

    function testFuzz_mint(address to, uint8 amount) public {
        vm.assume(to != address(0) && amount != 0 && amount <= 10);

        erc721a.mint(to, amount);
        assertEq(erc721a.balanceOf(to), amount);
        assertEq(erc721a.totalSupply(), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(i + 1), to);
        }
    }

    function testFailFuzz_mint_toAddressZero(uint128 amount) public {
        vm.assume(amount != 0);
        // vm.expectRevert(ERC721A.InvalidRecipient.selector);
        erc721a.mint(address(0), amount);
    }

    function testFailFuzz_mint_amountZero(address to) public {
        vm.assume(to != address(0));
        // vm.expectRevert(ERC721A.InvalidAmount.selector);
        erc721a.mint(to, 0);
    }

    function testFuzz_safeMint_toEOA(address to, uint8 amount) public {
        vm.assume(to != address(0) && amount != 0 && amount <= 10);
        erc721a.safeMint(to, amount);
        assertEq(erc721a.balanceOf(to), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(i + 1), to);
        }
    }

    function testFuzz_safeMint_toERC721Recipient(
        address to,
        uint8 amount,
        bytes calldata data
    ) public {
        vm.assume(to != address(0) && amount != 0 && amount <= 10);
        vm.etch(to, type(ERC721Recipient).runtimeCode);

        for (uint256 i; i < amount; i++) {
            vm.expectCall(
                to,
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    address(this),
                    address(0),
                    i + 1,
                    data
                )
            );
        }

        erc721a.safeMint(to, amount, data);
        assertEq(erc721a.balanceOf(to), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(i + 1), to);
        }
    }

    function testFailFuzz_safeMint_toRevertingERC721Recipient(address to, uint128 amount) public {
        vm.assume(to != address(0) && amount != 0);
        vm.etch(to, type(RevertingERC721Recipient).runtimeCode);

        // vm.expectRevert(ERC721A.UnsafeRecipient.selector);
        erc721a.safeMint(to, amount);
    }

    function testFuzz_tokenOfOwnerByIndex(address owner, uint8 amount) public {
        vm.assume(owner != address(0) && amount != 0 && amount <= 10);

        erc721a.mint(owner, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.tokenOfOwnerByIndex(owner, i), i + 1);
        }
    }

    function testFailFuzz_tokenOfOwnerByIndex_unMinted(address owner, uint256 idx) public {
        vm.assume(owner != address(0) && idx != 0);

        erc721a.tokenOfOwnerByIndex(owner, idx);
    }

    function testFuzz_tokenByIndex(address rnd, uint8 amount) public {
        vm.assume(rnd != address(0) && amount != 0 && amount <= 10);

        erc721a.mint(rnd, amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.tokenByIndex(i + 1), i + 1);
        }
    }

    function testFailFuzz_tokenByIndex_unMinted(uint256 id) public {
        vm.assume(id != 0);

        erc721a.tokenByIndex(id);
    }

    function testFailFuzz_ownerOf_unMinted(uint256 id) public {
        vm.assume(id != 0);

        erc721a.ownerOf(id);
    }

    function testFuzz_transferFrom(
        address from,
        address to,
        address operator,
        uint8 amount
    ) public {
        vm.assume(
            from != address(0) &&
                to != address(0) &&
                from != to &&
                from != operator &&
                operator != to &&
                amount != 0 &&
                amount <= 10
        );

        erc721a.mint(from, amount);

        for (uint256 i; i < amount; i++) {
            uint256 id = i + 1;

            vm.prank(from);
            erc721a.approve(operator, id);

            vm.prank(operator);
            erc721a.transferFrom(from, to, id);

            assertEq(erc721a.getApproved(id), address(0));
            assertEq(erc721a.ownerOf(id), to);
        }

        assertEq(erc721a.balanceOf(from), 0);
        assertEq(erc721a.balanceOf(to), amount);
    }

    function testFuzz_transferFrom_self(
        address from,
        address to,
        uint8 amount
    ) public {
        vm.assume(
            from != address(0) && to != address(0) && from != to && amount != 0 && amount <= 10
        );

        erc721a.mint(from, amount);

        vm.startPrank(from);
        for (uint256 i; i < amount; i++) {
            erc721a.transferFrom(from, to, i + 1);
        }
        vm.stopPrank();

        assertEq(erc721a.balanceOf(from), 0);
        assertEq(erc721a.balanceOf(to), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(i + 1), to);
        }
    }

    function testFailFuzz_transferFrom_invalidToken(address from, address to) public {
        vm.assume(from != address(0) && to != address(0) && from != to);

        erc721a.transferFrom(from, to, 0);
    }

    function testFailFuzz_transferFrom_unMinted(
        address from,
        address to,
        uint256 id
    ) public {
        vm.assume(from != address(0) && to != address(0) && from != to && id != 0);

        erc721a.transferFrom(from, to, id);
    }

    function testFailFuzz_transferFrom_wrongFrom(
        address from,
        address to,
        address rnd
    ) public {
        vm.assume(
            from != address(0) &&
                to != address(0) &&
                rnd != address(0) &&
                from != to &&
                from != rnd &&
                rnd != to
        );

        erc721a.mint(rnd, 1);
        erc721a.transferFrom(from, to, 1);
    }

    function testFailFuzz_transferFrom_unAuthorized(address from, address to) public {
        vm.assume(from != address(0) && to != address(0) && from != to);

        erc721a.mint(from, 1);
        vm.prank(to);
        erc721a.transferFrom(from, to, 1);
    }

    function testFailFuzz_transferFrom_toAddressZero(address from) public {
        vm.assume(from != address(0));

        erc721a.mint(from, 1);
        vm.prank(from);
        erc721a.transferFrom(from, address(0), 1);
    }

    function testFuzz_safeTransferFrom(
        address from,
        address to,
        uint8 amount,
        bytes calldata data
    ) public {
        vm.assume(
            from != address(0) && to != address(0) && from != to && amount != 0 && amount <= 10
        );
        vm.etch(to, type(ERC721Recipient).runtimeCode);

        erc721a.mint(from, amount);

        vm.startPrank(from);
        for (uint256 i; i < amount; i++) {
            uint256 id = i + 1;

            vm.expectCall(
                to,
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    from,
                    from,
                    id,
                    data
                )
            );
            erc721a.safeTransferFrom(from, to, id, data);
        }
        vm.stopPrank();

        assertEq(erc721a.balanceOf(to), amount);
        for (uint256 i; i < amount; i++) {
            assertEq(erc721a.ownerOf(i + 1), to);
        }
    }

    function testFuzz_approve(
        address from,
        address spender,
        uint8 amount
    ) public {
        vm.assume(
            from != address(0) &&
                spender != address(0) &&
                from != spender &&
                amount != 0 &&
                amount <= 10
        );

        erc721a.mint(from, amount);

        uint256 id = (getRandom256(amount) % amount) + 1;

        vm.prank(from);
        erc721a.approve(spender, id);
        assertEq(erc721a.getApproved(id), spender);
    }

    function testFailFuzz_approve_invalidToken(address from, address spender) public {
        vm.assume(from != address(0) && spender != address(0) && from != spender);
        vm.prank(from);
        erc721a.approve(spender, 0);
    }

    function testFailFuzz_approve_unMinted(
        address from,
        address spender,
        uint256 id
    ) public {
        vm.assume(from != address(0) && spender != address(0) && from != spender && id != 0);
        vm.prank(from);
        erc721a.approve(spender, id);
    }

    function testFuzz_setApprovalForAll(
        address from,
        address spender,
        bool approved
    ) public {
        vm.assume(from != address(0) && spender != address(0) && from != spender);
        vm.startPrank(from);
        erc721a.setApprovalForAll(spender, approved);
        assertBoolEq(erc721a.isApprovedForAll(from, spender), approved);
    }

    function testGas_deploy() public {
        unchecked {
            new MockERC721A();
        }
    }

    function testGas_mint() public {
        // start slots warm
        startMeasuringGas("First mint");
        erc721a.mint(address(69), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 1");
        erc721a.mint(address(1), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 2");
        erc721a.mint(address(2), 2);
        stopMeasuringGas();

        startMeasuringGas("Mint 3");
        erc721a.mint(address(3), 3);
        stopMeasuringGas();

        startMeasuringGas("Mint 4");
        erc721a.mint(address(4), 4);
        stopMeasuringGas();

        startMeasuringGas("Mint 5");
        erc721a.mint(address(5), 5);
        stopMeasuringGas();

        startMeasuringGas("Mint 10");
        erc721a.mint(address(10), 10);
        stopMeasuringGas();
    }

    function testGas_safeMint() public {
        // start slots warm
        startMeasuringGas("First mint");
        erc721a.safeMint(address(69), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 1");
        erc721a.safeMint(address(1), 1);
        stopMeasuringGas();

        startMeasuringGas("Mint 2");
        erc721a.safeMint(address(2), 2);
        stopMeasuringGas();

        startMeasuringGas("Mint 3");
        erc721a.safeMint(address(3), 3);
        stopMeasuringGas();

        startMeasuringGas("Mint 4");
        erc721a.safeMint(address(4), 4);
        stopMeasuringGas();

        startMeasuringGas("Mint 5");
        erc721a.safeMint(address(5), 5);
        stopMeasuringGas();

        startMeasuringGas("Mint 10");
        erc721a.safeMint(address(10), 10);
        stopMeasuringGas();
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
