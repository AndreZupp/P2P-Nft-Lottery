// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

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
  uint256 private numberOfCollectibles;
  uint256 private seed;
  uint256 public roundId;
  uint public roundDuration;

  Ticket[] private tickets;
  Ticket private winningTicket;

  mapping(uint256 => address ) private ticketOwners;
  mapping(uint256 => uint256[]) private collectibles;

  CollectiblesNFT private nftContract;

  event TicketBought(address indexed _ticketOwner, Ticket indexed _boughtTicket);
  event TicketRefunded(uint256 indexed amount);
  event TicketRewarded(address indexed _winnerAddress, Ticket indexed _winningTicket, uint256 indexed ticketClass);
  event WinningTicketExtracted(Ticket indexed _winningTicket, uint256 indexed roundId);
  event LogTmp(uint256 indexed ticketClass, uint256 indexed Token_id, address indexed winner);

  constructor(){
    nftContract = new CollectiblesNFT('TRYLottery', 'TRYL');
    nftContract.setOwnerAddress();
    soldTickets = 0;
    roundId = 0;
    ticketPrice = 30000000 gwei;
    numberOfCollectibles = 0;
    seed = 0;
    roundDuration = 10;
  } 

  function setRoundDuration(uint _newDuration) external onlyOwner {
    require(!lotteryStatus, 'Can not change the lottery duration while it is opened');
    roundDuration = _newDuration;
  }
  
  //This function exists only for test purposes, to check that everything works
  function setWinningTicket(uint8[6] memory ticketNumbers) external onlyOwner {
    winningTicket =  Ticket(ticketNumbers, 123456);
    emit WinningTicketExtracted(winningTicket, roundId);

  }


  function getWinningTicket() view public returns(Ticket memory) {
    return winningTicket;
  }

  function startNewRound() external onlyOwner {
    require(!lotteryStatus,'Lottery is alredy opened');
    require(numberOfCollectibles > 0, 'No collectibles available for the winners!');

    roundId++;
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
    require(lotteryStatus, 'Can not check the round of a closed lottery');
    if(block.number >= endingBlock){
      if(winningTicket.ticketId != 123456) //Case of test lottery, the winning ticket is assigned ID 123456
        drawNumbers();
      emit WinningTicketExtracted(winningTicket, roundId);
      checkWinners();
      payable(this.owner()).transfer(address(this).balance);
      cleanData(); //Notice that since mappings need the list of keys to be deleted they're deleted while traversed in checkwinner function
      toggleLotteryStatus();
    }
  }


  function drawNumbers() private {
    winningTicket = Ticket(createTicketNumber(), soldTickets+1);
  }

  function cleanData() private{
    delete tickets;
    soldTickets = 0;
    roundId++;
    delete collectibles[0];
    delete collectibles[1];
    delete collectibles[2];
    delete collectibles[3];
    delete collectibles[4];
    delete collectibles[5];
    delete collectibles[6];
    delete collectibles[7];
    numberOfCollectibles = 0;
  }

  function createTicketNumber() private returns(uint8[6] memory) {
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

  function buy(uint8[6] memory userNumbers) public payable{
    checkRound(); 
    require(lotteryStatus, 'Lottery is not opened');
    require(msg.value >= ticketPrice, 'Not enough Ether sent');
    require(numberOfCollectibles > soldTickets, 'Not enough Collectibles');
    tickets.push(Ticket(userNumbers, soldTickets));
    ticketOwners[soldTickets] = msg.sender;
    emit TicketBought(msg.sender, tickets[soldTickets]);
    soldTickets++; 
  }

  function mint(string memory _metadata) external onlyOwner {
    collectibles[numberOfCollectibles % 8].push(nftContract.mint(_metadata));
    numberOfCollectibles++;
  }

  function givePrizes(uint256 ticketNumber, uint8 class) private {
    uint256 rewardTokenId = collectibles[class-1][collectibles[class-1].length - 1];
    collectibles[class-1].pop();
    emit LogTmp(class, rewardTokenId, ticketOwners[ticketNumber]);
    nftContract.transferNft(address(ticketOwners[ticketNumber]), rewardTokenId);
    //nftContract.transferFrom(address(this), address(ticketOwners[ticketNumber]), rewardTokenId);
    emit TicketRewarded(ticketOwners[ticketNumber], tickets[ticketNumber], class);
    numberOfCollectibles--;
  }

  function closeLottery() external payable onlyOwner{
    require(lotteryStatus, 'Lottery is alredy closed');
    refund();
    emit TicketRefunded(ticketPrice * soldTickets);
    cleanData(); 
    toggleLotteryStatus();
  }

  function refund() private  onlyOwner{
    for(uint256 i = 0; i < tickets.length; i++){
      payable(ticketOwners[i]).transfer(ticketPrice);
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
      if(!powerBallMatch && matches == 0){
        //delete ticketOwners[i];
        continue;
      }
      if(matches == 5){
          if(powerBallMatch)
            givePrizes(i,1);
          else
            givePrizes(i,2);
          continue;
        }

      if(matches == 4){
        if(powerBallMatch)
            givePrizes(i,3);
        else
          givePrizes(i,4);
        continue;        
        }

      if(matches == 3){
        if(powerBallMatch){
          givePrizes(i,4);
          continue;
        }
        else{
          givePrizes(i,5);
          continue;
        }
      }

      if(matches == 2){
        if(powerBallMatch){
         givePrizes(i, 5);
         continue;
        }
        else{
          givePrizes(i,6);
          continue;
        }
      }

      if(matches == 1){
        if(powerBallMatch){
         givePrizes(i, 6);
         continue;
        }
        else{
          givePrizes(i,7);
          continue;
        }
      }
      
      if(powerBallMatch && matches == 0){
          givePrizes(i,8);
          continue;
      }
    }
  }

}
