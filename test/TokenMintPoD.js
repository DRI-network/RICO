const TokenMintPoD = artifacts.require("./PoDs/TokenMintPoD.sol");

contract('TokenMintPoD', function (accounts) {
  const owner = accounts[0]

  const podTokenSupply = 120 * 10 ** 18;
  const decimals = 18

  it("contract should be deployed and initializing token for SimplePoD", async function () {

    pod = await TokenMintPoD.new();
    //deploy contracts and initialize ico.
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const setConfigMint1 = await pod.setConfig(owner, 72000, podTokenSupply)

    const init = await pod.init()

    const status = await pod.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("contract should be started SimplePoD", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const start = await pod.start(now)

    const status = await pod.status.call()

    assert.equal(status.toNumber(), 2, "Error: status is not Initialized")


  })
  it("Check the process for donation should be done", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [72000],
      id: 0
    })

    const donate = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(8, 'ether')
    })
    //console.log(donate)

    const status = await pod.status.call()

    assert.equal(status.toNumber(), 3, "Error: status is not Initialized")

  })

  it("Check the tokenBalance for owner", async function () {

    const status = await pod.status.call()
    assert.strictEqual(status.toNumber(), 3, 'status is not 3')

    const balance = await pod.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), podTokenSupply, "Error: podTokenSupply is not correct")

  })
})