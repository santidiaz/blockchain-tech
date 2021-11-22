
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require('hardhat-contract-sizer');

module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    }
  },
  // defaultNetwork: "rinkeby", // <ganache> por defecto.
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
  networks: {
    hardhat: {
      chainid: 31337
    },
    ganache: {
      chainid: 5777,
      url: process.env.GANACHE_URL,
      accounts: [process.env.PRIVATE_KEY_G1, process.env.PRIVATE_KEY_G2, process.env.PRIVATE_KEY_G3, 
        process.env.PRIVATE_KEY_G4, process.env.PRIVATE_KEY_G5, process.env.PRIVATE_KEY_G6, process.env.PRIVATE_KEY_G7, process.env.PRIVATE_KEY_G8],
      from: process.env.ACCOUNT_ADDRESS_G,
      gas: 2100000,
      gasPrice: 8000000000
    },
    rinkeby: {
      chainid: 4,
      url: process.env.RINKEBY_URL,
      accounts: [process.env.PRIVATE_KEY_R1],
      from: process.env.ACCOUNT_ADDRESS_R1
    }
  }
};
