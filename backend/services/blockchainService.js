const Web3 = require('web3');
const contractABI = require('../abi/contract.json');
require('dotenv').config();
const web3 = new Web3(`https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`);

const account = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(account);

const contract = new web3.eth.Contract(contractABI, process.env.CONTRACT_ADDRESS);

// Hàm xác minh document bằng CID hoặc file hash
async function verifyDocument(hashInput) {
  try {
    let hash;
    if (typeof hashInput === 'string' && hashInput.startsWith('0x')) {
      hash = hashInput; // đã là hash
    } else {
      hash = web3.utils.keccak256(hashInput); // tính hash từ buffer hoặc CID
    }

    console.log("🔎 Verifying hash:", hash);
    const result = await contract.methods.verifyDocument(hash).call();
    console.log("✅ Document verification result:", result);
    return result;
  } catch (err) {
    console.error("❌ Error in verifyDocument:", err);
    throw err;
  }
}

// hàm lấy hợp đồng
async function getTotalContracts() {
  return await contract.methods.getTotalContracts().call();
}

async function getContract(index) {
  return await contract.methods.getContract(index).call();
}

module.exports = {
  storeCID,
  verifyDocument,
  getTotalContracts,
  getContract,
  addDocument
};