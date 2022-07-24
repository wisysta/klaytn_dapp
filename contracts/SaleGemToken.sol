// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./MintGemToken.sol";

contract SaleGemToken {
    MintGemToken public mintGemToken;

    constructor(address _mintGemToken) {
        mintGemToken = MintGemToken(_mintGemToken);
    }

    struct GemTokenData {
        uint256 tokenId;
        uint256 gemTokenRank;
        uint256 gemTokenType;
        uint256 tokenPrice;
    }

    mapping(uint256 => uint256) public tokenPrices;

    uint256[] public onSaleTokens;

    function setForSaleGemToken(uint256 _tokenId, uint256 _price) public {
        address tokenOwner = mintGemToken.ownerOf(_tokenId);

        require(tokenOwner == msg.sender, "Caller is not Gem token owner.");
        require(_price > 0, "Price is zero or lower.");
        require(
            tokenPrices[_tokenId] == 0,
            "This Gem token is already on sale."
        );
        require(
            mintGemToken.isApprovedForAll(msg.sender, address(this)),
            "Gem token owner did not approve token."
        );

        tokenPrices[_tokenId] = _price;

        onSaleTokens.push(_tokenId);
    }

    function purchaseGemToken(uint256 _tokenId) public payable {
        address tokenOwner = mintGemToken.ownerOf(_tokenId);

        require(tokenPrices[_tokenId] > 0, "This Gem token not sale.");
        require(
            tokenPrices[_tokenId] <= msg.value,
            "Caller sent lower than price."
        );
        require(tokenOwner != msg.sender, "Caller is Gem token owner.");

        payable(tokenOwner).transfer(msg.value);

        mintGemToken.safeTransferFrom(tokenOwner, msg.sender, _tokenId);

        tokenPrices[_tokenId] = 0;

        popOnSaleToken(_tokenId);
    }

    function popOnSaleToken(uint256 _tokenId) private {
        for (uint256 i = 0; i < onSaleTokens.length; i++) {
            if (onSaleTokens[i] == _tokenId) {
                onSaleTokens[i] = onSaleTokens[onSaleTokens.length - 1];
                onSaleTokens.pop();
            }
        }
    }

    function getGemTokens(address _tokenOwner)
        public
        view
        returns (GemTokenData[] memory)
    {
        uint256 balanceLength = mintGemToken.balanceOf(_tokenOwner);

        require(balanceLength > 0, "Token owner did not have token.");

        GemTokenData[] memory gemTokens = new GemTokenData[](balanceLength);

        for (uint256 i = 0; i < balanceLength; i++) {
            uint256 tokenId = mintGemToken.tokenOfOwnerByIndex(_tokenOwner, i);

            (
                uint256 gemTokenRank,
                uint256 gemTokenType,
                uint256 tokenPrice
            ) = getGemTokenInfo(tokenId);

            gemTokens[i] = GemTokenData(
                tokenId,
                gemTokenRank,
                gemTokenType,
                tokenPrice
            );
        }
        return gemTokens;
    }

    function getSaleGemTokens() public view returns (GemTokenData[] memory) {
        require(onSaleTokens.length > 0, "Not exist on sale token.");

        GemTokenData[] memory gemTokens = new GemTokenData[](
            onSaleTokens.length
        );

        for (uint256 i = 0; i < onSaleTokens.length; i++) {
            uint256 tokenId = onSaleTokens[i];

            (
                uint256 gemTokenRank,
                uint256 gemTokenType,
                uint256 tokenPrice
            ) = getGemTokenInfo(tokenId);

            gemTokens[i] = GemTokenData(
                tokenId,
                gemTokenRank,
                gemTokenType,
                tokenPrice
            );
        }

        return gemTokens;
    }

    function getLatestMintedGemToken(address _tokenOwner)
        public
        view
        returns (GemTokenData memory)
    {
        uint256 balanceLength = mintGemToken.balanceOf(_tokenOwner);

        uint256 tokenId = mintGemToken.tokenOfOwnerByIndex(
            _tokenOwner,
            balanceLength - 1
        );

        (
            uint256 gemTokenRank,
            uint256 gemTokenType,
            uint256 tokenPrice
        ) = getGemTokenInfo(tokenId);

        return GemTokenData(tokenId, gemTokenRank, gemTokenType, tokenPrice);
    }

    function getGemTokenInfo(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 gemTokenRank = mintGemToken.getGemTokenRank(_tokenId);
        uint256 gemTokenType = mintGemToken.getGemTokenType(_tokenId);
        uint256 tokenPrice = tokenPrices[_tokenId];

        return (gemTokenRank, gemTokenType, tokenPrice);
    }
}
