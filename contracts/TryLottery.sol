// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./CollectiblesNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TryLottery is Ownable {

  bool private toggleLottery;
  uint8 public actualRound;
  uint8 public maxRound;
  uint8 public numberOfClasses;
  CollectiblesNFT private nftContract;
  uint256 private numberOfCollectibles;
  mapping(uint => uint[]) dictOfCollectibles;


  constructor(address _t){
    actualRound = 0;
    maxRound = 8;
    nftContract = CollectiblesNFT(_t);
    numberOfCollectibles = 8;
  }

  function createRandom(uint number) private returns(uint){
    return uint(keccak256(abi.encodePacked(blockhash(actualRound),block.timestamp))) % number;
  }

  function _mintCollectible(uint8 class, string memory _metadata ) external onlyOwner {
      dictOfCollectibles[class].push(nftContract.mint(_metadata));
  }

  function increaseRound() public {
    actualRound++;
  }

}

