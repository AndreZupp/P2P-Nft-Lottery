pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNft2 is ERC721 {
    uint256 private _tokenIds;

    constructor() ERC721('MyNft2','MYNFT2') {}

    function mint(address _owner) public returns (uint256)
    {
        _mint(_owner, _tokenIds);
        return _tokenIds++;
    }

}