const { expect } = require("chai");
const { assert } = require('chai');
const { Contract } = require("ethers");
const { ethers } = require("hardhat");

const cEth_ABI = require("./cETH_abi.json");

describe("Long using Compound connector", function () {
  let provider;

  let usingCollateralFactor;
  let usingFlashLoan;
  let DSA;

  beforeEach(async function () {
    [deployer, add1, add2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;

    // Deploying contract:
    usingCollateralFactor = await ethers.getContractFactory("usingCollateralFactor").then(contract => contract.deploy());
    await usingCollateralFactor.deployed();

    // Deploying contract:
    usingFlashLoan = await ethers.getContractFactory("flashLoanLogic").then(contract => contract.deploy());
    await usingFlashLoan.deployed();

    cEth = new ethers.Contract("0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5", cEth_ABI, provider);

  });

  // it("Collateral Factor scale", async function () { // convert calculateLoops to public before calling this test
  //   await usingCollateralFactor.connect(add1).calculateLoops(ethers.utils.parseEther("1"), "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5");
  // })
  it("Build DSA", async function () {
    await usingFlashLoan.build_myDSA(add1.address)
    DSA = await usingFlashLoan.myDSA()
    expect(DSA).not.equal("0x0000000000000000000000000000000000000000")
  })
  it("Leveraged using FlashLoan", async function () {
    console.log("add1: ", add1.address)

    await usingFlashLoan.build_myDSA(add1.address)
    console.log(usingFlashLoan.address)
    // await usingFlashLoan.takePosition(ethers.utils.parseEther("1"))

    const cETH_recieved = await cEth.balanceOf(DSA)
    console.log(cETH_recieved)
  })
});
