const { expect } = require("chai");
const { assert } = require('chai');
const { Contract } = require("ethers");
const { ethers } = require("hardhat");

const cEth_ABI = require("./cETH_abi.json");
const DAI_ABI = require("./DAI_abi.json")

describe("Contract Testing: ", function () {
  let provider;
  let signer;

  let usingCollateralFactor;
  let usingFlashLoan;
  let smaple_dsa;

  beforeEach(async function () {
    [deployer, add1, add2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;
    signer = provider.getSigner(add1.address)

    // Deploying contract:
    usingCollateralFactor = await ethers.getContractFactory("usingCollateralFactor").then(contract => contract.deploy());
    await usingCollateralFactor.deployed();

    // Deploying contract:
    usingFlashLoan = await ethers.getContractFactory("flashLoanLogic").then(contract => contract.deploy());
    await usingFlashLoan.deployed();

    // Deploying contract:
    sample = await ethers.getContractFactory("sample").then(contract => contract.deploy());
    await sample.deployed();
    smaple_dsa = await sample.myDSA() // build DSA


    cEth = new ethers.Contract("0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5", cEth_ABI, provider);
    DAI = new ethers.Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", DAI_ABI, provider);
  });

  // it("Collateral Factor scale", async function () { // convert calculateLoops to public before calling this test
  //   await usingCollateralFactor.connect(add1).calculateLoops(ethers.utils.parseEther("1"), "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5");
  // })
  it("Build DSA", async function () {
    DSA = await usingFlashLoan.myDSA()
    expect(DSA).not.equal("0x0000000000000000000000000000000000000000")
  })
  // it("Leveraged using FlashLoan", async function () {
  //   // send eth to contract
  //   tx = {
  //     to: usingFlashLoan.address,
  //     value: ethers.utils.parseEther('2', 'ether')
  //   };
  //   const transaction = await signer.sendTransaction(tx)
  //   console.log("Contract Balance: ", await provider.getBalance(usingFlashLoan.address))

  //   // go long
  //   await usingFlashLoan.connect(add1).takePosition(ethers.utils.parseEther("1"))

  //   const cETH_recieved = await cEth.balanceOf(DSA)
  //   console.log(cETH_recieved)
  // })

  it("Verify DSA build - Experiment", async function () {
    expect(smaple_dsa).not.equal("0x0000000000000000000000000000000000000000")
  })

  it("Basic + Compound Deposit - Experiment", async function () {

    // main call
    await sample.connect(add1).takePosition({ value: ethers.utils.parseEther("1") })
    const DAI_recieved = await DAI.balanceOf(smaple_dsa);
    // console.log("DAI recieved: ", DAI_recieved);
    // console.log("DSA ETH Balance: ", await provider.getBalance(smaple_dsa));
    const cETH_recieved = await cEth.balanceOf(smaple_dsa)
    console.log(cETH_recieved)
  })
});