// Right click on the script name and hit "Run" to execute
import * as IPFS from 'ipfs-core';
const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0xA4d2290b6137c6b338F6326Bb5B4ac9fD76A0bc7";

describe("MyContract", function () {
  it("test initial value", async function () {
    const myContract = await ethers.getContractAt("MyContract", cadd);
    const results = JSON.parse(await myContract.get_value())
    console.log("This is the actual balance: ", results)
  });

  it("Increase value", async function(){
    const myContract =  await ethers.getContractAt("MyContract", cadd);
    const ret = await myContract.increase(50);
  });

    it("test final value", async function () {
    const myContract = await ethers.getContractAt("MyContract", cadd);
    const results = JSON.parse(await myContract.get_value())
    console.log("This is the actual balance: ", results)
  });



});