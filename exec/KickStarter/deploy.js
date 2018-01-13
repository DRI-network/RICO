const Launcher = artifacts.require("./Launcher.sol")
const RICO = artifacts.require("./RICO.sol")
const MultiSigWalletWithDailyLimit = artifacts.require("./MultiSigWalletWithDailyLimit.sol")

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 10 / 100
const tobWeiLimit = 100 * 10 ** 18
const now = parseInt(new Date() / 1000)
const tobStartTime = now + 72000; //sec

const podTokenSupply = totalTokenSupply * 90 / 100
const podWeiLimit = 100 * 10 ** 18
const podStartTime = now + 172000; //sec

const lastSupply = totalTokenSupply * 30 / 100;

const marketMaker = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set first market maker's address 
const owner = 0x8a20a13b75d0aefb995c0626f22df0d98031a4b6;
const dailyLimit = 200 * 10 ** 18

module.exports = async function (callback) {

  const rico = await RICO.at(process.env.RICO_ADDR) // ropsten tsetnet
  const launcher = await Launcher.at(process.env.LAUNCHER_ADDR) //ropsten testnet
  const po = await getAccount()

  console.log(`RICO: ${rico.address} launcher: ${launcher.address}`)

  const wallet = await MultiSigWalletWithDailyLimit.new([owner, po], 2, dailyLimit)

  console.log(`MultisigWallet: ${wallet.address}`)

  var newICO;

  newICO = await launcher.simpleICO(
    name,
    symbol,
    decimals,
    wallet.address, [podStartTime, podTokenSupply, podWeiLimit], [podTokenSupply / 2, podStartTime + 78000]
  )

  /**
   *     
   * newICO = await launcher.standardICO(
    rico.address,
    name,
    symbol,
    decimals,
    wallet.address,
    0, [tobStartTime, tobTokenSupply, tobWeiLimit, lastSupply], [podStartTime, podTokenSupply, podWeiLimit], [po, owner], [marketMaker]
  )
   */


  console.log(`tx:${newICO.tx}`)

}

function getAccount() {
  return new Promise((resolve, reject) => {
    web3.eth.getAccounts((err, accounts) => {
      const owner = accounts[0]
      resolve(owner)
    })
  })
}