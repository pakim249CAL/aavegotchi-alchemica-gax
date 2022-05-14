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
    "0xB77225AD50bF0Ea5c9a51Dcf17D0D503Aca44DAD"
  );
  await diamondCutFacet.diamondCut();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
