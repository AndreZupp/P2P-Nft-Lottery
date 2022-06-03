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
const cadd = "0x78EE305c65A3ad00FB6d0C240464682C3b4DCF51"; //Contract address

describe("Minting test", function () {
/it("Minting 100 NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    for(let i = 0; i < 100 ; i++){
        myContract.createCollectible(metadata[i]);
    }
    console.log("All the minting transaction have been sent");

  });
});