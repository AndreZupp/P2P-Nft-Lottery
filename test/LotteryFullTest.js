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
  //Setting Async timeout so it doens't run out of time
  this.timeout(5000000);

  //Minting test, 60 NFTs
  it("Minting NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    for(let i = 0; i < 60 ; i++){
        await myContract.mint(metadata[i]);
    }
    console.log("All the minting transaction have been sent");
  });

  //Buying and then calling transaction to get to the M-th block so the lottery gets closed
  it("Buying test", async function (){

    //Getting references to addresses
    const [owner, address1, address2] = await ethers.getSigners();
    const onwerContractInstance = await ethers.getContractAt("TryLottery", cadd);

    //Adding event listeners
    onwerContractInstance.on("TicketBought", async (_ticketOwner, _boughtTicket, event) =>{
        console.log("The user with address  ", _ticketOwner, " has bought a ticket","\n \n");
    });

    onwerContractInstance.on("TicketRewarded", async (_winnerAddress, _winningTicket, ticketClass, message, event) => {
        console.log("The user  ", _winnerAddress, "has won the collectible of class ", JSON.parse(ticketClass), "\n \n");
      });

    //Set lottery duration
    const lotteryDuration = await onwerContractInstance.setRoundDuration(26);
    //Open the lottery
    const lottery = await onwerContractInstance.startNewRound();

    //Open connection from other addresses to the contract
    const address1ContractInstance = onwerContractInstance.connect(address1);
    const address2ContractInstance = onwerContractInstance.connect(address2);
    const options = {value: ethers.utils.parseEther("0.03")}
    //Buy tickets
    for(let i = 0; i < 12; i++){
      const result1 = await address1ContractInstance.buyRandomTicket(options);
      const result2 = await address2ContractInstance.buyRandomTicket(options);
    }
    //Calls to function to skip some block
    const checkRound = onwerContractInstance.checkRound();
    const checkround2 = await onwerContractInstance.checkRound();
  });
});