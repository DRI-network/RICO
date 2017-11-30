const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

module.exports = async function (deployer, network, accounts) {

  const dap = await DutchAuctionPoD.deployed()

  const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp
  
  const start = await dap.start(now).catch((err) => {
    console.log(err)
  })
  console.log("transaction tx:", start.tx)
  
}  