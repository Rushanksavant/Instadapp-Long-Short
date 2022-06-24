const { expect } = require("chai");
const { assert } = require('chai');
const { Contract } = require("ethers");
const { ethers } = require("hardhat");

const cEth_ABI = require("./cETH_abi.json");
const DAI_ABI = require("./DAI_abi.json")
const wETH_ABI = require("./wETH_abi.json")


describe("Contract Testing: ", function () {
  let provider;
  let signer;

  let usingFlashLoan;
  let myDSA;

  beforeEach(async function () {
    [deployer, add1, add2, ...addrs] = await ethers.getSigners();
    provider = ethers.provider;
    signer = provider.getSigner(add1.address)

    // Deploying contract:
    usingFlashLoan = await ethers.getContractFactory("FlashLoan_Logic").then(contract => contract.deploy());
    await usingFlashLoan.deployed();
    myDSA = await usingFlashLoan.myDSA() // get DSA address

    cEth = new ethers.Contract("0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5", cEth_ABI, provider);
    DAI = new ethers.Contract("0x6B175474E89094C44Da98b954EedeAC495271d0F", DAI_ABI, provider);
    wETH = new ethers.Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", wETH_ABI, provider);
  });

  it("1. Verify DSA Build", async function () {
    expect(myDSA).not.equal("0x0000000000000000000000000000000000000000")
  })

  it("2. MAIN - 3x Leveraged Position using FlashLoan", async function () {

    // main call
    await usingFlashLoan.connect(add1).takePosition({ value: ethers.utils.parseEther("1") })

    // cETH minted
    const cETH_recieved = await cEth.balanceOf(myDSA) / (10 ** 8)
    console.log("cETH recieved: ", cETH_recieved)

    // required getters
    const cETH_exchangeRate = await cEth.exchangeRateStored() / (10 ** (18 - 8 + 18))
    console.log("cETH exchangeRate: ", cETH_exchangeRate)

    const position = cETH_recieved * cETH_exchangeRate
    console.log("Leveraged Position: ", position)

    // position comparision
    expect(position).to.be.gt(1)
  })

  it("3. FlashLoan - Experiment", async function () {

    // Deploying contract:
    flash = await ethers.getContractFactory("flash").then(contract => contract.deploy());
    await flash.deployed();

    // main call
    await flash.connect(add1).takePosition({ value: ethers.utils.parseEther("1") })
    // flasDSA = await flash.myDSA()

  })

  it("4. Getting wETH", async function () {
    // Deploying contract:
    getWETH = await ethers.getContractFactory("getWETH").then(contract => contract.deploy());
    await getWETH.deployed();

    // main
    await getWETH.connect(add1).WETHget({ value: ethers.utils.parseEther("1") })
    getWETH_DSA = getWETH.myDSA();
    const wETH_recieved = await wETH.balanceOf(getWETH_DSA);
    console.log("WETH recieved: ", wETH_recieved);

  })

  it("5. Deposit and swap test", async function () {
    // Deploying contract:
    onlyComp = await ethers.getContractFactory("onlyComp").then(contract => contract.deploy());
    await onlyComp.deployed();

    // main
    await onlyComp.connect(add1).takePosition({ value: ethers.utils.parseEther("3") })
    onlyComp_DSA = onlyComp.myDSA();
    const wETH_recieved = await wETH.balanceOf(onlyComp_DSA);
    console.log("WETH recieved: ", wETH_recieved);

    const ETH_recieved = await provider.getBalance(onlyComp_DSA);
    console.log("ETH recieved: ", ETH_recieved);

    const DAI_recieved = await DAI.balanceOf(onlyComp_DSA);
    console.log("DAI recieved: ", DAI_recieved);

    const cETH_recieved = await cEth.balanceOf(onlyComp_DSA)
    console.log("cETH recieved: ", cETH_recieved)

  })
});