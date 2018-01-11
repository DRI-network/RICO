const TokenMintPoD = artifacts.require("./PoDs/TokenMintPoD.sol");

contract('TokenMintPoD', function (accounts) {
  const owner = accounts[0]

  const podTokenSupply = 120 * 10 ** 18;
  const decimals = 18

  it("contract should be deployed and initializing token for SimplePoD", async function () {

    pod = await TokenMintPoD.new();
    //deploy contracts and initialize ico.
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const setConfigMint1 = await pod.init(owner, podTokenSupply, now + 72000)


    const status = await pod.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("Check the donation process should be done", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",

      method: "evm_increaseTime",
      params: [72000],
      id: 0
    })

    const donate = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(10, 'ether')
    }).catch((err) => {
      //console.log(err)
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const status = await pod.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")

  })

  it("Check the finalize process done", async function () {
    const finalize = await pod.finalize()
    const status = await pod.status.call()

    assert.equal(status.toNumber(), 2, "Error: status is not ended")
  })
  it("Check the tokenBalance for owner", async function () {

    const status = await pod.status.call()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const balance = await pod.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), podTokenSupply, "Error: podTokenSupply is not correct")

  })
})