const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

module.exports = async function (callback) {
  
  const dap = await DutchAuctionPoD.deployed()

  const tokenDecimals = 18;

  const priceStart = 1 * 10 ** 18
  const priceConstant = 524880000
  const priceExponent = 3

  const setup = await dap.setConfig(tokenDecimals, priceStart, priceConstant, priceExponent).catch((err) => {
    console.log(err)
  })
  console.log("transaction tx:", setup.tx)
  
}