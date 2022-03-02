require("dotenv").config();

import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "solidity-coverage";
import "hardhat-abi-exporter";
import "@typechain/hardhat";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const ALCHEMY_KEY = process.env.ALCHEMY_KEY;

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  solidity: {
    compilers: [
      {
        version: "0.5.2",
      },
      {
        version: "0.6.12",
      },
      {
        version: "0.7.3",
      },
      {
        version: "0.7.5",
      },
      {
        version: "0.8.0",
      },
      {
        version: "0.8.11",
      }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
    },
  },
  networks: {
    hardhat: {
      gas: 60000000,
      chainId: 1,
      blockGasLimit: 0x1fffffffffffff,
      allowUnlimitedContractSize: true,
      forking: {
        url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`,
        blockNumber: 23641001,
      }
    },
    local: {
      url: process.env.LOCAL_URL || "http://127.0.0.1:8545",
    },
    mainnet: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      maxFeePerGas: 1000 * 1000 * 1000 * 150,
      maxPriorityFeePerGas: 1000 * 1000 * 1000,
    },
    kovan: {
      url: `https://eth-kovan.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      maxFeePerGas: 1000 * 1000 * 1000 * 50,
      maxPriorityFeePerGas: 1000 * 1000 * 1000,
    },
    matic: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}`,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      maxFeePerGas: 1000 * 1000 * 1000 * 50,
      maxPriorityFeePerGas: 1000 * 1000 * 1000,
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_KEY}`,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      maxFeePerGas: 1000 * 1000 * 1000 * 2,
      maxPriorityFeePerGas: 1000 * 1000 * 1000,
      gas: 20000000,
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 55,
    coinmarketcap: "71a0e4d4-2872-4441-8dda-97464b6d5e55",
    token: "ETH",
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY/*
      {
        mainnet: process.env.ETHERSCAN_API_KEY || "PLACEHOLDER",
        matic: process.env.POLYGONSCAN_API_KEY || "PLACEHOLDER",
        mumbai: process.env.POLYGONSCAN_API_KEY || "PLACEHOLDER",
        kovan: process.env.ETHERSCAN_API_KEY || "PLACEHOLDER",
      }*/
  },
  abiExporter: {
    path: "./build",
    clear: true,
    flat: true,
    spacing: 2,
    pretty: true,
  },
  mocha: {
    timeout: 5000000,
  },
};
