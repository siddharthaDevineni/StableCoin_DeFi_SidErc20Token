import { ethers } from "hardhat";

async function main() {
  const SID = await ethers.getContractFactory("SID");
  const sidToken = await SID.deploy();
  console.log("SidTokenERC20 deployed to: ", await sidToken.getAddress());
  const addr = ethers.getAddress("0xFf58d746A67C2E42bCC07d6B3F58406E8837E883");
  await sidToken.transfer(addr, ethers.parseUnits("50", 18));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
