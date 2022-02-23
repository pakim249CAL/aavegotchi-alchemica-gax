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
  deployAlchemica,
} from "../helpers/helpers";
import {
  GWEI,
  ETHER,
  YEAR,
  FUD_MAX_SUPPLY,
  FOMO_MAX_SUPPLY,
  ALPHA_MAX_SUPPLY,
  KEK_MAX_SUPPLY,
} from "../helpers/constants";


describe("Alchemica", function () {

  let signers: Signer[];
  let owner: Signer;
  let proxyAdmin: Contract;
  let fud: Contract;

  before(async function () {
    signers = await ethers.getSigners();
    owner = signers[0];
    proxyAdmin = await deployProxyAdmin(owner);
    fud = await deployAlchemica(
      owner,
      proxyAdmin,
      "Gotchiverse FUD",
      "FUD",
      FUD_MAX_SUPPLY,
      signers[1],
      signers[2],
      signers[3],
      );
  });

  it("should mint 10% of the total supply to the vesting contracts", async function() {
    expect(await fud.cap()).to.equal(FUD_MAX_SUPPLY);
    expect(await fud.balanceOf(signers[2].getAddress())).to.equal(FUD_MAX_SUPPLY.div(10));
    expect(await fud.balanceOf(signers[3].getAddress())).to.equal(FUD_MAX_SUPPLY.div(10));
  });


});