const Launcher = artifacts.require("./Launcher.sol")
const RICO = artifacts.require("./RICO.sol")
const MultiSigWalletWithDailyLimit = artifacts.require("./MultiSigWalletWithDailyLimit.sol")

// Set variables for your Responsible ICO:
const name = "Responsible ICO Token"; // token name
const symbol = "RIT"; // token symbol
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const now = parseInt(new Date() / 1000);

const publicSaleTokenSupply = totalTokenSupply * 90 / 100; // total token amount for the public sale
const publicSaleWeiCap = 100 * 10 ** 18; // Set the cap of the public sale to 100 ether.
const publicSaleStartTime = now + 172800; // Set the start of the Public dat to 2 days from now.

// Owner of the ICO. All ICO funds to be received in a multisig wallet.
var multisigWalletAddress1 = '0x0'; // Can be your own address. Defaults to the user who executes this script.
const multisigWalletAddress2 = '0x0'; // Must be different from address 1
const multisigWalletDailyLimit = 1 * 10 ** 18; // Allows an owner to withdraw a daily limit without multisig. Set to 1 ether.

/**
 * Set variables ONLY for RICO Standard ICO (not used with Simple ICO)
 */
// Take over Bid (TOB)
var TOBFunder; // Defaults to the user who executes this script.
const TOBStartTime = now + 72000; // sec
const TOBTokenSupply = totalTokenSupply * 10 / 100; // 8% of the totalTokenSupply
const TOBPrice = 10 * 10 ** 18; // = 10 ether for the TOB
// A second TOB owner can be set.
const TOBSecondOwner = '0x0'; // (Optional) Second owner of the TOB. Cannot be the same as TOBFunder.
const secondOwnerAllocation = totalTokenSupply * 0 / 100; // 0% of the totalTokenSupply is given to a second owner at the expense of the TOB funder.

const marketMaker = '0x0'; // (string) The first market maker's address

/**
 * Set variables ONLY for Simple ICO (not used with RICO Standard ICO)
 */
const separateAllocationTokenAmount = totalTokenSupply * 10 / 100; // Set the separate allocated tokens to 10% of the totalTokenSupply.
const separateAllocationLockTime = publicSaleStartTime + 2592000; // Set lock time of the separate allocation to 1 month.

module.exports = async function (callback) {

  const rico = await RICO.at(process.env.RICO_ADDR) // retrieve the deployed RICO instance on the network
  const launcher = await Launcher.at(process.env.LAUNCHER_ADDR) // retrieve the deployed Launcher instance on the network
  console.log(`RICO: ${rico.address} launcher: ${launcher.address}`)
  
  multisigWalletAddress1 = (!multisigWalletAddress1 || multisigWalletAddress1 == '0x0') ? await getAccount() : multisigWalletAddress1;
  const wallet = await MultiSigWalletWithDailyLimit.contract.new([multisigWalletAddress1, multisigWalletAddress2], 2, multisigWalletDailyLimit)
  console.log(`MultisigWallet: ${wallet.address}`)
  
  TOBFunder = await getAccount();

  var newICO;

  /**【RICO Standard ICO】
   *  launch the standardICO on the already deployed Launcher.sol
   *  see Launcher.sol for clarification on the parameters
   */
  newICO = await launcher.standardICO(
    name,
    symbol,
    decimals,
    wallet.address,
    [TOBStartTime, TOBTokenSupply, TOBPrice, secondOwnerAllocation],
    [publicSaleStartTime, publicSaleTokenSupply, publicSaleWeiCap],
    [TOBFunder, TOBSecondOwner],
    [marketMaker]
  )
  /**【Simple ICO】
   *  launch the simpleICO on the already deployed Launcher.sol
   *  see Launcher.sol for clarification on the parameters
   */
  // newICO = await launcher.simpleICO(
  //   name,
  //   symbol,
  //   decimals,
  //   wallet.address,
  //   [publicSaleStartTime, publicSaleTokenSupply, publicSaleWeiCap],
  //   [separateAllocationTokenAmount, separateAllocationLockTime]
  // )
  console.log(`tx:${newICO.tx}`)
}

function getAccount() {
  return new Promise((resolve, reject) => {
    web3.eth.getAccounts((err, accounts) => {
      const currentUser = accounts[0]
      resolve(currentUser)
    })
  })
}