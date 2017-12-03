const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

module.exports = async function (deployer, network, accounts) {

  const blocktime = await getBlock()
  const dap = await DutchAuctionPoD.deployed()

  const start = await dap.start(blocktime + 500).catch((err) => {
    console.log(err)
  })
  console.log("transaction tx:", start.tx)
}

function getBlock() {
  return new Promise((resolve, reject) => {
    getBlockNum().then((result) => {
      web3.eth.getBlock(result, (err, data) => {
        const timestamp = data.timestamp
        resolve(timestamp)
      })
    })
  })
}

function getBlockNum() {
  return new Promise((resolve, reject) => {
    web3.eth.getBlockNumber((err, result) => {
      resolve(result)
    })
  })
}