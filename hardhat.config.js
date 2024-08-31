/** @type import('hardhat/config').HardhatUserConfig */

require('@nomiclabs/hardhat-ethers')
module.exports = {
  solidity: {
    version: "0.8.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    // sepolia: {
    //   url: `https://sepolia.infura.io/v3/1b418729725246bbaee99a2ac3ac2870`,
    //   accounts: [``] 
    // },
    localhost: {
      url: "http://127.0.0.1:8545",
    }
  }
};