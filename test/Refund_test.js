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
const cadd = "0x6C09Dc18F567049f1A5280585D62B7ac7EAfb310"; //Contract address

describe("Refunding test", function () {
  this.timeout(5000000);
  it("Minting NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    for(let i = 0; i < 2 ; i++){
        await myContract.mint(metadata[i+10]);
    }
    console.log("All the NFTs have been minted");
  });
  it("Buying test" async function (){
    const [owner, address1, address2, address3] = await ethers.getSigners();
    const onwerContractInstance = await ethers.getContractAt("TryLottery", cadd);

    // event TicketRefunded(address indexed _refundAddress, Ticket indexed _refundedTicket, uint256 indexed amount);

    onwerContractInstance.on("TicketRefunded", async (amount, event) => {
      console.log("A total of:", JSON.parse(amount)," has been refunded to the addresses\n \n");
    });

    const lottery = await onwerContractInstance.startNewRound();
    const address1ContractInstance = await onwerContractInstance.connect(address1);
    const address2ContractInstance = await onwerContractInstance.connect(address2);
    const address3ContractInstance = await onwerContractInstance.connect(address3);
    const options = {value: ethers.utils.parseEther("0.03")}
    
    //const result1 = await address1ContractInstance.buy([12,21,11,19,23,1],options) //Wins a class 1 Ticket
   // const result2 = await address2ContractInstance.buy([12,21,11,19,23,2],options) //Wins a class 2 Ticket
   // const result3 = await address3ContractInstance.buy([13,21,11,19,23,1],options) //Wins a class 3 Ticket 
   // const result4 = await address1ContractInstance.buy([12,21,11,19,24,2],options) //Wins a class 4 Ticket
   // const result5 = await address2ContractInstance.buy([12,21,11,20,24,2],options) //Wins a class 5 Ticket
   // const result6 = await address3ContractInstance.buy([13,22,12,20,24,1],options) //Wins a class 6 Ticket
    const result7 = await address1ContractInstance.buy([12,22,12,20,24,2],options) //Wins a class 7 Ticket
    const result8 = await address2ContractInstance.buy([13,22,12,20,24,1],options) //Wins a class 8 Ticket

    const checkround = await onwerContractInstance.closeLottery();
  });

});
});