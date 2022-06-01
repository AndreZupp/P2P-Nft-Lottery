const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0xaE981060901dbe586B884Bf90Bc0e102D0EA40C7"; //Contract address

describe("Minting test", function () {
  it("Minting 20 NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    for(let i = 0; i < 100 ; i++){
        myContract.createCollectible(metadata[i]);
        console.log('Minted number ', i);
    }
    

  });
});