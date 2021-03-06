import { 
  BigNumber, 
  Contract 
} from "ethers";

export type AlchemicaParams = {
  name: string;
  symbol: string;
  supply: BigNumber;
}

export type VerifyParams = {
  contract: Contract;
  constructorArgs: any[];
}