const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

module.exports = async function (deployer, network, accounts) {

  const dap = await DutchAuctionPoD.deployed()

  const start = await dap.donate({
    gasPrice: 50000000000,
    value: web3.toWei(0.1, 'ether')
  }).catch((err) => {
    console.log(err)
  })
  console.log("transaction tx:", start.tx)

}