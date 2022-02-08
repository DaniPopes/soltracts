# soltracts

A set of modern and efficient solidity smart contracts.

Currently there are only ERC721 NFT contracts.

## Tokens

### ERC721
- **ERC721**: Used at the base of the other ERC721 contracts which implement mint, storage and transfer logic. Includes only metadata and abstract logic.
- **ERC721A**: Extends `ERC721`. Refactored and optimized version of [chiru-labs's implementation](https://github.com/chiru-labs/ERC721A).
- **ERC721B**: Extends `ERC721`. Refactored and optimized version of [beskay's implementation](https://github.com/beskay/ERC721B).
- **Extensions**:
  * **ERC721Batch**: Extends `ERC721` with batch transfer functions.
  * **ERC721Tradable**: Extends `ERC721` with NFT marketplace whitelisting for easy trading.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install danipopes/soltracts
```

To install with [**DappTools**](https://github.com/dapphub/dapptools):

```sh
dapp install danipopes/soltracts
```

## Test

Tests use [**Foundry: Forge**](https://github.com/gakonst/foundry).

### Install Forge

```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Run tests

```sh
# Get dependencies
forge update

# Run tests
forge test
```

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions or loss of transmitted information. DaniPopes is not liable for any of the foregoing. Users should proceed with caution and use at their own risk._

## Acknowledgements

These contracts were inspired by or directly modified from many sources, primarily:

- [Chiru-Labs](https://github.com/chiru-labs/ERC721A)
- [Rari-Capital](https://github.com/Rari-Capital/solmate)
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Beskay](https://github.com/beskay/ERC721B)
