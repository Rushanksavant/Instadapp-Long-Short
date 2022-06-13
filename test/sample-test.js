const { expect } = require("chai");
const { assert } = require('chai');
const { Contract } = require("ethers");
const { ethers } = require("hardhat");

describe("Long using Compound connector", function () {
  let provider;

  let Task1;

  beforeEach(async function () {
    [deployer, add1, add2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;

    // Deploying contract:
    Task1 = await ethers.getContractFactory("Task1").then(contract => contract.deploy(
      "0x1B1EACaa31abbE544117073f6F8F658a56A3aE25" // ConnectV2Compound
    ));
    await Task1.deployed();

  });

  it("Verify Long operation", async function () {
    await Task1.connect(add1).goLong(2, "ETH-A");
  })
});
