const { expect } = require("chai");
const { ethers } = require("hardhat");
const cadd = "0x5f66c7e0954B5c620744Bcf22d673Cbe3B4F7653"; //Contract address

describe("Minting test", function () {
  it("Buying test" async function (){
    const [owner, address1, address2] = await ethers.getSigners();
    const onwerContractInstance = await ethers.getContractAt("TryLottery", cadd);
    const lottery = await onwerContractInstance.openLottery();
    const address1ContractInstance = onwerContractInstance.connect(address1);
    const address2ContractInstance = onwerContractInstance.connect(address2);
    const options = {value: ethers.utils.parseEther("0.1")}
    for(let i = 0; i < 4; i++){
      const result1 = await address1ContractInstance.buyRandomTicket(options);
      const result2 = await address2ContractInstance.buyRandomTicket(options);
    }
    

  });
});