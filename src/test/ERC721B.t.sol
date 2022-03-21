// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import { MockERC721B } from "./utils/mocks/MockERC721B.sol";

contract TestERC721B is BaseTest {
    MockERC721B internal erc721b;

    function setUp() public {
        erc721b = new MockERC721B("testname", "testsymbol", "https://example.com/12345/");
    }

    function testDeployGas() public {
        unchecked {
            new MockERC721B("abcdefg", "xyz", "https://example.com/12345/");
        }
    }

    // uint160(keccak256("0x69")) - checksummed
    address private constant _to = 0xa29Cfe8c2b8F0CeA8C67AF4a20c2C9286D2562a6;

    function testSafeMint(uint256 _amount) public {
        uint256 amount = (_amount % 128) + 1;
        erc721b.safeMint(_to, amount);
        assertEq(erc721b.balanceOf(_to), amount);
    }

    function testSafeMintGas1() public {
        unchecked {
            erc721b.safeMint(_to, 1);
        }
    }

    function testSafeMintGas2() public {
        unchecked {
            erc721b.safeMint(_to, 2);
        }
    }

    function testSafeMintGas3() public {
        unchecked {
            erc721b.safeMint(_to, 3);
        }
    }

    function testSafeMintGas4() public {
        unchecked {
            erc721b.safeMint(_to, 4);
        }
    }

    function testSafeMintGas5() public {
        unchecked {
            erc721b.safeMint(_to, 5);
        }
    }

    function testSafeMintGasA() public {
        unchecked {
            erc721b.safeMint(_to, 10);
        }
    }

    function testTransferFromGas() public {
        address from = getRandomAddress(69420);
        address to = getRandomAddress(420123);
        vm.startPrank(from);

        erc721b.safeMint(from, 2);

        startMeasuringGas("First transfer");
        erc721b.transferFrom(from, to, 1);
        stopMeasuringGas();

        assertEq(erc721b.balanceOf(from), 1);
        assertEq(erc721b.balanceOf(to), 1);

        startMeasuringGas("Second transfer");
        erc721b.transferFrom(from, to, 2);
        stopMeasuringGas();

        assertEq(erc721b.balanceOf(from), 0);
        assertEq(erc721b.balanceOf(to), 2);
    }

    function testSafeTransferFromGas() public {
        address from = getRandomAddress(42069);
        address to = getRandomAddress(69000);
        vm.startPrank(from);

        erc721b.safeMint(from, 2);

        startMeasuringGas("First transfer");
        erc721b.safeTransferFrom(from, to, 1);
        stopMeasuringGas();

        assertEq(erc721b.balanceOf(from), 1);
        assertEq(erc721b.balanceOf(to), 1);

        startMeasuringGas("Second transfer");
        erc721b.safeTransferFrom(from, to, 2);
        stopMeasuringGas();
    }
}
