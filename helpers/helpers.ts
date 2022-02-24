import * as hre from "hardhat";
import { ethers } from "hardhat";
import { 
  BigNumber, 
  Signer, 
  Contract, 
  ContractFactory,} 
  from "ethers";

import {
  increaseTime,
  mine,
  currentTimestamp,
  address
} from "./utils";

export async function deployProxyAdmin(
  owner: Signer,
) : Promise<Contract> {
  let ProxyAdmin = await hre.ethers.getContractFactory("ProxyAdmin");
  return await ProxyAdmin.connect(owner).deploy();
}

export async function deployProxy(
  logic: Contract,
  admin: Signer | Contract,
) : Promise<Contract> {
  let Proxy = await hre.ethers.getContractFactory("TransparentUpgradeableProxy");
  return await Proxy.deploy(await address(logic), await address(admin), []);
}

export async function getProxyContract(
  contract: Contract,
) : Promise<Contract> {
  let Proxy = await hre.ethers.getContractFactory("TransparentUpgradeableProxy");
  return await Proxy.attach(contract.address);
}

export async function deployVestingContract(
  owner: Signer,
  proxyAdmin: Signer | Contract,
  beneficiary: Signer,
  start: BigNumber,
  decayFactor: BigNumber,
  revocable: boolean,
): Promise<Contract> {
  let AlchemicaVesting = await hre.ethers.getContractFactory("AlchemicaVesting");
  let implementation =  await AlchemicaVesting.connect(owner).deploy();
  let proxy = await deployProxy(implementation, proxyAdmin);
  let alchemicaVesting = await AlchemicaVesting.attach(proxy.address);
  await alchemicaVesting.connect(owner).initialize(
    await beneficiary.getAddress(),
    start,
    decayFactor,
    revocable,
  )
  return alchemicaVesting;
}

export async function deployAlchemica(
  owner: Signer,
  proxyAdmin: Contract,
  name: string,
  symbol: string,
  supply: BigNumber,
  realmDiamond: Contract | Signer,
  ecosystemVestingContract: Contract | Signer,
  gameplayVestingContract: Contract | Signer,
): Promise<Contract> {
  let AlchemicaToken = await hre.ethers.getContractFactory("AlchemicaToken");
  let implementation = await AlchemicaToken.connect(owner).deploy();
  let proxy = await deployProxy(implementation, proxyAdmin);
  let alchemicaToken = AlchemicaToken.attach(await address(proxy));
  await alchemicaToken.connect(owner).initialize(
    name,
    symbol,
    supply,
    await address(realmDiamond),
    await address(ecosystemVestingContract),
    await address(gameplayVestingContract),
  );
  return alchemicaToken;

}

export async function deployDEX(): Promise<Contract> {
  let contractFactory = await hre.ethers.getContractFactory("");
  let contract = await contractFactory.deploy();
  return contract;
}

