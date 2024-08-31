const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    const MyNFT = await hre.ethers.getContractAt("MyNFT", "");

    const tokenURI = "https://gateway.pinata.cloud/ipfs/QmbQVTr6QRZhiYmauxec29RhryLu4erSY83u9qLMprEP78";
    const recipientAddress = ""; // Replace with the address to receive the NFT

    const tx = await MyNFT.mintNFT(recipientAddress, tokenURI);
    await tx.wait();

    console.log("Minted NFT with tokenURI:", tokenURI);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
