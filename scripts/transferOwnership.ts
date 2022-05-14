import * as hre from "hardhat";
import { ethers } from "hardhat";
import { BigNumber, Signer, Contract, Wallet } from "ethers";
import {
  DefenderRelaySigner,
  DefenderRelayProvider,
} from "defender-relay-client/lib/ethers";

async function main() {
  const credentials = {
    apiKey: process.env.DEFENDER_API_KEY,
    apiSecret: process.env.DEFENDER_API_SECRET,
  };
  const provider = new DefenderRelayProvider(credentials);
  const owner = new DefenderRelaySigner(credentials, provider, {
    speed: "fast",
  });

  let ownershipFacet = await hre.ethers.getContractAt(
    "OwnershipFacet",
    "0xB77225AD50bF0Ea5c9a51Dcf17D0D503Aca44DAD"
  );
  await ownershipFacet
    .connect(owner)
    .transferOwnership("0x8FEebfA4aC7AF314d90a0c17C3F91C800cFdE44B");
  console.log("New Owner: " + (await ownershipFacet.owner()));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
