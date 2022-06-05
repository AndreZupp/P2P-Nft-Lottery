// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CollectiblesNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    address public ownerAddress;
    address public param1;
    address public param2;
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function setOwnerAddress() external onlyOwner {
        ownerAddress = msg.sender;
    }

    function mint(string memory tokenURI) public returns (uint256) {
        _mint(ownerAddress, _tokenIds);
        _setTokenURI(_tokenIds, tokenURI);

        return _tokenIds++;
    }

    function getTokenID() public view returns(uint256){
        return _tokenIds;
    }

    function transferNft(address _to, uint256 tokenId) external onlyOwner {
            param1 = _to;
            param2 = ownerAddress;
            transferFrom(ownerAddress, _to, tokenId);
    }
}
