// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Contract module that allows children to implement role-based access
/// control mechanisms.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol)
abstract contract AccessControl {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when `account` is missing `role`.
    error MissingRole(bytes32 role, address account);

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Emitted when `newAdminRole` is set as `role`'s admin role, replacing `previousAdminRole`
    /// `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
    /// {RoleAdminChanged} not being emitted signaling this.
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /// @dev Emitted when `account` is granted `role`.
    /// `sender` is the account that originated the contract call, an admin role
    /// bearer except when using {AccessControl-_setupRole}.
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /// @dev Emitted when `account` is revoked `role`.
    /// `sender` is the account that originated the contract call:
    ///   - if using `revokeRole`, it is the admin role bearer
    ///   - if using `renounceRole`, it is the role bearer (i.e. `account`)
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /* -------------------------------------------------------------------------- */
    /*                              IMMUTABLE STORAGE                             */
    /* -------------------------------------------------------------------------- */

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x0;

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    /// @dev Modifier that checks that an account has a specific role. Reverts
    /// with a standardized message including the required role.
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                ERC165 LOGIC                           
    /* -------------------------------------------------------------------------- */

    /// @notice Returns true if this contract implements an interface from its ID.
    /// @dev See the corresponding
    /// [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
    /// to learn more about how these IDs are created.
    /// @return The implementation status.
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x7965db0b; // ERC165 Interface ID for AccessControl
    }

    /* -------------------------------------------------------------------------- */
    /*                             AccessControl LOGIC                            */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns `true` if `account` has been granted `role`.
    /// @param role The role to check.
    /// @param account The address to query.
    /// @return `true` if `account` has been granted `role`.
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].members[account];
    }

    /// @dev Revert with a standard message if `msg.sender` is missing `role`.
    /// Overriding this function changes the behavior of the {onlyRole} modifier.
    /// Format of the revert message is described in {_checkRole}.
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, msg.sender);
    }

    /// @dev Revert with a standard message if `account` is missing `role`.
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) revert MissingRole(role, account);
    }

    /// @notice Returns the admin role that controls `role`. See {grantRole} and
    /// {revokeRole}.
    /// @dev To change a role's admin, use {_setRoleAdmin}.
    /// @param role The role to check.
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /// @notice Grants `role` to `account`.
    /// @dev Requirements:
    /// - the caller must have `role`'s admin role.
    /// If `account` had not been already granted `role`, emits a {RoleGranted}
    /// event.
    /// @param role The role to grant.
    /// @param account The address to grant to.
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /// @notice Revokes `role` from `account`.
    /// @dev Requirements:
    /// - the caller must have `role`'s admin role.
    /// If `account` had not been already granted `role`, emits a {RoleRevoked}
    /// event.
    /// @param role The role to revoke.
    /// @param account The address to revoke from.
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /// @notice Revokes `role` from the calling account.
    /// Roles are often managed via {grantRole} and {revokeRole}: this function's
    /// purpose is to provide a mechanism for accounts to lose their privileges
    /// if they are compromised (such as when a trusted device is misplaced).
    /// @dev If the calling account had been revoked `role`, emits a
    /// {RoleRevoked} event.
    /// @param role The role to renounce.
    function renounceRole(bytes32 role) public virtual {
        _revokeRole(role, msg.sender);
    }

    /// @dev Grants `role` to `account`.
    /// If `account` had not been already granted `role`, emits a {RoleGranted}
    /// event. Note that unlike {grantRole}, this function doesn't perform any
    /// checks on the calling account.
    /// [WARNING]
    /// ====
    /// This function should only be called from the constructor when setting
    /// up the initial roles for the system.
    /// Using this function in any other way is effectively circumventing the admin
    /// system imposed by {AccessControl}.
    /// ====
    /// NOTE: This function is deprecated in favor of {_grantRole}.
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    /// Emits a {RoleAdminChanged} event.
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /// @dev Grants `role` to `account`.
    /// Internal function without access restriction.
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    /// @dev Revokes `role` from `account`.
    /// Internal function without access restriction.
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}
