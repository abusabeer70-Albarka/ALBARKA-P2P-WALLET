const fs = require("fs");
const { ethers } = require("ethers");

const RPC = process.env.ALCHEMY_SEPOLIA_RPC;
const PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY;
const USDT_ADDRESS = "0x79af4e49901b107ece18b9fa79d99ff502e11c97";

async function main() {
  if (!RPC) throw new Error("ALCHEMY_SEPOLIA_RPC is missing");
  if (!PRIVATE_KEY) throw new Error("DEPLOYER_PRIVATE_KEY is missing");

  const provider = new ethers.JsonRpcProvider(RPC);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  const network = await provider.getNetwork();

  if (network.chainId !== 11155111n) {
    throw new Error(`Wrong network. Expected Sepolia 11155111, got ${network.chainId}`);
  }

  const expectedDeployer =
    "0x37115b87509dab0069d66cf342da47d588e0cf89";

  if (wallet.address.toLowerCase() !== expectedDeployer) {
    throw new Error("Deployer address does not match expected address");
  }

  const balance = await provider.getBalance(wallet.address);

  console.log("DEPLOYER=" + wallet.address);
  console.log("CHAIN_ID=" + network.chainId);
  console.log("BALANCE_ETH=" + ethers.formatEther(balance));
  console.log("USDT_CONSTRUCTOR=" + USDT_ADDRESS);

  const abi = JSON.parse(
    fs.readFileSync("contracts/build/AlbarkaSwapTestnet.abi", "utf8")
  );

  const bytecode =
    "0x" +
    fs.readFileSync("contracts/build/AlbarkaSwapTestnet.bin", "utf8").trim();

  const factory = new ethers.ContractFactory(abi, bytecode, wallet);

  console.log("DEPLOYING_ALBARKA_SWAP_TESTNET...");

  const contract = await factory.deploy(USDT_ADDRESS);

  const tx = contract.deploymentTransaction();

  console.log("DEPLOYMENT_TX_HASH=" + tx.hash);

  await contract.waitForDeployment();

  const address = await contract.getAddress();

  console.log("CONTRACT_ADDRESS=" + address);
  console.log("DEPLOYMENT_CONFIRMED=true");
}

main().catch((error) => {
  console.error("DEPLOYMENT_FAILED:", error.message);
  process.exit(1);
});
