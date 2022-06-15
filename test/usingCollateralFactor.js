const { expect } = require("chai");
const { assert } = require('chai');
const { Contract } = require("ethers");
const { ethers } = require("hardhat");

describe("Long using Compound connector", function () {
  let provider;

  let usingCollateralFactor;

  beforeEach(async function () {
    [deployer, add1, add2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;

    // Deploying contract:
    usingCollateralFactor = await ethers.getContractFactory("usingCollateralFactor").then(contract => contract.deploy());
    await usingCollateralFactor.deployed();

  });

  it("Collateral Factor scale", async function () { // convert calculateLoops to public before calling this test
    await usingCollateralFactor.connect(add1).calculateLoops(ethers.utils.parseEther("1"), "0x4ddc2d193948926d02f9b1fe9e1daa0718270ed5");
  })
});
