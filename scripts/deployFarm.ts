import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber, Signer, Contract, Wallet } from "ethers";

import { sleep, address } from "../helpers/utils";

async function main() {
  const owner = new ethers.Wallet(
    process.env.PRIVATE_KEY,
    hre.ethers.provider
  );
  const DiamondCutFacet = await hre.ethers.getContractFactory(
    "DiamondCutFacet"
  );
  const diamondCutFacet = await DiamondCutFacet.deploy();
  await diamondCutFacet.deployed();
  console.log("DiamondCutFacet: " + diamondCutFacet.address);
  const DiamondLoupeFacet = await hre.ethers.getContractFactory(
    "DiamondLoupeFacet"
  );
  const diamondLoupeFacet = await DiamondLoupeFacet.deploy();
  await diamondLoupeFacet.deployed();
  console.log("DiamondLoupeFacet: " + diamondLoupeFacet.address);
  const OwnershipFacet = await hre.ethers.getContractFactory(
    "OwnershipFacet"
  );
  let ownershipFacet = await OwnershipFacet.deploy();
  await ownershipFacet.deployed();
  console.log("OwnershipFacet: " + ownershipFacet.address);
  const FarmFacet = await hre.ethers.getContractFactory("FarmFacet");
  const farmFacet = await FarmFacet.deploy();
  await farmFacet.deployed();
  console.log("FarmFacet: " + farmFacet.address);
  const FarmInit = await hre.ethers.getContractFactory("FarmInit");
  const farmInit = await FarmInit.deploy();
  await farmInit.deployed();
  console.log("FarmInit: " + farmInit.address);
  const ReentrancyGuardInit = await hre.ethers.getContractFactory(
    "ReentrancyGuardInit"
  );
  const reentrancyGuardInit = await ReentrancyGuardInit.deploy();
  await reentrancyGuardInit.deployed();
  console.log("ReentrancyGuardInit: " + reentrancyGuardInit.address);
  const FarmAndGLTRDeployer = await hre.ethers.getContractFactory(
    "FarmAndGLTRDeployer"
  );
  const farmAndGLTRDeployer = await FarmAndGLTRDeployer.deploy();
  await farmAndGLTRDeployer.deployed();
  console.log("FarmAndGLTRDeployer: " + farmAndGLTRDeployer.address);

  const deployedAddresses = {
    diamondCutFacet: diamondCutFacet.address,
    diamondLoupeFacet: diamondLoupeFacet.address,
    ownershipFacet: ownershipFacet.address,
    farmFacet: farmFacet.address,
    farmInit: farmInit.address,
    reentrancyGuardInit: reentrancyGuardInit.address,
  };
  const latestBlock = await hre.ethers.provider.getBlock("latest");
  const latestBlockNumber = latestBlock.number;
  const farmInitParams = {
    startBlock: latestBlockNumber + 1000,
    decayPeriod: 38000 * 365,
  };

  let returnData = await farmAndGLTRDeployer
    .connect(owner)
    .callStatic.deployFarmAndGLTR(deployedAddresses, farmInitParams);
  const diamondAddress = returnData.diamond_;
  const gltrAddress = returnData.rewardToken_;
  console.log("diamond: " + diamondAddress);
  console.log("gltr: " + gltrAddress);
  let tx = await farmAndGLTRDeployer
    .connect(owner)
    .deployFarmAndGLTR(deployedAddresses, farmInitParams);

  ownershipFacet = await ethers.getContractAt(
    "OwnershipFacet",
    diamondAddress
  );
  const gltr = await ethers.getContractAt(
    "GAXLiquidityTokenReward",
    gltrAddress
  );

  console.log(await ownershipFacet.owner());

  await tx.wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
