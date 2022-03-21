// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "../../../tokens/ERC721/ERC721A.sol";

contract MockERC721A is ERC721, ERC721A, Ownable, ReentrancyGuard {
    string public baseURI;

    constructor() payable ERC721A("TestName", "TestSymbol") {
        baseURI = "https://api.example.com/metadata/";
    }

    function setBaseURI(string calldata _baseURI) external {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        string memory _baseURI = baseURI;
        return bytes(_baseURI).length == 0 ? "" : string(abi.encodePacked(_baseURI, toString(id)));
    }

    function idsOfOwner(address owner) external view returns (uint256[] memory) {
        return _idsOfOwner(owner);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function mint(address to, uint256 amount) public payable {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public payable nonReentrant {
        _safeMint(to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual override(ERC721, ERC721A) {
        ERC721A._mint(to, amount);
    }

    function _safeMint(address to, uint256 amount) internal virtual override(ERC721, ERC721A) {
        ERC721A._safeMint(to, amount);
    }

    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal virtual override(ERC721, ERC721A) {
        ERC721A._safeMint(to, amount, data);
    }
}
