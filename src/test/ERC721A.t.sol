// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import { MockERC721A } from "./utils/mocks/MockERC721A.sol";

contract TestERC721A is BaseTest {
    MockERC721A internal erc721a;

    function setUp() public {
        erc721a = new MockERC721A("testname", "testsymbol", "https://example.com/12345/");
    }

    function testDeployGas() public {
        unchecked {
            new MockERC721A("abcdefg", "xyz", "https://example.com/12345/");
        }
    }

    // uint160(keccak256("0x69")) - checksummed
    address private constant _to = 0xa29Cfe8c2b8F0CeA8C67AF4a20c2C9286D2562a6;

    // function testSafeMint(uint256 amount) public {
    //     vm.assume(amount > 0 && amount < type(uint128).max);
    //     erc721a.safeMint(_to, amount);
    //     assertEq(erc721a.balanceOf(_to), amount);
    // }

    function testSafeMintGas1() public {
        unchecked {
            erc721a.safeMint(_to, 1);
        }
    }

    function testSafeMintGas2() public {
        unchecked {
            erc721a.safeMint(_to, 2);
        }
    }

    function testSafeMintGas3() public {
        unchecked {
            erc721a.safeMint(_to, 3);
        }
    }

    function testSafeMintGas4() public {
        unchecked {
            erc721a.safeMint(_to, 4);
        }
    }

    function testSafeMintGas5() public {
        unchecked {
            erc721a.safeMint(_to, 5);
        }
    }

    function testSafeMintGasA() public {
        unchecked {
            erc721a.safeMint(_to, 10);
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
}
