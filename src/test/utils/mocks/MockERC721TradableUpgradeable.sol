// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MockERC721AUpgradeable.sol";
import "../../../upgradable/tokens/ERC721/extensions/ERC721TradableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MockERC721TradableUpgradeable is MockERC721AUpgradeable, ERC721TradableUpgradeable {
    function initialize(address openSeaProxyRegistry, address looksRareTransferManager)
        external
        initializer
    {
        __ERC721Tradable_init(
            "TestName",
            "TestSymbol",
            openSeaProxyRegistry,
            looksRareTransferManager
        );
    }

    function setMarketplaceApprovalForAll(bool approved) public {
        _setMarketplaceApprovalForAll(approved);
    }

    function isApprovedForAll(address a, address b)
        public
        view
        override(ERC721Upgradeable, ERC721TradableUpgradeable)
        returns (bool c)
    {
        return super.isApprovedForAll(a, b);
    }

    function _safeMint(address to, uint256 amount)
        internal
        override(ERC721AUpgradeable, ERC721Upgradeable)
    {
        super._safeMint(to, amount);
    }

    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal override(ERC721AUpgradeable, ERC721Upgradeable) {
        ERC721AUpgradeable._safeMint(to, amount, data);
    }
}
