import * as hre from "hardhat";
import { ethers, run } from "hardhat";
import { BigNumber, BigNumberish } from "ethers";
import {
  convertFacetAndSelectorsToString,
  DeployUpgradeTaskArgs,
  FacetsAndAddSelectors,
} from "../../tasks/deployUpgrade";
import {
  diamondOwner,
  maticDiamondAddress,
} from "../helperFunctions";
import { UpdateStartBlockInit__factory } from "../../typechain-types";

import {
  UpdateStartBlockInit,
  UpdateStartBlockInitInterface,
} from "../../typechain-types/UpdateStartBlockInit";

export async function upgrade() {
  const UpdateStartBlockInit = await ethers.getContractFactory(
    "UpdateStartBlockInit"
  );
  const updateStartBlockInit = await UpdateStartBlockInit.deploy();
  await updateStartBlockInit.deployed();
  console.log(
    "UpdateStartBlockInit: " + updateStartBlockInit.address
  );

  const diamondCutFacet = await hre.ethers.getContractAt(
    "DiamondCutFacet",
    "0x1fE64677Ab1397e20A1211AFae2758570fEa1B8c"
  );

  let iface: UpdateStartBlockInitInterface =
    new ethers.utils.Interface(
      UpdateStartBlockInit__factory.abi
    ) as UpdateStartBlockInitInterface;

  await diamondCutFacet.diamondCut(
    [],
    updateStartBlockInit.address,
    iface.encodeFunctionData("init", [
      BigNumber.from(28471715 + 40000),
    ])
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