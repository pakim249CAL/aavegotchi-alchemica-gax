import * as hre from 'hardhat';
import {ethers} from 'hardhat';
import { 
  BigNumber,
  Signer,
  Contract,
} from 'ethers';
import {
  deployProxyAdmin, 
  deployVestingImplementation, 
  deployAndInitializeVestingProxy, 
  deployAlchemicaImplementation,
  deployAndInitializeAlchemicaProxy,
  deployGAXFactory,
  deployGAXRouter,
  verify
} from "../helpers/helpers";
import {VerifyParams} from "../helpers/types";
import {sleep, address} from "../helpers/utils";
import {
  ECOSYSTEM_VESTING_BENEFICIARY,
  GAMEPLAY_VESTING_BENEFICIARY,
  FUD_PARAMS,
  FOMO_PARAMS,
  ALPHA_PARAMS,
  KEK_PARAMS,
  REALM_DIAMOND,
} from "../helpers/constants";



async function deployVestingContracts(
  owner: Signer,
  proxyAdmin: Contract,
) {
  let returnParams: VerifyParams[] = [];
  let vestingImplementation = await deployVestingImplementation(owner);
  console.log("Vesting Implementation: " + vestingImplementation.contract.address)
  returnParams.push(vestingImplementation);
  await vestingImplementation.contract.deployed();

  let ecosystemVestingProxy = await deployAndInitializeVestingProxy(
    owner,
    vestingImplementation.contract,
    ECOSYSTEM_VESTING_BENEFICIARY,
    proxyAdmin,
  );
  console.log("Ecosystem Vesting: " + ecosystemVestingProxy.contract.address);
  returnParams.push(ecosystemVestingProxy);
  let gameplayVestingProxy = await deployAndInitializeVestingProxy(
    owner,
    vestingImplementation.contract,
    GAMEPLAY_VESTING_BENEFICIARY,
    proxyAdmin,
  )
  console.log("Gameplay Vesting: " + gameplayVestingProxy.contract.address);
  returnParams.push(gameplayVestingProxy);
  return returnParams;
}

async function deployAlchemica(
  owner: Signer,
  proxyAdmin: Contract,
  realmDiamond: string,
  gameplayVestingContract: Contract,
  ecosystemVestingContract: Contract,
) {
  let returnParams: VerifyParams[] = [];
  let alchemicaImplementation = await deployAlchemicaImplementation(owner);
  console.log("Alchemica Implementation: " + alchemicaImplementation.contract.address);
  returnParams.push(alchemicaImplementation);
  await alchemicaImplementation.contract.deployed();

  for(let params of [FUD_PARAMS, FOMO_PARAMS, ALPHA_PARAMS, KEK_PARAMS]) {
    let alchemicaProxy = await deployAndInitializeAlchemicaProxy(
      owner,
      alchemicaImplementation.contract,
      proxyAdmin,
      params.name,
      params.symbol,
      params.supply,
      realmDiamond,
      gameplayVestingContract,
      ecosystemVestingContract,

    );
    console.log(params.name + ": " + alchemicaProxy.contract.address);
    returnParams.push(alchemicaProxy);
  }

  return returnParams;
}

async function deployGAX(
  owner: Signer,
) {
  let returnParams: VerifyParams[] = [];
  let gaxFactory = await deployGAXFactory(owner);
  returnParams.push(gaxFactory);
  let gaxRouter = await deployGAXRouter(
    owner,
    gaxFactory.contract,
  );
  returnParams.push(gaxRouter);
  return returnParams;
}

async function main() {
  let verifyParams: VerifyParams[] = [];
  const signers = await hre.ethers.getSigners();
  const owner = signers[0];
  const proxyAdmin = await deployProxyAdmin(owner);
  console.log("ProxyAdmin: ", proxyAdmin.contract.address);
  verifyParams.push(proxyAdmin);

  let [vestingImplementation, ecosystemVesting, gameplayVesting] = await deployVestingContracts(owner, proxyAdmin.contract);
  verifyParams.push(vestingImplementation, ecosystemVesting, gameplayVesting);
  
  let [alchemicaImplementation, fud, fomo, alpha, kek] = await deployAlchemica(
    owner, 
    proxyAdmin.contract, 
    REALM_DIAMOND, 
    gameplayVesting.contract, 
    ecosystemVesting.contract
  );
  verifyParams.push(alchemicaImplementation, fud, fomo, alpha, kek);

  let [gaxFactory, gaxRouter] = await deployGAX(owner);
  console.log("GAXFactory: ", gaxFactory.contract.address);
  console.log("GAXRouter: ", gaxRouter.contract.address);
  verifyParams.push(gaxFactory, gaxRouter);

  if(process.env.VERIFY) {
    await verify(verifyParams);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });