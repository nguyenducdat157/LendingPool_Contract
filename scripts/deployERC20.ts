import { ethers } from "hardhat";

async function main() {
  const DaiToken = await ethers.getContractFactory("DAIToken");
  const dai = await DaiToken.deploy();

  await dai.deployed();

  console.log("DaiToken deployed to:", dai.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
