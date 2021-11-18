
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.4",
  // defaultNetwork: "rinkeby", // <ganache> por defecto.
  networks: {
    hardhat: {
      chainid: 31337
    },
    ganache: {
      chainid: 5777,
      url: process.env.GANACHE_URL,
      accounts: [process.env.PRIVATE_KEY_G1, process.env.PRIVATE_KEY_G2],
      from: process.env.ACCOUNT_ADDRESS_G
    },
    rinkeby: {
      chainid: 4,
      url: process.env.RINKEBY_URL,
      accounts: [process.env.PRIVATE_KEY_R],
      from: process.env.ACCOUNT_ADDRESS_R
    }
  }
};
