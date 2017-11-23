const DutchAuctionRegistry = artifacts.require("./DutchAuctionRegistry.sol");


contract('DutchAuctionRegistry', function (accounts) {
  const owner = accounts[0]
  const wallet = accounts[1]
  const caller = accounts[2]
  const tokenDecimals = 18;
  const supply = 40000000;

  it("should be deployed and init token for DutchAuctionRegistry", async function () {

    DAR = await DutchAuctionRegistry.new();

    //deploy contracts and initialize ico.
    const init = await DAR.init(wallet, caller, supply, tokenDecimals, {
      from: owner
    });

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [4000],
      id: 0
    })

    //assert.strictEqual(balance.toNumber(), 5000 * 10 ** decimals, 'balance of projectOwner != 5000 * 10 ** decimals')

  })

  it("should be initialized with parameters for DutchAuctionRegistry", async function () {

    const _priceConstant = 524880000
    const _priceExponent = 3
    const _priceStart = 2 * 10 ** 18

    const setup = await DAR.seup(wallet, caller, supply, tokenDecimals, {
      from: owner
    })
  })
  it("should be started DutchAuction", async function () {
    const start = await DAR.startAuction()
  })
      
})