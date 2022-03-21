// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Batch.sol";

contract MockERC721Batch is ERC721A, ERC721Batch {
    constructor(string memory _name, string memory _symbol) payable ERC721A(_name, _symbol) {}

    function safeMint(address to, uint256 amount) external {
        _safeMint(to, amount);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {}

    function _safeMint(address to, uint256 amount) internal override(ERC721, ERC721A) {
        ERC721A._safeMint(to, amount);
    }

    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal override(ERC721, ERC721A) {
        ERC721A._safeMint(to, amount, data);
    }
}
