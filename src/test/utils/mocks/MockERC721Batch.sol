// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MockERC721A.sol";
import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Batch.sol";

contract MockERC721Batch is MockERC721A, ERC721Batch {
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
