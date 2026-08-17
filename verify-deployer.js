const { ethers } = require("ethers");

async function main() {
  const rpc = process.env.ALCHEMY_SEPOLIA_RPC;
  const privateKey = process.env.DEPLOYER_PRIVATE_KEY;

  if (!rpc) throw new Error("ALCHEMY_SEPOLIA_RPC is missing");
  if (!privateKey) throw new Error("DEPLOYER_PRIVATE_KEY is missing");

  const provider = new ethers.JsonRpcProvider(rpc);
  const wallet = new ethers.Wallet(privateKey, provider);

  const network = await provider.getNetwork();
  const balance = await provider.getBalance(wallet.address);

  console.log("DEPLOYER_ADDRESS=" + wallet.address);
  console.log("CHAIN_ID=" + network.chainId.toString());
  console.log("BALANCE_ETH=" + ethers.formatEther(balance));

  if (network.chainId !== 11155111n) {
    throw new Error("Wrong network: expected Sepolia 11155111");
  }

  if (wallet.address.toLowerCase() !==
      "0x37115b87509dab0069d66cf342da47d588e0cf89".toLowerCase()) {
    throw new Error("DEPLOYER_PRIVATE_KEY does not match expected deployer address");
  }

  if (balance === 0n) {
    throw new Error("Deployer has no Sepolia ETH for gas");
  }

  console.log("DEPLOYER_VERIFICATION_SUCCESS");
}

main().catch((error) => {
  console.error("VERIFICATION_FAILED:", error.message);
  process.exit(1);
});
