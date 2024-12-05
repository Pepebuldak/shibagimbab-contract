import { ethers } from "hardhat";
import { deployProxy } from "./common";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("[Deployer account address]: " + deployer.address);

  const signerAddress = process.env.SIGNER_ADDRESS;
  const nftContractAddress = process.env.NFT_CONTRACT_ADDRESS;
  if (!signerAddress || !nftContractAddress) return;

  // Deploy the ClaimManager contract first to get its address
  const claimManagerAddress = await deployProxy(
    "ClaimManager",
    [], // Constructor arguments
    [signerAddress, nftContractAddress] // Initialize arguments
  );
  console.log(`NEXT_PUBLIC_CLAIM_MANAGER_CONTRACT=${claimManagerAddress}`);
  // Transfer NFT ownership to claim manager
  const nftContract = await ethers.getContractAt(
    "ShibaGimbapNFT",
    nftContractAddress
  );
  await nftContract.transferOwnership(claimManagerAddress);
  console.log("Ownership transferred");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
