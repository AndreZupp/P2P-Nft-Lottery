// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./MyNft2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TryLottery is Ownable {

  bool private toggleLottery;
  uint8 public actualRound;
  uint8 public maxRound;
  uint8 public numberOfClasses;
  MyNft2 private myNftContract;
  uint256 private numberOfCollectibles;
  Collectible[] private collectibles;
  mapping(uint => Collectible[]) dictOfCollectibles;

  struct Collectible {
    uint256 tokenId;
  }

  constructor(address _t){
    actualRound = 0;
    maxRound = 8;
    myNftContract = MyNft2(_t);
    numberOfCollectibles = 8;
  }

  function createRandom(uint number) private returns(uint){
    return uint(keccak256(abi.encodePacked(blockhash(actualRound),block.timestamp))) % number;
  }

  function _mintCollectibles(uint quantity) external onlyOwner {
    for(uint i = 0; i < quantity; i++){
      dictOfCollectibles[createRandom(numberOfClasses)].push(Collectible(myNftContract.mint(msg.sender)));
    }
  }

  function increaseRounde() public {
    actualRound++;
  }

}

