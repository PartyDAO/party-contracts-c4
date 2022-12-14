// SPDX-License-Identifier: Beta Software
pragma solidity ^0.8;

import "../tokens/IERC721.sol";
import "../utils/ReadOnlyDelegateCall.sol";
import "../utils/EIP165.sol";
import "../globals/IGlobals.sol";
import "../globals/LibGlobals.sol";

/// @notice NFT functionality for crowdfund types. This NFT is soulbound and read-only.
contract CrowdfundNFT is IERC721, EIP165, ReadOnlyDelegateCall {
    error AlreadyBurnedError(address owner, uint256 tokenId);
    error InvalidTokenError(uint256 tokenId);

    // The `Globals` contract storing global configuration values. This contract
    // is immutable and it’s address will never change.
    IGlobals private immutable _GLOBALS;

    /// @notice The name of the crowdfund. This will also carry over to the
    ///         governance party.
    string public name;
    /// @notice The token symbol for the crowdfund. This will also carry over to
    ///         the governance party.
    string public symbol;

    mapping (uint256 => address) private _owners;

    modifier alwaysRevert() {
        revert('ALWAYS FAILING');
        _; // Compiler requires this.
    }

    // Set the `Globals` contract.
    constructor(IGlobals globals) {
        _GLOBALS = globals;
    }

    // Initialize name and symbol for crowdfund.
    function _initialize(string memory name_, string memory symbol_)
        internal
        virtual
    {
        name = name_;
        symbol = symbol_;
    }

    /// @notice DO NOT CALL. This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always fail.
    function transferFrom(address, address, uint256)
        external
        alwaysRevert
    {}

    /// @notice DO NOT CALL. This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always fail.
    function safeTransferFrom(address, address, uint256)
        external
        alwaysRevert
    {}

    /// @notice DO NOT CALL. This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always fail.
    function safeTransferFrom(address, address, uint256, bytes calldata)
        external
        alwaysRevert
    {}

    /// @notice DO NOT CALL. This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always fail.
    function approve(address, uint256)
        external
        alwaysRevert
    {}

    /// @notice DO NOT CALL. This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always fail.
    function setApprovalForAll(address, bool)
        external
        alwaysRevert
    {}

    /// @notice This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always return null.
    function getApproved(uint256)
        external
        pure
        returns (address)
    {
        return address(0);
    }

    /// @notice This is a soulbound NFT and cannot be transferred.
    ///         Attempting to call this function will always return false.
    function isApprovedForAll(address, address)
        external
        pure
        returns (bool)
    {
        return false;
    }

    /// @inheritdoc EIP165
    function supportsInterface(bytes4 interfaceId)
        public
        virtual
        override
        pure
        returns (bool)
    {
        return super.supportsInterface(interfaceId) ||
            interfaceId == type(IERC721).interfaceId;
    }

    /// @notice Returns a URI to render the NFT.
    function tokenURI(uint256) external view returns (string memory) {
        return _delegateToRenderer();
    }

    /// @notice Returns a URI for the storefront-level metadata for your contract.
    function contractURI() external view returns (string memory) {
        return _delegateToRenderer();
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        owner = _owners[tokenId];
        if (owner == address(0)) {
            revert InvalidTokenError(tokenId);
        }
    }

    /// @inheritdoc IERC721
    function balanceOf(address owner) external view returns (uint256 numTokens) {
        return _doesTokenExistFor(owner) ? 1 : 0;
    }

    function _doesTokenExistFor(address owner) internal view returns (bool) {
        return _owners[uint256(uint160(owner))] != address(0);
    }

    function _mint(address owner) internal returns (uint256 tokenId)
    {
        tokenId = uint256(uint160(owner));
        if (_owners[tokenId] != owner) {
            _owners[tokenId] = owner;
            emit Transfer(address(0), owner, tokenId);
        }
    }

    function _burn(address owner) internal {
        uint256 tokenId = uint256(uint160(owner));
        if (_owners[tokenId] == owner) {
            _owners[tokenId] = address(0);
            emit Transfer(owner, address(0), tokenId);
            return;
        }
        revert AlreadyBurnedError(owner, tokenId);
    }

    function _delegateToRenderer() private view returns (string memory) {
        _readOnlyDelegateCall(
            // Instance of IERC721Renderer.
            _GLOBALS.getAddress(LibGlobals.GLOBAL_CF_NFT_RENDER_IMPL),
            msg.data
        );
        assert(false); // Will not be reached.
        return "";
    }
}
