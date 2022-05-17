import * as hre from "hardhat";
import { ethers, run } from "hardhat";
import {
  convertFacetAndSelectorsToString,
  DeployUpgradeTaskArgs,
  FacetsAndAddSelectors,
} from "../../tasks/deployUpgrade";
import {
  diamondOwner,
  maticDiamondAddress,
} from "../helperFunctions";

export async function upgrade() {
  const FarmFacet = await hre.ethers.getContractFactory("FarmFacet");
  const farmFacet = await FarmFacet.deploy();
  await farmFacet.deployed();

  const diamondCutFacet = await hre.ethers.getContractAt(
    "DiamondCutFacet",
    "0xDCd215010246B223819277e6F651E726669cf19A"
  );

  interface Cut {
    facetAddress: string;
    action: 0 | 1 | 2;
    functionSelectors: string[];
  }

  const cut: Cut[] = [
    {
      facetAddress: farmFacet.address,
      action: 1,
      functionSelectors: ["0x93f1a40b"],
    },
  ];

  await diamondCutFacet.diamondCut(
    cut,
    ethers.constants.AddressZero,
    "0x"
  );
}

if (require.main === module) {
  upgrade()
    .then(() => process.exit(0))
    // .then(() => console.log('upgrade completed') /* process.exit(0) */)
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}
