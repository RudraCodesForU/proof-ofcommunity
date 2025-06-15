// SPDX-License-Identifier: MIT
// Copyright (c) 2025 RudraCodesForU. All Rights Reserved.
// Origin: Proof of Community (Decentralized AI-Powered Volunteer Verification)
// This contract may not be copied or reused without explicit permission except under the MIT License terms.

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ProofOfCommunity
 * @dev NFT Badge contract for decentralized, AI-verified volunteer recognition.
 *      Badges are soulbound (non-transferrable) by default to ensure authenticity.
 *      Only the contract owner (platform backend) can mint badges.
 *      Each badge stores a metadata URI describing the volunteer act.
 */
contract ProofOfCommunity is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    /// @dev Emitted when a new badge is minted.
    event BadgeMinted(address indexed volunteer, uint256 indexed tokenId, string metadataURI);

    // Pass msg.sender to Ownable constructor as required in OZ v5+
    constructor() ERC721("Proof of Community Badge", "POCB") Ownable(msg.sender) {}

    /**
     * @notice Mint a badge to a verified volunteer.
     * @param recipient The wallet address of the volunteer.
     * @param metadataURI The URI describing the volunteer's verified contribution.
     */
    function mintBadge(address recipient, string calldata metadataURI) external onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, metadataURI);

        emit BadgeMinted(recipient, tokenId, metadataURI);
    }

    /**
     * @dev Override _update to make badges soulbound (non-transferrable).
     *      Only allow minting (from zero address) or burning (to zero address).
     */
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        if (_ownerOf(tokenId) != address(0) && to != address(0)) {
            revert("Badges are soulbound and non-transferrable");
        }
        return super._update(to, tokenId, auth);
    }

    /// @notice Get the total number of badges minted.
    function totalBadges() external view returns (uint256) {
        return _tokenIdCounter;
    }
}