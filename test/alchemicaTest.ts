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
  FUD_PARAMS
} from "../helpers/constants";


describe("Alchemica", function () {

  let signers: Signer[];
  let owner: Signer;
  let realmDiamond: Signer;
  let proxyAdmin: Contract;
  let fud: Contract;

  before(async function () {
    signers = await ethers.getSigners();
    owner = signers[0];
    realmDiamond = signers[1];
    proxyAdmin = await deployProxyAdmin(owner);
    fud = await deployAlchemica(
      owner,
      proxyAdmin,
      FUD_PARAMS.name,
      FUD_PARAMS.symbol,
      FUD_PARAMS.supply,
      realmDiamond,
      signers[2],
      signers[3],
      );
  });

  it("should mint 10% of the total supply to the vesting contracts", async function() {
    expect(await fud.cap()).to.equal(FUD_PARAMS.supply);
    expect(await fud.balanceOf(signers[2].getAddress())).to.equal(FUD_PARAMS.supply.div(10));
    expect(await fud.balanceOf(signers[3].getAddress())).to.equal(FUD_PARAMS.supply.div(10));
  });

  it("Realm diamond should have access to minting", async function() {
    await fud.connect(realmDiamond).mint(await signers[4].getAddress(), 1);
    expect(await fud.balanceOf(await signers[4].getAddress())).to.equal(1);
  });


});