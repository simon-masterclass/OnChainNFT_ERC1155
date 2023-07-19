/** @format */

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// deploy/01_deploy_library.js
const { ethers } = require("hardhat");

async function main() {
  const signers = await ethers.getSigners();

  // Deploy the library contract
  const LibraryContract = await hre.ethers.getContractFactory("BravoLibrary", {
    signer: signers[0],
  });
  const libraryContract = await LibraryContract.deploy();
  
  // await libraryContract.address

  // Deploy the main contract and link the library
  const MainContract = await hre.ethers.getContractFactory(
    "OnchainBravoNFTs",
    { signer: signers[0] },
    {
      libraries: {
        LibraryContract: libraryContract.address,
      },
    }
  );
  const mainContract = await MainContract.deploy();
  // await mainContract.address;

  console.log("LibraryContract deployed to:", libraryContract.address);
  console.log("MainContract deployed to:", mainContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
