// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ERC721 } from "../ERC721.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Extension of ERC721 with the ERC2981 NFT Royalty Standard, a standardized way to retrieve royalty payment
/// information
abstract contract ERC721Royalty is ERC721 {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when trying to set the royalty receiver to address(0).
    error InvalidReceiver();

    /// @dev Thrown when trying to set the royalty fraction to a number greater than {_feeDenominator}.
    error InvalidRoyaltyFraction();

    /* -------------------------------------------------------------------------- */
    /*                            ERC721Royalty STORAGE                           */
    /* -------------------------------------------------------------------------- */

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo internal _royaltyInfo;

    /// @notice Called with the sale price to determine how much royalty
    // is owed and to whom.
    /// @param - The NFT asset queried for royalty information.
    /// @param salePrice The sale price of the NFT asset specified by `id`.
    /// @return The address of who should be sent the royalty payment.
    /// @return The royalty payment amount for `salePrice`.
    function royaltyInfo(
        uint256, /* id */
        uint256 salePrice
    ) external view virtual returns (address, uint256) {
        RoyaltyInfo memory royaltyInfo_ = _royaltyInfo;
        return (
            royaltyInfo_.receiver,
            (salePrice * royaltyInfo_.royaltyFraction) / _feeDenominator()
        );
    }

    /// @dev The denominator with which to interpret the fee set in {_setDefaultRoyalty} as a fraction of the sale price.
    /// Defaults to 10000 so fees are expressed in basis points, but may be customized by an override.
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /// @dev Sets the royalty information that all IDs in this contract will default to.
    /// Requirements:
    /// - `receiver` cannot be the zero address.
    /// - `royaltyFraction` cannot be greater than the fee denominator.
    function _setRoyalty(address receiver, uint96 royaltyFraction) internal virtual {
        if (receiver == address(0)) revert InvalidReceiver();
        if (royaltyFraction > _feeDenominator()) revert InvalidRoyaltyFraction();

        _royaltyInfo.receiver = receiver;
        _royaltyInfo.royaltyFraction = royaltyFraction;
    }

    /// @inheritdoc ERC721
    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
        return
            interfaceId == 0x2a55205a || // ERC165 Interface ID for ERC2981
            super.supportsInterface(interfaceId);
    }
}
