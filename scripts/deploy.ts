import { ethers } from "hardhat";

async function main() {
  const LendingPool = await ethers.getContractFactory("LendingPool");
  const lp = await LendingPool.deploy();

  await lp.deployed();

  console.log("Lending pool deployed to:", lp.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
