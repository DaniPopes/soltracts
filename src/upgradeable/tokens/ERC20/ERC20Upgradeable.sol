// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Initializable } from "../../proxy/utils/Initializable.sol";

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20Upgradeable is Initializable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when `block.timestamp` is greater than the permit's deadline.
    error PermitDeadlineExpired();

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Emitted when `amount` tokens are moved from one account (`from`) to
    /// another (`to`).
    /// Note that `amount` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set by
    /// a call to {approve}. `amount` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /* -------------------------------------------------------------------------- */
    /*                              METADATA STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the token's name.
    string public name;

    /// @notice Returns the token's symbol.
    string public symbol;

    /// @notice Returns the token's decimals.
    uint8 public decimals;

    /* -------------------------------------------------------------------------- */
    /*                                ERC20 STORAGE                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the amount of tokens in existence.
    uint256 public totalSupply;

    /// @notice Returns the amount of tokens owned by an address.
    mapping(address => uint256) public balanceOf;

    /// @notice Returns the remaining number of tokens that `spender` will be
    /// allowed to spend on behalf of `owner` through {transferFrom}. This is
    /// zero by default.
    /// This value changes when {approve} or {transferFrom} are called.
    mapping(address => mapping(address => uint256)) public allowance;

    /* -------------------------------------------------------------------------- */
    /*                              EIP-2612 STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @dev The initial chain ID.
    uint256 internal INITIAL_CHAIN_ID;

    /// @dev The initial domain separator hash.
    bytes32 internal INITIAL_DOMAIN_SEPARATOR;

    /// @notice Returns the current nonce for `owner`. This value must be
    /// included whenever a signature is generated for {permit}.
    /// Every successful call to {permit} increases ``owner``'s nonce by one. This
    /// prevents a signature from being used multiple times.
    mapping(address => uint256) public nonces;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZER                                */
    /* -------------------------------------------------------------------------- */

    function __ERC20_init(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) internal onlyInitializing {
        __ERC20_init_unchained(_name, _symbol, _decimals);
    }

    function __ERC20_init_unchained(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) internal onlyInitializing {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /* -------------------------------------------------------------------------- */
    /*                                 ERC20 LOGIC                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
    /// `transferFrom`. This is semantically equivalent to an infinite approval.
    /// Requirements:
    /// - `spender` cannot be the zero address.
    /// Emits an {Approval} event.
    /// @param spender The spender's address.
    /// @param amount The allowance.
    /// @return success Whether the operation succeeded.
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    /// @dev NOTE: Does not update the allowance if the current allowance
    /// is the maximum `uint256`.
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - the caller must have a balance of at least `amount`.
    /// Emits a {Transfer} event.
    /// @param to The address to transfer to.
    /// @param amount The amount of tokens to transfer.
    /// @return success Whether the operation succeeded.
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    /// @notice Moves `amount` tokens from `from` to `to` using the
    /// allowance mechanism. `amount` is then deducted from the caller's
    /// allowance.
    /// @dev Requirements:
    /// - `from` and `to` cannot be the zero address.
    /// - `from` must have a balance of at least `amount`.
    /// - the caller must have allowance for `from`'s tokens of at least
    /// `amount`.
    /// Emits a {Transfer} event.
    /// @param to The address to transfer to.
    /// @param amount The amount of tokens to transfer.
    /// @return success Whether the operation succeeded.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /* -------------------------------------------------------------------------- */
    /*                               EIP-2612 LOGIC                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Sets `value` as the allowance of `spender` over ``owner``'s tokens,
    /// given ``owner``'s signed approval.
    /// @dev Requirements:
    /// - `spender` cannot be the zero address.
    /// - `deadline` must be a timestamp in the future.
    /// - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
    /// over the EIP712-formatted function arguments.
    /// - the signature must use ``owner``'s current nonce (see {nonces}).
    /// For more information on the signature format, see the
    /// https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
    /// section].
    /// Emits an {Approval} event.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) revert PermitDeadlineExpired();

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    /// @notice Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /* -------------------------------------------------------------------------- */
    /*                          INTERNAL MINT/BURN LOGIC                          */
    /* -------------------------------------------------------------------------- */

    /// @dev Creates `amount` tokens and assigns them to `to`, increasing
    /// the total supply.
    /// Emits a {Transfer} event with `from` set to the zero address.
    /// @param to The address to mint to.
    /// @param amount Amount of tokens to mint.
    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /// @dev Destroys `amount` tokens from `account`, reducing the
    /// the total supply.
    /// Emits a {Transfer} event with `to` set to the zero address.
    /// @param from The address to burn from.
    /// @param amount Amount of tokens to burn.
    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
