const DutchAuctionPoD = artifacts.require("DutchAuctionPoD.sol")

module.exports = async function (callback) {
  const dap = await DutchAuctionPoD.deployed()


  const podCapOfToken = 120 * 10 ** 18;
  const podCapofWei = 100000;

  const owner = await getAccount()

  const init = await dap.init(owner, podCapOfToken, podCapofWei).catch((err) => {
    console.log("Error transaction has been rejected")
  })
  console.log("transaction tx:", init.tx)
}

function getAccount() {
  return new Promise((resolve, reject) => {
    web3.eth.getAccounts((err, accounts) => {
      const owner = accounts[0]
      resolve(owner)
    })
  })
}