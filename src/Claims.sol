//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "openzeppelin-solidity/contracts/access/AccessControl.sol";
import "./ClaimERC1155ERC721ERC20.sol";

/// @title A Multi Claim contract that enables claims of user rewards in the form of ERC1155, ERC721 and / or ERC20 tokens
/// @notice This contract manages claims for multiple token types
contract Claims is AccessControl, ClaimERC1155ERC721ERC20 {
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    mapping(address => mapping(bytes32 => bool)) public claimed;
    mapping(bytes32 => uint256) internal _expiryTime;

    event NewGiveaway(bytes32 merkleRoot, uint256 expiryTime);

    constructor(address admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function getExpiryTime(bytes32 merkleRoot) external view returns (uint) {
        return _expiryTime[merkleRoot];
    }

    /// @notice Function to add a new giveaway.
    /// @param merkleRoot The merkle root hash of the claim data.
    /// @param expiryTime The expiry time for the giveaway.
    function addNewGiveaway(bytes32 merkleRoot, uint256 expiryTime) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _expiryTime[merkleRoot] = expiryTime;
        emit NewGiveaway(merkleRoot, expiryTime);
    }

    /// @notice Function to permit the claiming of multiple tokens from multiple giveaways to a reserved address.
    /// @param claims The array of claim structs, each containing a destination address, the giveaway items to be claimed and an optional salt param.
    /// @param proofs The proofs submitted for verification.
    function claimMultipleTokensFromMultipleMerkleTree(
        bytes32[] calldata rootHashes,
        Claim[] memory claims,
        bytes32[][] calldata proofs
    ) external {
        require(claims.length == rootHashes.length, "MULTIGIVEAWAY_INVALID_INPUT");
        require(claims.length == proofs.length, "MULTIGIVEAWAY_INVALID_INPUT");
        for (uint256 i = 0; i < rootHashes.length; i++) {
            claimMultipleTokens(rootHashes[i], claims[i], proofs[i]);
        }
    }

    /// @notice Function to check which giveaways have been claimed by a particular user.
    /// @param user The user (intended token destination) address.
    /// @param rootHashes The array of giveaway root hashes to check.
    /// @return claimedGiveaways The array of bools confirming whether or not the giveaways relating to the root hashes provided have been claimed.
    function getClaimedStatus(address user, bytes32[] calldata rootHashes) external view returns (bool[] memory) {
        bool[] memory claimedGiveaways = new bool[](rootHashes.length);
        for (uint256 i = 0; i < rootHashes.length; i++) {
            claimedGiveaways[i] = claimed[user][rootHashes[i]];
        }
        return claimedGiveaways;
    }

    /// @dev Public function used to perform validity checks and progress to claim multiple token types in one claim.
    /// @param merkleRoot The merkle root hash for the specific set of items being claimed.
    /// @param claim The claim struct containing the destination address, all items to be claimed and optional salt param.
    /// @param proof The proof provided by the user performing the claim function.
    function claimMultipleTokens(
        bytes32 merkleRoot,
        Claim memory claim,
        bytes32[] calldata proof
    ) public {
        uint256 giveawayExpiryTime = _expiryTime[merkleRoot];
        require(claim.to != address(0), "MULTIGIVEAWAY_INVALID_TO_ZERO_ADDRESS");
        require(claim.to != address(this), "MULTIGIVEAWAY_DESTINATION_MULTIGIVEAWAY_CONTRACT");
        require(giveawayExpiryTime != 0, "MULTIGIVEAWAY_DOES_NOT_EXIST");
        require(block.timestamp < giveawayExpiryTime, "MULTIGIVEAWAY_CLAIM_PERIOD_IS_OVER");
        require(claimed[claim.to][merkleRoot] == false, "MULTIGIVEAWAY_DESTINATION_ALREADY_CLAIMED");
        claimed[claim.to][merkleRoot] = true;
        _claimERC1155ERC721ERC20(merkleRoot, claim, proof);
    }

    function onERC721Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return ERC721_RECEIVED;
    }

    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return ERC1155_BATCH_RECEIVED;
    }

}
