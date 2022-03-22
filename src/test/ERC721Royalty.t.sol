// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/BaseTest.sol";
import "./utils/mocks/MockERC721Royalty.sol";

contract TestERC721Royalty is BaseTest {
    MockERC721Royalty private erc721aRoyalty;

    function setUp() public virtual {
        erc721aRoyalty = new MockERC721Royalty();

        vm.label(address(erc721aRoyalty), "ERC721Royalty");
        vm.label(address(this), "TestERC721Royalty");
    }

    function test_royalty() public {
        vm.startPrank(alice);

        vm.expectRevert(ERC721Royalty.InvalidReceiver.selector);
        erc721aRoyalty.setRoyalty(address(0), 500);
        vm.expectRevert(ERC721Royalty.InvalidRoyaltyFraction.selector);
        erc721aRoyalty.setRoyalty(alice, 10001);

        // set receiver to alice and royalty to 5% (500bps)
        erc721aRoyalty.setRoyalty(alice, 500);

        uint256 id = 1;
        uint256 salePrice = 1 ether;

        (address receiver, uint256 royalty) = erc721aRoyalty.royaltyInfo(id, salePrice);

        assertEq(receiver, alice);
        assertEq(royalty, (salePrice * 500) / 10000);
    }

    function testGas_deploy() public {
        new MockERC721Royalty();
    }
}
