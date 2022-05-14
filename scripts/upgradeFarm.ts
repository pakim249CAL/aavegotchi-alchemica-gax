import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber, Signer, Contract, Wallet } from "ethers";
import {
  DefenderRelaySigner,
  DefenderRelayProvider,
} from "defender-relay-client/lib/ethers";

async function main() {
  const diamondCutFacet = hre.ethers.getContractAt(
    "DiamondCutFacet",
    "0x00"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
