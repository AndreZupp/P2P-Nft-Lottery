const metadata = ["donkey","around","river","yourself","youth","stairs"
"date","listen","plural","hall","laugh","uncle"
"sweet","tired","thou","giving","boat","while"
"fair","month","seat","judge","nearly","adventure"
"slave","contain","harder","better","eye","introduced"
"visitor","addition","combination","command","shine","mile"
"memory","office","silly","afternoon","model","job", "barn","would","hang","material","who","cream"
"shot","south","idea","repeat","stop","him"
"refer","saddle","high","movement","hard","hung"
"difference","art","wind","whale","creature","let"
"exact","explore","paid","rise","interior","railroad"
"class","white","high","share","explain","rocket"
"officer","chair","maybe","know","captured","flow", "airplane","depth","due","factor","long","selection"
"lower","basis","coal","great","negative","four"
"burn","sink","lion","accept","tongue","jet"
"reader","tired","advice","cow","whose","part"
"tales","had","another","standard","rays","experience"
"species","division","bag","including","health","join"
"farm","bee","recent","mouse","carried","member"];


const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0xd9145CCE52D386f254917e481eB44e9943F39138"; //Contract address

describe("Try lottery testing", function () {
  this.timeout(5000000);
  it("Minting NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    for(let i = 0; i < 20 ; i++){
        await myContract.mint(metadata[i+10]);
    }
    console.log("All the NFTs have been minted");
  });
  it("Buying test", async function (){
    //Get the addresses and open an instance for the owner
    const [owner, address1, address2, address3] = await ethers.getSigners();
    const onwerContractInstance = await ethers.getContractAt("TryLottery", cadd);

    //Event listener
    onwerContractInstance.on("TicketBought", async (_ticketOwner, _boughtTicket, event) =>{
      console.log("The user with address  ", _ticketOwner, " has bought a ticket","\n \n");
    });

    onwerContractInstance.on("TicketRewarded", async (_winnerAddress, _winningTicket, ticketClass, message, event) => {
      console.log("The user  ", _winnerAddress, "has won the collectible of class ", JSON.parse(ticketClass), "\n \n");
    });

    //Open the lottery
    const lottery = await onwerContractInstance.startNewRound();

    //Open instances for other addresses
    const address1ContractInstance = await onwerContractInstance.connect(address1);
    const address2ContractInstance = await onwerContractInstance.connect(address2);
    const address3ContractInstance = await onwerContractInstance.connect(address3);
    const options = {value: ethers.utils.parseEther("0.03")}
    


    //Buying the tickets
    const result1 = await address1ContractInstance.buy([12,21,11,19,23,1],options) //Wins a class 1 Ticket
    const result2 = await address2ContractInstance.buy([12,21,11,19,23,2],options) //Wins a class 2 Ticket
    const result3 = await address3ContractInstance.buy([13,21,11,19,23,1],options) //Wins a class 3 Ticket 
    const result4 = await address1ContractInstance.buy([12,21,11,19,24,2],options) //Wins a class 4 Ticket
    const result5 = await address2ContractInstance.buy([12,21,11,20,24,2],options) //Wins a class 5 Ticket
    const result6 = await address3ContractInstance.buy([12,21,12,20,24,2],options) //Wins a class 6 Ticket
    const result7 = await address1ContractInstance.buy([12,22,12,20,24,2],options) //Wins a class 7 Ticket
    const result8 = await address2ContractInstance.buy([13,22,12,20,24,1],options) //Wins a class 8 Ticket
    //Now we are going to manipulate the lottery for testing purposes
    const winningTicket = await onwerContractInstance.setWinningTicket([12,21,11,19,23,1]) //Winning ticket
    //Call to skip a block and end the lottery
    //If you want to manage the test differently (to display correctly the even log) 
    //comment this line and call checkRound() from Remix
    const last = await onwerContractInstance.checkRound(); 
    console.log("For some reason the logs of winning tickets are displayed even if the event is emitted only once, and it doens't happen on Ganache (as you can manually check on remix)");
  });
});
