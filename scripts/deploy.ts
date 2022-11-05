import { ethers } from "hardhat";
/*
Link Token: "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06"
Registry: "0x02777053d6764996e594c3E88AF1D58D5363a2e6"
Registrar: "0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d"
AnaAbonmanSozlesmesi: "0xc21D85b680Ac5ad88559FBd8093338C512e2AAdE"
AboneToken: "0xDaC819A2A27781a68EE660187f37885796c2cB6E"
*/
async function main() {
  const Makalelik = await ethers.getContractFactory("Makalelik");
  const makalelik = await Makalelik.deploy(
    "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", 
  "0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d",
  "0x02777053d6764996e594c3E88AF1D58D5363a2e6",
  "0xDaC819A2A27781a68EE660187f37885796c2cB6E");

  await makalelik.deployed();

  console.log(`Makalelik deployed to ${makalelik.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
