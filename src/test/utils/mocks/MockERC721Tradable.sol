// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MockERC721A.sol";
import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Tradable.sol";

contract MockERC721Tradable is MockERC721A, ERC721Tradable {
    constructor(address _openSeaProxyRegistry, address _looksRareTransferManager)
        payable
        ERC721Tradable(_openSeaProxyRegistry, _looksRareTransferManager)
    {}

    function setMarketplaceApprovalForAll(bool approved) public {
        _setMarketplaceApprovalForAll(approved);
    }

    function isApprovedForAll(address a, address b)
        public
        view
        override(ERC721, ERC721Tradable)
        returns (bool c)
    {
        return super.isApprovedForAll(a, b);
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
