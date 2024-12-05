import { ethers } from "hardhat";

async function main() {
  // 컨트랙트 가져오기
  const CustomToken = await ethers.getContractFactory("ShibaGimbapNFT");
  const customToken = await CustomToken.deploy();

  await customToken.deployed();

  console.log("CustomToken deployed to:", customToken.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
