const DutchAuctionPoD = artifacts.require("DutchAuctionPoD.sol")

module.exports = async function (callback) {

  const dap = await DutchAuctionPoD.deployed()

  const podCapOfToken = 120 * 10 ** 18;
  const podCapofWei = 100000;

  const owner = web3.eth.accounts[0]

  const init = await dap.init(owner, podCapOfToken, podCapofWei).catch((err) => {
    console.log("Error transaction has been rejected")
  })

  console.log("transaction tx:", init.tx)
  
}