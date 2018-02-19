const TokenMintPoD = artifacts.require("./PoDs/TokenMintPoD.sol");

contract('TokenMintPoD', function (accounts) {
  const owner = accounts[0]

  const decimals = 18;
  const separateAllocationTokenAmount = 120 * 10 ** 18;

  it("contract should be deployed and initializing token for PublicSalePoD", async function () {

    pod = await TokenMintPoD.new();
    //deploy contracts and initialize ico.
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp
    const separateAllocationLockTime = now + 72000;

    const setConfigMint1 = await pod.init(owner, separateAllocationTokenAmount, separateAllocationLockTime)
    const status = await pod.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("Check the donation process should be done", async function () {

    // var checkNow = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    // console.log('checkNow 1 → ', checkNow);

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [72030],
      id: 0
    });

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

    // checkNow = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    // console.log('checkNow 2 → ', checkNow);

    const status = await pod.status.call()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const balance = await pod.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), separateAllocationTokenAmount, "Error: separateAllocationTokenAmount is not correct")

  })
})