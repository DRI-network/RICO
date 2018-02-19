const RICOStandardPoD = artifacts.require("./PoDs/RICOStandardPoD.sol");

contract('RICOStandardPoD', function (accounts) {

  const decimals = 18;
  const TOBTokenSupply = 120 * 10 ** 18;
  const TOBPrice = 10 * 10 ** 18;
  const TOBFunder = accounts[0];
  const TOBSecondOwner = accounts[1];
  const TOBSecondOwnerAllocation = TOBTokenSupply / 2;
  const marketMakers = [
    accounts[2],
    accounts[3]
  ]

  it("contract should be deployed and initializing token for PublicSalePoD", async function () {

    bid = await RICOStandardPoD.new()

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp
    const TOBStartTime = now + 500;

    //deploy contracts and initialize ICO.
    const init = await bid.init(decimals, TOBStartTime, TOBTokenSupply, TOBPrice, [TOBFunder, TOBSecondOwner], marketMakers, TOBSecondOwnerAllocation)

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
    assert.equal(price.toNumber() / 10 ** decimals, TOBPrice / TOBTokenSupply, "Error: Token price is not TOBPrice / TOBTokenSupply")

    const donate = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(8, 'ether'),
      from: TOBFunder
    }).catch((err) => {
      //console.log(err)
    })

    const status = await bid.status.call()

    //console.log(donate.tx, status.toNumber(), proofOfDonationCapOfWei.toNumber())
    const balanceOfWei = await bid.getBalanceOfWei(TOBFunder)

    assert.equal(balanceOfWei.toNumber() / 10 ** 18, 8, "Error: donation has been failed")
    assert.equal(status.toNumber(), 1, "Error: status is not started")

  })

  it("Check the process for donation should be ended when cap reached", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const donate = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(100, 'ether'),
      from: TOBSecondOwner
    }).catch((err) => {
      //console.log(err)
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const status = await bid.status.call()
    assert.equal(status.toNumber(), 1, "Error: status is not started")

    const donate2 = await bid.donate({
      gasPrice: 50000000000,
      value: web3.toWei(2, 'ether'),
      from: TOBFunder
    })
    const status2 = await bid.status.call()
    assert.equal(status2.toNumber(), 2, "Error: status is not ended")
  })

  it("Check the tokenBalance for TOBFunder", async function () {

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

    const balance = await bid.getBalanceOfToken(TOBFunder)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), TOBTokenSupply, "Error: TOBTokenSupply is not correct")

  })
  it("Check the tokenBalance for TOBSecondOwner", async function () {

    const balance = await bid.getBalanceOfToken(TOBSecondOwner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), TOBSecondOwnerAllocation, "Error: TOBTokenSupply is not correct")

  })

})