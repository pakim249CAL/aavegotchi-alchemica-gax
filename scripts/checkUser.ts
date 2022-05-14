import { ethers } from "hardhat";
import { FarmFacet } from "../typechain-types/FarmFacet";
import { upgrade } from "./upgrades/upgrade-rewardDebt";

async function main() {
  const diamondAddress = "0xB77225AD50bF0Ea5c9a51Dcf17D0D503Aca44DAD";
  const user = "0xC3c2e1Cf099Bc6e1fA94ce358562BCbD5cc59FE5";

  await upgrade();

  const diamond = (await ethers.getContractAt(
    "FarmFacet",
    diamondAddress
  )) as FarmFacet;

  const info = await diamond.allUserInfo(user);
  console.log("info:", info);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
