// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./CollectiblesNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TryLottery is Ownable {

  struct Ticket{
    uint8[6] ticket;
    uint256 ticketId;
  }

  address payable contractAddress;

  bool public toggleLottery;

  uint256 public soldTickets;
  uint256 public actualRound;
  uint256 public maxRound;
  uint256 public numberOfTickets;
  uint256 public ticketPrice;
  uint256 public numberOfCollectibles;
  uint256 public balance;
  Ticket[] tickets;

  mapping(uint256 => address) ticketOwners;
  mapping(uint256 => uint256[]) collectibles;

  CollectiblesNFT private nftContract;

  constructor(address _t){
    actualRound = 0;
    maxRound = 8;
    nftContract = CollectiblesNFT(_t);
    numberOfTickets = 0;
    soldTickets = 0;
    ticketPrice = 1 ether;
    numberOfCollectibles = 0;
  } 

  function openLottery() external onlyOwner {
    require(!toggleLottery,'Lottery is alredy opened');
    require(numberOfCollectibles > 0, 'No tickets for sale');
    actualRound = block.number;
    maxRound = maxRound + block.number;
    toggleLotteryStatus();
  }

  function toggleLotteryStatus() private {
    toggleLottery = !toggleLottery;
  }
  
  function getLotteryStatus() public returns(bool){
    return toggleLottery;
  }

  function createRandom(uint number) private returns(uint){
    return uint(keccak256(abi.encodePacked(blockhash(actualRound),block.timestamp))) % number;
  }

  function getContractBalance() public returns(uint256){
    return address(this).balance;
  }

  function createSmallRandom(uint8 number) private returns(uint8){
    return uint8(uint(keccak256(abi.encodePacked(blockhash(actualRound),block.timestamp)))) % number;
  }

  function increaseRound() public {
    actualRound++;
  }
  function someTest() public returns(uint8[6] memory){
    return createTicketNumber();
  }

  function createTicketNumber() public returns(uint8[6] memory) {

    uint8[6]  memory _ticketNumber;

    for(uint8 i = 0; i < 5 ; i++){
      _ticketNumber[i] = createSmallRandom(70);
    }
    _ticketNumber[5] = createSmallRandom(27);
    return _ticketNumber;
  }

  function buyTicket() public payable{
    require(toggleLottery, 'Lottery is not opened');
    require(msg.value >= ticketPrice, 'Not enough Ether sent');
    require(numberOfCollectibles > soldTickets, 'Not enough Collectibles');
    tickets.push(Ticket(createTicketNumber(), soldTickets));
    balance = address(this).balance;
    //ticketOwners[soldTickets] = msg.sender;
    //if(soldTickets + 1 == numberOfTickets){
    //  toggleLotteryStatus();
    //}
    //soldTickets++;
  }


  function createCollectible(string memory _metadata) public onlyOwner {
    collectibles[numberOfCollectibles % 8].push(nftContract.mint(_metadata));
    numberOfCollectibles++;
  }

  function awardCollectible(uint256 ticketNumber, uint8 class) private {
    nftContract.transferFrom(address(this), ticketOwners[ticketNumber], collectibles[class][createRandom(collectibles[class].length)]);
  }

  function getBalance() view public  returns(uint256){
    return balance;
  }

}

