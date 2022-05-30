// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNft is ERC721, Ownable {
    uint256 public mintPrice = 0.05 ether;
    uint256 public totalSupply;
    uint256 public maxSupply;
    bool isMintEnabled;
    mapping(address => uint256) mintedWallets;

    constructor() payable ERC721('My Nft', 'MYNFT'){
        maxSupply = 2;
    }

    function toggleIsMintEnabled() external onlyOwner {
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 maxSupply_) external  {
        maxSupply = maxSupply_;
    }

    function mint(address _owner) external payable {
        require(isMintEnabled, 'Minting not available');
        require(mintedWallets[msg.sender] < 1 , 'Exceeded number of mints');
        require(msg.value == mintPrice, 'Value not valid');
        require( totalSupply < maxSupply, 'Max supply reached');

        mintedWallets[msg.sender]++;
        totalSupply++;
        uint tokenID = totalSupply;
        _safeMint(_owner, tokenID);
    }



    }