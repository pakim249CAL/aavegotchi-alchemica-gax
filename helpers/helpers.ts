import * as hre from "hardhat";
import { ethers } from "hardhat";
import { 
  BigNumber, 
  Signer, 
  Contract, 
  ContractFactory,} 
  from "ethers";

export async function address(
  contractOrSigner: Contract | Signer,
) : Promise<string> {
  if (contractOrSigner instanceof Contract) {
    return contractOrSigner.address;
  } else {
    return await contractOrSigner.getAddress();
  }
}

export async function deployVestingContract(
  owner: Signer,
  beneficiary: Signer,
  start: BigNumber,
  decayFactor: BigNumber,
  revocable: boolean,
): Promise<Contract> {
  let AlchemicaVesting = await hre.ethers.getContractFactory("AlchemicaVesting");
  return await AlchemicaVesting.connect(owner).deploy(
    await beneficiary.getAddress(),
    start,
    decayFactor,
    revocable,
  );;
}

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
  let alchemicaToken = await AlchemicaToken.connect(owner).deploy();
  console.log(await address(alchemicaToken));
  let proxy = await deployProxy(alchemicaToken, proxyAdmin);
  alchemicaToken = AlchemicaToken.attach(await address(proxy));
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

export async function increaseTime(time: number): Promise<void> {
  await hre.network.provider.send("evm_setNextBlockTimestamp", [await currentTimestamp() + time]);
}

export async function mine(times: number = 1): Promise<void> {
  for (let i = 0; i < times; i++) {
    await hre.network.provider.send("evm_mine", []);
  }
}

export async function currentTimestamp(): Promise<number> {
  let block = await hre.ethers.provider.getBlock("latest");
  return block.timestamp;
}