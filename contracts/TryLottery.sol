// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./CollectiblesNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TryLottery is Ownable {

  struct Ticket{
    uint8[6] numbers;
    uint256 ticketId;
  }

  address payable contractAddress;

  bool public lotteryStatus;

  uint256 public soldTickets;
  uint256 public endingBlock;
  uint public roundDuration;
  uint256 public ticketPrice;
  uint256 public numberOfCollectibles;
  uint256 private seed;

  Ticket[] tickets;
  Ticket winningTicket;

  mapping(uint256 => address ) ticketOwners;
  mapping(uint256 => uint256[]) collectibles;

  CollectiblesNFT private nftContract;

  event TicketBought(address indexed _ticketOwner, Ticket indexed _boughtTicket);
  event TicketRefunded(address indexed _refuncAddress, Ticket indexed _refundedTicket, uint256 amount, string message);
  constructor(address _t){
    nftContract = CollectiblesNFT(_t);
    soldTickets = 0;
    ticketPrice = 10000000 gwei;
    numberOfCollectibles = 0;
    seed = 0;
    roundDuration = 10;
  } 

  function openLottery() external onlyOwner {
    require(!lotteryStatus,'Lottery is alredy opened');
    require(numberOfCollectibles > 0, 'No collectibles available for the winners!');
    endingBlock = block.number + roundDuration;
    toggleLotteryStatus();
  }

  function toggleLotteryStatus() private {
    lotteryStatus = !lotteryStatus;
  }
  
  function createRandom(uint number) private returns(uint){
    return uint(keccak256(abi.encodePacked(blockhash(block.number),block.timestamp,seed++))) % number;
  }
  
  function getContractBalance() view public returns(uint256){
    return address(this).balance;
  }

  function createSmallRandom(uint8 number) private returns(uint8){
    seed++;
    return uint8(uint(keccak256(abi.encodePacked(blockhash(block.number),block.timestamp,seed)))) % number;
  }

  function checkRound() public {
    require(lotteryStatus, 'Lottery is Not Opened');
    if(block.number >= endingBlock){
      toggleLotteryStatus();
      winningTicket = Ticket(createTicketNumber(), soldTickets++);
      checkWinners();
    }
  }

  function createTicketNumber() public returns(uint8[6] memory) {
    checkRound();
    uint8[6]  memory _ticketNumber;

    for(uint8 i = 0; i < 5 ; i++){
      _ticketNumber[i] = createSmallRandom(70);
    }
    _ticketNumber[5] = createSmallRandom(27);
    return _ticketNumber;
  }

  function buyRandomTicket() public payable{
    checkRound();
    require(lotteryStatus, 'Lottery is not opened');
    require(msg.value >= ticketPrice, 'Not enough Ether sent');
    require(numberOfCollectibles > soldTickets, 'Not enough Collectibles');
    tickets.push(Ticket(createTicketNumber(), soldTickets));
    ticketOwners[soldTickets] = msg.sender;
    soldTickets++;

  }

  function buyTicket(uint8[6] memory userNumbers) public payable{
    checkRound();
    require(lotteryStatus, 'Lottery is not opened');
    require(msg.value >= ticketPrice, 'Not enough Ether sent');
    require(numberOfCollectibles > soldTickets, 'Not enough Collectibles');
    tickets.push(Ticket(userNumbers, soldTickets));
    ticketOwners[soldTickets] = msg.sender;
    emit TicketBought(msg.sender, tickets[soldTickets]);
    soldTickets++; 
  }

  function createCollectible(string memory _metadata) public onlyOwner {
    collectibles[numberOfCollectibles % 8].push(nftContract.mint(address(this),_metadata));
    numberOfCollectibles++;
  }

  function awardCollectible(uint256 ticketNumber, uint8 class) private {
    nftContract.transferFrom(address(this), ticketOwners[ticketNumber], collectibles[class-1][createRandom(collectibles[class].length)]);
    delete collectibles[class];
    numberOfCollectibles--;
  }

  function closeLottery() external onlyOwner{
    require(lotteryStatus, 'Lottery is alredy closed');
    refund();
  }

  function getTicket(uint i) view public returns(uint8[6] memory){
    return tickets[i].numbers;
  }

  function refund() private {
    require(address(this).balance >= tickets.length * ticketPrice, 'Not enough fund to repay the owners');
    for(uint i = 0; i < tickets.length; i++){
      payable(ticketOwners[i]).transfer(ticketPrice);
      emit TicketRefunded(ticketOwners[i],  tickets[i], ticketPrice, "Your ticket has been refunded to your address");
      delete ticketOwners[i];
    }
  }


  function checkWinners() private {
    uint matches;
    bool powerBallMatch;
    for(uint i = 0; i < tickets.length; i++){
      powerBallMatch = false;
      matches = 0;
      for(uint j = 0; j < 5; j++){
        if(tickets[i].numbers[j] == winningTicket.numbers[j])
            matches++;
      }
      powerBallMatch = tickets[i].numbers[5] == winningTicket.numbers[5];
      if(matches == 5){
          if(powerBallMatch)
            awardCollectible(i,1);
          else
            awardCollectible(i,2);
          continue;
        }
      if(matches == 4){
        if(powerBallMatch)
            awardCollectible(i,3);
        else
          awardCollectible(i,4);
        continue;
          
        }
      if(matches > 0){
        if(powerBallMatch)
          matches++;
        awardCollectible(i,uint8(8-matches));
        continue;
        }
      if(powerBallMatch){
         awardCollectible(i, 8);
      }
    }
  }

}

