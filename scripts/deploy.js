const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy ERC20Token first
  const ERC20Token = await hre.ethers.getContractFactory("ERC20Token");
  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18);
  const erc20Token = await ERC20Token.deploy(initialSupply);
  await erc20Token.deployed();
  
  console.log("ERC20Token deployed to:", erc20Token.address);

  // Deploy EtherStaking
  const EtherStaking = await hre.ethers.getContractFactory("EtherStaking");
  const etherStaking = await EtherStaking.deploy(
    hre.ethers.utils.parseUnits("0.0000000001", 18), // Reward rate (0.0000000001 tokens per staking period)
    86400 // Staking period (1 day in seconds)
  );
  await etherStaking.deployed();
  
  console.log("EtherStaking contract deployed to:", etherStaking.address);

  // Deploy ERC20Staking
  const ERC20Staking = await hre.ethers.getContractFactory("ERC20Staking");
  const rewardRate = hre.ethers.utils.parseUnits("0.01", 18); // Reward rate (0.01 tokens per staking period)
  const stakingPeriod = 86400; // Staking period (1 day in seconds)
  const erc20Staking = await ERC20Staking.deploy(
    erc20Token.address, // Address of the deployed ERC20 token
    rewardRate,
    stakingPeriod
  );
  await erc20Staking.deployed();
  
  console.log("ERC20Staking contract deployed to:", erc20Staking.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
