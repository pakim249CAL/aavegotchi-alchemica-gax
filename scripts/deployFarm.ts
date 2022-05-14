import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber, Signer, Contract, Wallet } from "ethers";
import {
  DefenderRelaySigner,
  DefenderRelayProvider,
} from "defender-relay-client/lib/ethers";

import { sleep, address } from "../helpers/utils";

async function main() {
  const credentials = {
    apiKey: process.env.DEFENDER_API_KEY,
    apiSecret: process.env.DEFENDER_API_SECRET,
  };
  const provider = new DefenderRelayProvider(credentials);
  const owner = new DefenderRelaySigner(credentials, provider, {
    speed: "fast",
  });
  const DiamondCutFacet = await hre.ethers.getContractFactory(
    "DiamondCutFacet"
  );
  const diamondCutFacet = await DiamondCutFacet.connect(
    owner
  ).deploy();
  await diamondCutFacet.deployed();
  console.log("DiamondCutFacet: " + diamondCutFacet.address);
  const DiamondLoupeFacet = await hre.ethers.getContractFactory(
    "DiamondLoupeFacet"
  );
  const diamondLoupeFacet = await DiamondLoupeFacet.connect(
    owner
  ).deploy();
  await diamondLoupeFacet.deployed();
  console.log("DiamondLoupeFacet: " + diamondLoupeFacet.address);
  const OwnershipFacet = await hre.ethers.getContractFactory(
    "OwnershipFacet"
  );
  let ownershipFacet = await OwnershipFacet.connect(owner).deploy();
  await ownershipFacet.deployed();
  console.log("OwnershipFacet: " + ownershipFacet.address);
  const FarmFacet = await hre.ethers.getContractFactory("FarmFacet");
  const farmFacet = await FarmFacet.connect(owner).deploy();
  await farmFacet.deployed();
  console.log("FarmFacet: " + farmFacet.address);
  const FarmInit = await hre.ethers.getContractFactory("FarmInit");
  const farmInit = await FarmInit.connect(owner).deploy();
  await farmInit.deployed();
  console.log("FarmInit: " + farmInit.address);
  const ReentrancyGuardInit = await hre.ethers.getContractFactory(
    "ReentrancyGuardInit"
  );
  const reentrancyGuardInit = await ReentrancyGuardInit.connect(
    owner
  ).deploy();
  await reentrancyGuardInit.deployed();
  console.log("ReentrancyGuardInit: " + reentrancyGuardInit.address);

  const GAXLiquidityTokenReward = await hre.ethers.getContractFactory(
    "GAXLiquidityTokenReward"
  );
  const gaxLiquidityTokenReward =
    await GAXLiquidityTokenReward.connect(owner).deploy();
  await gaxLiquidityTokenReward.deployed();
  console.log(
    "GAXLiquidityTokenReward: " + gaxLiquidityTokenReward.address
  );

  const FarmAndGLTRDeployer = await hre.ethers.getContractFactory(
    "FarmAndGLTRDeployer"
  );
  const farmAndGLTRDeployer = await FarmAndGLTRDeployer.connect(
    owner
  ).deploy();
  await farmAndGLTRDeployer.deployed();
  console.log("FarmAndGLTRDeployer: " + farmAndGLTRDeployer.address);

  const Diamond = await hre.ethers.getContractFactory("Diamond");
  const diamond = await Diamond.connect(owner).deploy(
    farmAndGLTRDeployer.address,
    diamondCutFacet.address
  );
  await diamond.deployed();
  console.log("Diamond: " + diamond.address);

  let tx = await gaxLiquidityTokenReward
    .connect(owner)
    .transfer(
      diamond.address,
      await gaxLiquidityTokenReward.balanceOf(
        await owner.getAddress()
      )
    );
  await tx.wait();
  console.log("GAXLiquidityTokenReward transferred to Diamond");

  const deployedAddresses = {
    diamond: diamond.address,
    rewardToken: gaxLiquidityTokenReward.address,
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
  tx = await farmAndGLTRDeployer
    .connect(owner)
    .deployFarmAndGLTR(deployedAddresses, farmInitParams);

  await tx.wait();
  ownershipFacet = await ethers.getContractAt(
    "OwnershipFacet",
    diamond.address
  );
  tx = await ownershipFacet
    .connect(owner)
    .transferOwnership("0x8FEebfA4aC7AF314d90a0c17C3F91C800cFdE44B"); // TODO: Change this to whoever we want to transfer ownership of contract to
  await tx.wait();
  console.log("Owner: " + (await ownershipFacet.owner()));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
