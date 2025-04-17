import { ethers } from "hardhat";
import { deployProxy } from "./common";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("[Deployer account address]: " + deployer.address);

  const signerAddress = process.env.SIGNER_ADDRESS;
  const tokenAddress = process.env.TOKEN_CONTRACT_ADDRESS;
  if (!signerAddress || !tokenAddress) return;

  // Deploy the ClaimManager contract first to get its address
  const rewardManagerAddress = await deployProxy(
    "RewardManager",
    [], // Constructor arguments
    [signerAddress, tokenAddress] // Initialize arguments
  );
  console.log(`NEXT_PUBLIC_REWARD_MANAGER_CONTRACT=${rewardManagerAddress}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
