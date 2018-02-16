const RICOStandardPoD = artifacts.require("./PoDs/RICOStandardPoD.sol");

contract('RICOStandardPoD', function (accounts) {
  const owner = accounts[0]

  const bidTokenSupply = 120 * 10 ** 18;
  const bidWeiLimit = 10 * 10 ** 18;
  const decimals = 18
  const buyer = accounts[1]
  const mm = [
    accounts[2],
    accounts[3]
  ]

  it("contract should be deployed and initializing token for SimplePoD", async function () {


    bid = await RICOStandardPoD.new()

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    //deploy contracts and initialize ICO.
    const init = await bid.init(decimals, now + 500, bidTokenSupply, bidWeiLimit, [buyer, owner], mm, bidTokenSupply / 2)

    const status = await bid.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("Check the process for donation should be done", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [530],
      id: 0
    })
    const startTime = await bid.getStartTime()
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    //console.log(startTime.toNumber(), now)
    const price = await bid.getTokenPrice()
    // console.log(price.toNumber() / 10 ** decimals)
    assert.equal(price.toNumber() / 10 ** decimals, bidWeiLimit / bidTokenSupply, "Error: Token price is not bidTokenSupply / bidTokenSupply")

    const donate = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(8, 'ether'),
      from: buyer
    }).catch((err) => {
      //console.log(err)
    })

    const status = await bid.status.call()

    //console.log(donate.tx, status.toNumber(), proofOfDonationCapOfWei.toNumber())
    const balanceOfWei = await bid.getBalanceOfWei(buyer)

    assert.equal(balanceOfWei.toNumber() / 10 ** 18, 8, "Error: donation has been failed")
    assert.equal(status.toNumber(), 1, "Error: status is not started")

  })

  it("Check the process for donation should be ended when cap reached", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const donate = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(100, 'ether'),
      from: owner
    }).catch((err) => {
      //console.log(err)
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const status = await bid.status.call()
    assert.equal(status.toNumber(), 1, "Error: status is not started")

    const donate2 = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(2, 'ether'),
      from: buyer
    })
    const status2 = await bid.status.call()
    assert.equal(status2.toNumber(), 2, "Error: status is not ended")
  })

  it("Check the tokenBalance for buyer", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [15650000],
      id: 0
    })

    const donate = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(10, 'ether')
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const balance = await bid.getBalanceOfToken(buyer)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), bidTokenSupply, "Error: bidTokenSupply is not correct")

  })
  it("Check the tokenBalance for owner", async function () {

    const balance = await bid.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), bidTokenSupply / 2, "Error: bidTokenSupply is not correct")

  })

})