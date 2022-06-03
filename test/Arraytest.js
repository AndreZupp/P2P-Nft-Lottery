const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0xF27225f42B3E7a087A27f158f06755f89aA8F056"; //Contract address

describe("Minting test", function () {
  it("Minting 20 NFTs", async function () {
    const [owner] = await ethers.getSigners();
    const myContract = await ethers.getContractAt("TryLottery", cadd);
    const result = await myContract.getArray([10,20,30,40,50,80]);
    console.log(result);
  });
});