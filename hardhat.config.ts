import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "dotenv/config";
import "hardhat-typechain";
import { HardhatUserConfig } from "hardhat/types";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.5",
  },
  networks: {
    popcateum: {
      url: "https://dataseed.popcateum.org",
      accounts: [process.env.ADMIN || ''],
      chainId: 1213,
    },
  },
};

export default config;
