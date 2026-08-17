const { ethers } = require("ethers");

const RPC = process.env.ALCHEMY_SEPOLIA_RPC;
const CONTRACT = "0x698C67e888DDfEbCcAE584e043e8e91AbDA30500";
const EXPECTED_USDT = "0x79af4e49901b107ece18b9fa79d99ff502e11c97";

const ABI = [
  "function usdt() view returns (address)",
  "function owner() view returns (address)",
  "function USDT_PER_ETH() view returns (uint256)",
  "function USDT_DECIMALS() view returns (uint256)",
  "function getContractEthBalance() view returns (uint256)",
  "function getContractUsdtBalance() view returns (uint256)"
];

async function main() {
  if (!RPC) {
    throw new Error("ALCHEMY_SEPOLIA_RPC is not configured");
  }

  const provider = new ethers.JsonRpcProvider(RPC);

  const network = await provider.getNetwork();

  console.log("CHAIN_ID=" + network.chainId);

  if (network.chainId !== 11155111n) {
    throw new Error("Wrong network. Expected Sepolia.");
  }

  const code = await provider.getCode(CONTRACT);

  console.log("CONTRACT_CODE=" + (code !== "0x" ? "FOUND" : "NOT_FOUND"));

  if (code === "0x") {
    throw new Error("No contract code found at address.");
  }

  const contract = new ethers.Contract(CONTRACT, ABI, provider);

  const usdt = await contract.usdt();
  const owner = await contract.owner();
  const rate = await contract.USDT_PER_ETH();
  const decimals = await contract.USDT_DECIMALS();
  const ethBalance = await contract.getContractEthBalance();
  const usdtBalance = await contract.getContractUsdtBalance();

  console.log("CONTRACT=" + CONTRACT);
  console.log("USDT=" + usdt);
  console.log("OWNER=" + owner);
  console.log("USDT_PER_ETH=" + rate);
  console.log("USDT_DECIMALS=" + decimals);
  console.log("ETH_BALANCE=" + ethers.formatEther(ethBalance));
  console.log("USDT_BALANCE=" + ethers.formatUnits(usdtBalance, decimals));

  if (usdt.toLowerCase() !== EXPECTED_USDT.toLowerCase()) {
    throw new Error("USDT contract address mismatch.");
  }

  if (rate !== 1000n) {
    throw new Error("Unexpected USDT_PER_ETH.");
  }

  if (decimals !== 6n) {
    throw new Error("Unexpected USDT_DECIMALS.");
  }

  console.log("VERIFICATION_SUCCESS=true");
}

main().catch((e) => {
  console.error("VERIFICATION_FAILED=" + e.message);
  process.exit(1);
});
