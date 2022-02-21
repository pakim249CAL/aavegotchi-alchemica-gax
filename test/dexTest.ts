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
  deployVestingContract,
  increaseTime,
  mine,
  currentTimestamp,
} from "../helpers/helpers";
import {
  GWEI,
  ETHER,
  YEAR,
} from "../helpers/constants";

describe("DEX Testing", function() {
  let signers: Signer[];
  let owner: Signer;
  let beneficiary: Signer;
  let token: Contract;

  
  before(async function () {
    signers = await ethers.getSigners();
    owner = signers[0];
    beneficiary = signers[1];
    let tokenFactory = await ethers.getContractFactory("Token");
    token = await tokenFactory.deploy();
    await token.deployed();
  });

});