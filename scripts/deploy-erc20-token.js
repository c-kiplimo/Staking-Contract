const hre = require("hardhat");

async function main() {
  // Get the deployer's account
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("Deploying ERC20Token with the account:", deployer.address);

  // Get the ContractFactory for the ERC20Token contract
  const ERC20Token = await hre.ethers.getContractFactory("ERC20Token");
  
  // Deploy the ERC20Token contract with an initial supply of 1,000,000 tokens
  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18); // 1,000,000 tokens with 18 decimals
  const erc20Token = await ERC20Token.deploy(initialSupply);
  
  // Wait for the deployment transaction to be mined
  await erc20Token.deployed();
  
  console.log("ERC20Token contract deployed to:", erc20Token.address);
}

// Execute the main function and handle errors
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
