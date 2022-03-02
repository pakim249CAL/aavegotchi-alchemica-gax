import * as fs from "fs";
import * as hre from "hardhat";
import { ethers } from "hardhat";
import { 
  Signer, 
  Contract, 
  ContractFactory,
  BigNumber } from "ethers";
import { expect } from "chai";
import {
  deployProxyAdmin,
  deployVestingImplementation,
  deployAlchemicaImplementation,
  deployAndInitializeVestingProxy,
  deployAndInitializeAlchemicaProxy,
} from "../helpers/helpers";
import {
  address,
  increaseTime,
  mine,
  currentTimestamp,
  aboutEquals,
} from "../helpers/utils";
import {
  GWEI,
  ETHER,
  YEAR,
  FUD_PARAMS,
  FOMO_PARAMS,
  ALPHA_PARAMS,
  KEK_PARAMS,
} from "../helpers/constants";

describe("GAX", function() {
  let signers: Signer[];
  let owner: Signer;
  let proxyAdmin: Contract;
  let fud: Contract;
  let token: Contract;
  let factory: Contract;
  let router: Contract;
  let vestingImplementation: Contract;
  let alchemicaImplementation: Contract;

  before(async function () {
    signers = await ethers.getSigners();
    owner = signers[0];
    proxyAdmin = (await deployProxyAdmin(owner)).contract;
    alchemicaImplementation = (await deployAlchemicaImplementation(owner)).contract;
    fud = (await deployAndInitializeAlchemicaProxy(
      owner,
      alchemicaImplementation,
      proxyAdmin,
      FUD_PARAMS.name,
      FUD_PARAMS.symbol,
      FUD_PARAMS.supply,
      await address(owner),
      signers[2],
      signers[3],
      )).contract;
    let Token = await hre.ethers.getContractFactory("Token");
    token = await Token.deploy();
  });

  describe("Factory", function() {
    it("should deploy GAX factory", async function() {
      let GAXFactory = await ethers.getContractFactory("UniswapV2Factory");
      factory = await GAXFactory.connect(owner).deploy(await address(owner));
      expect(await address(factory)).to.not.be.equal("0x0000000000000000000000000000000000000000");
    });

    it("should deploy GAX router", async function() {
      let GAXRouter = await ethers.getContractFactory("UniswapV2Router02");
      router = await GAXRouter.connect(owner).deploy(await address(factory), "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"); //WMATIC address
      expect(await address(router)).to.not.be.equal("0x0000000000000000000000000000000000000000");
    });

    it("should create a token pair", async function() {
      await factory.createPair(await address(token), await address(fud));
      expect(
        await factory.getPair(
          await address(token), 
          await address(fud)
        )
      ).to.not.be.equal("0x0000000000000000000000000000000000000000");
    });

    it("should let the owner change the fees per pair", async function() {

    });

    it("should not let anyone but the owner change the fees per pair", async function() {

    });

    it("should not let the owner set too high of a fee", async function() {

    });

    it("should let the owner change the amount of swap fee minted per pair", async function() {

    });

    it("should not let anyone but the owner change the amount of swap fee minted per pair", async function() {

    });

    it("should not let the owner set too high of amount minted", async function() {

    });

  });

  describe("Liquidity", async function() {
    it("should be able to add liquidity", async function() {

    });

    /// List of changes that need testing:
    /// -getAmountIn
    /// -getAmountOut
    /// -Swap
    ///   -minting the swap fee
    ///   -different swap fees by direction and asset

  });

});