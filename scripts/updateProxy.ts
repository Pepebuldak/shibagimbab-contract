import { ethers, upgrades } from "hardhat";
import { upgradesProxy } from "./common";

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("[Owner account address]: " + owner.address);

  const rewardManagerAddress = "0x5E132f98753A94d804e90F08613e19954a12bb59";

  //If the OpenZeppelin files are lost, uncomment the upgrades.forceImport section and run it first. Then, make changes to the source code to introduce modifications. After that, call upgradesProxy again, and the upgrade should proceed successfully.
  /*
  const implementation = await ethers.getContractFactory("ClaimManager");
  await upgrades.forceImport(claimManagerAddress, implementation);
  */

  // contract upgrade proxy
  const upgraded = await upgradesProxy(rewardManagerAddress, "RewardManager");
  console.log("Upgrade Finish: " + JSON.stringify(upgraded));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
