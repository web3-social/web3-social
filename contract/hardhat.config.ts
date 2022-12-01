import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-web3";
import "hardhat-gas-reporter";
import * as dotenv from 'dotenv';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  gasReporter: {
    enabled: true,
    currency: 'USD',
    coinmarketcap: process.env.COINMARKETCAP_KEY,
    token: 'DAI',
    gasPriceApi: `https://api.gnosisscan.io/api?module=proxy&action=eth_gasPrice&apiKey=${process.env.ETHERSCAN_API_KEY}`,
  }
};

export default config;
