// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MockERC721A.sol";
import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Royalty.sol";

contract MockERC721Royalty is MockERC721A, ERC721Royalty {
    function setRoyalty(address receiver, uint96 royaltyFraction) external {
        _setRoyalty(receiver, royaltyFraction);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _safeMint(address to, uint256 amount) internal override(ERC721, MockERC721A) {
        MockERC721A._safeMint(to, amount);
    }

    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal override(ERC721, MockERC721A) {
        MockERC721A._safeMint(to, amount, data);
    }
}
