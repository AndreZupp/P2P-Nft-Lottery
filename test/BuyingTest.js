const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0x08dF5F59D2b585d9977A03304470A9c60396D454"; //Contract address

describe("Buying test", function () {
  it("Buying test" async function (){
    const [owner, address1, address2] = await ethers.getSigners();
    const onwerContractInstance = await ethers.getContractAt("TryLottery", cadd);
    const lottery = await onwerContractInstance.openLottery();
    const address1ContractInstance = onwerContractInstance.connect(address1);
    const address2ContractInstance = onwerContractInstance.connect(address2);
    const options = {value: ethers.utils.parseEther("0.1")}
    for(let i = 0; i < 12; i++){
      const result1 = await address1ContractInstance.buyRandomTicket(options);
      const result2 = await address2ContractInstance.buyRandomTicket(options);
    }
    

  });
});