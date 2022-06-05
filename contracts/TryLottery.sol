// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "./CollectiblesNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TryLottery is Ownable {

  struct Ticket{
    uint8[6] numbers;
    uint256 ticketId;
  }
  
  bool public lotteryStatus;

  uint256 public soldTickets;
  uint256 public endingBlock;
  uint256 public ticketPrice;
  uint256 public numberOfCollectibles;
  uint256 private seed;
  uint256 public roundId;
  uint public roundDuration;

  Ticket[] tickets;
  Ticket winningTicket;

  mapping(uint256 => address ) public ticketOwners;
  mapping(uint256 => uint256[]) public collectibles;

  CollectiblesNFT public nftContract;

  event TicketBought(address indexed _ticketOwner, Ticket indexed _boughtTicket);
  event TicketRefunded(address indexed _refundAddress, Ticket indexed _refundedTicket, uint256 indexed amount, string message);
  event TicketRewarded(address indexed _winnerAddress, Ticket indexed _winningTicket, uint256 indexed tokenID, string message);
  event WhereIAm(string message);
  event WinningTicketExtracted(Ticket indexed _winningTicket, uint256 indexed roundId, string message);
  event LogTmp(uint256 indexed ticketClass, uint256 indexed Token_id, address indexed winner);

  constructor(){
    nftContract = new CollectiblesNFT('TRYLottery', 'TRYL');
    soldTickets = 0;
    roundId = 0;
    ticketPrice = 30000000 gwei;
    numberOfCollectibles = 0;
    seed = 0;
    roundDuration = 10;
  } 

  function setRoundDuration(uint tmp) public {
    roundDuration = tmp;
  }
  
  function setWinningTicket(uint8[6] memory ticketNumbers) public {
    winningTicket =  Ticket(ticketNumbers, 123456);
  }

  function getWinningTicket() view public returns(Ticket memory) {
    return winningTicket;
  }

  function openLottery() external onlyOwner {
    require(!lotteryStatus,'Lottery is alredy opened');
    require(numberOfCollectibles > 0, 'No collectibles available for the winners!');
    endingBlock = block.number + roundDuration;
    toggleLotteryStatus();
  }

  function toggleLotteryStatus() public {
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
    if(block.number >= endingBlock){
      if(winningTicket.ticketId != 123456)
        winningTicket = Ticket(createTicketNumber(), soldTickets++);
      emit WinningTicketExtracted(winningTicket, roundId, 'This is the round winning ticket');
      checkWinners();
      //cleanData(); //Notice that since mappings need the list of keys to be deleted they're deleted while traversed in checkwinner function
      toggleLotteryStatus();
    }
  }

  function cleanData() private{
    delete tickets;
    soldTickets = 0;
    roundId++;
  }

  function createTicketNumber() public returns(uint8[6] memory) {
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
    require(msg.value < ticketPrice, 'Not enough Ether sent');
    require(numberOfCollectibles > soldTickets, 'Not enough Collectibles');
    tickets.push(Ticket(createTicketNumber(), soldTickets));
    ticketOwners[soldTickets] = msg.sender;
    soldTickets++;

  }

  function buyTicket(uint8[6] memory userNumbers) public payable{
    checkRound();
    require(lotteryStatus, 'Lottery is not opened');
    require(msg.value < ticketPrice, 'Not enough Ether sent');
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
    uint256 rewardTokenId = collectibles[class-1][createRandom(collectibles[class-1].length)];
    emit LogTmp(class-1, rewardTokenId, ticketOwners[ticketNumber]);
    nftContract.transferFrom(address(this), ticketOwners[ticketNumber], rewardTokenId);
    emit TicketRewarded(ticketOwners[ticketNumber], tickets[ticketNumber], rewardTokenId, 'Winning ticket log' );
    //delete collectibles[class];
    //delete ticketOwners[ticketNumber];
    //numberOfCollectibles--;
  }

  function closeLottery() external onlyOwner{
    require(lotteryStatus, 'Lottery is alredy closed');
    refund();
    payable(this.owner()).transfer(address(this).balance);
    toggleLotteryStatus();
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
    cleanData(); 
  }

  function transferWhatISay(uint256 _tokenId, address _address) public {
    nftContract.safeTransferFrom(address(this), _address, _tokenId);
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
      if(!powerBallMatch && matches == 0){
        //delete ticketOwners[i];
        continue;
      }
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

