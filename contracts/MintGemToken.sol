// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintGemToken is ERC721Enumerable {
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _metadataURI
    ) ERC721(_name, _symbol) {
        metadataURI = _metadataURI;
    }

    struct GemTokenData {
        uint256 gemTokenRank;
        uint256 gemTokenType;
    }

    mapping(uint256 => GemTokenData) public gemTokenData;

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory gemTokenRank = String.toString(
            gemTokenData[_tokenId].gemTokenRank
        );
        string memory gemTokenType = String.toString(
            gemTokenData[_tokenId].gemTokenType
        );

        return
            string(
                abi.encodePacked(
                    metadataURI,
                    "/",
                    gemTokenRank,
                    "/",
                    gemTokenType,
                    ".json"
                )
            );
    }

    function mintGemToken() public {
        uint256 tokenId = totalSupply() + 1;
        gemTokenData[tokenId] = GemTokenData(1, 1);
        _mint(msg.sender, tokenId);
    }
}
