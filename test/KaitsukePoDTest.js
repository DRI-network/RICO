const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol");
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol")
const RICO = artifacts.require("./RICO.sol");

contract('KaitsukePoD', function (accounts) {
  const owner = accounts[0]

  const tobTokenSupply = 120 * 10 ** 18;
  const tobWeiLimit = 10 * 10 ** 18;
  const decimals = 18

  it("contract should be deployed and initializing token for SimplePoD", async function () {

    tob = await KaitsukePoD.new();
    multisig = await MultiSigWallet.new(accounts, 2)
    
    //deploy contracts and initialize ico.
    const setConfigPoD = await tob.setConfig(decimals, tobTokenSupply, tobWeiLimit, owner)

    const init = await tob.init()

    const status = await tob.status.call()

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")
  })

  it("contract should be started SimplePoD", async function () {

    const status = await tob.status.call()

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    assert.equal(status.toNumber(), 1, "Error: status is not Initialized")

    const start = await tob.start(now)

    const change = await tob.transferOwnership(multisig.address)

  })
  it("Check the process for donation should be done", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [0],
      id: 0
    })
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const price = await tob.getTokenPrice()
    // console.log(price.toNumber() / 10 ** decimals)
    assert.equal(price.toNumber() / 10 ** decimals, tobWeiLimit / tobTokenSupply, "Error: Token price is not tobTokenSupply / tobTokenSupply")

    const donate = await tob.donate({
      gasPrice: 50000000000,
      value: web3.toWei(8, 'ether')
    }).catch((err) => console.log(err))

    const status = await tob.status.call()
    const proofOfDonationCapOfWei = await tob.proofOfDonationCapOfWei.call()

    //console.log(donate.tx, status.toNumber(), proofOfDonationCapOfWei.toNumber())
    const balanceOfWei = await tob.getBalanceOfWei(owner)
    assert.equal(status.toNumber(), 2, "Error: status is not started")
    assert.equal(balanceOfWei.toNumber() / 10 ** 18, 8, "Error: donation has been failed")

  })

  it("Check the process for donation should be ended when cap reached", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const donate = await tob.donate({
      gasPrice: 50000000000,
      value: web3.toWei(100, 'ether'),
      from: owner
    }).catch((err) => {
      //console.log(err)
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const status = await tob.status.call()
    assert.equal(status.toNumber(), 2, "Error: status is not started")

    const donate2 = await tob.donate({
      gasPrice: 50000000000,
      value: web3.toWei(2, 'ether')
    })
    const status2 = await tob.status.call()
    assert.equal(status2.toNumber(), 3, "Error: status is not ended")
  })

  it("Check the tokenBalance for owner", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [2592000],
      id: 0
    })

    const donate = await tob.donate({
      gasPrice: 50000000000,
      value: web3.toWei(10, 'ether')
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'donate is executable yet.')
    })

    const balance = await tob.getBalanceOfToken(owner)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), tobTokenSupply, "Error: tobTokenSupply is not correct")
    
  })
  it("Check the tokenBalance for multisig", async function () {
    const balance = web3.eth.getBalance(multisig.address)
    //console.log(balance.toNumber())
    assert.equal(balance.toNumber(), tobWeiLimit, "Error: tobWeiLimit is not correct")
    
  })
    
})