// SPDX-License-Identifier: Beta Software
pragma solidity ^0.8;

interface IERC721Renderer {
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function contractURI() external view returns (string memory);
}
