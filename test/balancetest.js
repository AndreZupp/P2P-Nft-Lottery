const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0xA4d2290b6137c6b338F6326Bb5B4ac9fD76A0bc7";

describe("Dioporcobastardo", function () {
  it("test initial value", async function () {
    const [owner] = await ethers.getSigners();
    const tx = {
    to: "0xA4d2290b6137c6b338F6326Bb5B4ac9fD76A0bc7",
    value: ethers.utils.parseEther("10.0")
    }
    owner.sendTransaction(tx)
//    const myContract = await ethers.getContractAt("MyContract", cadd);
    const balance = JSON.parse(await ethers.provider.getBalance(cadd));
    console.log("The balance is :", balance )
  });
});