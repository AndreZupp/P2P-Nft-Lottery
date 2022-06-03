// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectiblesNFT is ERC721URIStorage {
    uint256 private _tokenIds;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}
    function mint(address owner, string memory tokenURI)
        public
        returns (uint256)
    {
        _mint(owner, _tokenIds);
        _setTokenURI(_tokenIds++, tokenURI);

        return _tokenIds;
    }

    function getTokenID() public view returns(uint256){
        return _tokenIds;
    }
}

