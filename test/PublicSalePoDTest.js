const PublicSalePoD = artifacts.require("./PoDs/PublicSalePoD.sol");

contract('PublicSalePoD', function (accounts) {
  const owner = accounts[0];

  const decimals = 18;
  const publicSaleTokenSupply = 120 * 10 ** 18;
  const publicSaleWeiCap = 10 * 10 ** 18;

  it("contract should be deployed and initializing token for PublicSalePoD", async function () {

    pod = await PublicSalePoD.new();

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    const publicSaleStartTime = now + 200;

    //deploy contracts and initialize ico.
    const init = await pod.init(accounts[0], decimals, publicSaleStartTime, publicSaleTokenSupply, publicSaleWeiCap)

    const status = await pod.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("Check the process for donation should be done", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [200],
      id: 0
    })
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const price = await pod.getTokenPrice()

    assert.equal(price.toNumber() / 10 ** decimals, publicSaleWeiCap / publicSaleTokenSupply, "Error: Token price is not publicSaleTokenSupply / publicSaleWeiCap")

    const donate = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(8, 'ether')
    })

    const status = await pod.status.call()
    const proofOfDonationCapOfWei = await pod.getCapOfWei()

    //console.log(donate.tx, status.toNumber(), proofOfDonationCapOfWei.toNumber())
    const balanceOfWei = await pod.getBalanceOfWei(owner)
    assert.equal(status.toNumber(), 1, "Error: status is not started")
    assert.equal(balanceOfWei.toNumber() / 10 ** 18, 8, "Error: donation has been failed")

  })

  it("Check the process for donation should be ended when cap reached", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const donate = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(10, 'ether')
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const status = await pod.status.call()
    assert.equal(status.toNumber(), 1, "Error: status is not started")

    const donate2 = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(2, 'ether')
    })
    const status2 = await pod.status.call()
    assert.equal(status2.toNumber(), 2, "Error: status is not ended")
  })

  it("Check the tokenBalance for owner", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [400],
      id: 0
    })

    const donate = await pod.donate({
      gasPrice: 50000000000,
      value: web3.toWei(10, 'ether')
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const balance = await pod.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), publicSaleTokenSupply, "Error: publicSaleTokenSupply is not correct")

  })
})