/** @format */

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// deploy/01_deploy_library.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  // Deploy the library contract
  const LibraryContract = await ethers.getContractFactory("BravoLibrary");
  const libraryContract = await upgrades.deployProxy(LibraryContract);
  await libraryContract.deployed();

  // Deploy the main contract and link the library
  const MainContract = await ethers.getContractFactory("OnchainBravoNFTs");
  const mainContract = await upgrades.deployProxy(MainContract, [
    libraryContract.address,
  ]);
  await mainContract.deployed();

  console.log("LibraryContract deployed to:", libraryContract.address);
  console.log("MainContract deployed to:", mainContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
