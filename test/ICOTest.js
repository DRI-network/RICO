const RICO = artifacts.require("./RICO.sol");
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol")
const Launcher = artifacts.require("./Launcher.sol")
const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol")
const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

const ether = 10 ** 18;

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 3 / 100
const tobWeiLimit = 100 * 10 ** 18
const now = parseInt(new Date() / 1000)
const tobStartTime = now + 72000; //sec

const podTokenSupply = totalTokenSupply * 20 / 100
const podWeiLimit = 100 * 10 ** 18
const podStartTime = now + 172000; //sec


const firstSupply = totalTokenSupply * 30 / 100; // set first token supply to 30% of total supply.
const firstSupplyTime = 3456000; // set first mintable time to 40 days.（after 40 days elapsed)
const secondSupply = totalTokenSupply * 18 / 100; // set second token supply to 18% of total supply.
const secondSupplyTime = 10097000; // set second mintable time to 140 days.（after 140 days elapsed)
const mm_1 = "0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC"; // set first market maker's address 
const mm_1_amount = 100 * ether; // set ether amount to 100 ether for first market maker.
const mmCreateTime = 15552000 // set ether transferable time to 100 days.
const PoDstrat = 0; //set token strategy.

contract('RICO', function (accounts) {
  it("should be deployed and init token for ICOTest", async function () {

    projectOwner = accounts[0]
    tobAccount = accounts[1]

    rico = await RICO.new()
    lancher = await Launcher.new()

    const kickStart = await lancher.kickStart(
      rico.address,
      name,
      symbol,
      decimals,
      0, [tobTokenSupply, tobWeiLimit, tobStartTime, podTokenSupply, podWeiLimit, podStartTime]
    )
    console.log(kickStart)

    const status = await rico.tokens.call()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const test = await rico.transferOwnership(launcher.address).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'transferOwnership is executable')
    })
  })
  it("should be confirmed strategy for ICOTest", async function () {

    const confirmed = await rico.strategyConfirm()
    //const confirmed2 = await rico.strategyConfirm(1)

    const status = await rico.status.call()
    assert.strictEqual(status.toNumber(), 3, 'status is not 3')

    const init = await launcher.init(rico.address, totalTokenSupply, token.address, pods).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'changeOwner is executable')
    })
  })
  it("should be available TOB executes in this contract.", async function () {

    const status = await tob.status()
    const tobToken = await tob.proofOfDonationCapOfToken()
    const tobWei = await tob.proofOfDonationCapOfWei()
    const price = await tob.getTokenPrice()

    assert.strictEqual(tobToken.toNumber(), tobTokenSupply, 'tobTokenSupply is not correct')
    assert.strictEqual(tobWei.toNumber(), tobWeiLimit, 'tobWeiLimit is not correct')
    const buyer = await tob.buyer()
    assert.strictEqual(buyer, tobAccount, 'tobAccount is not correct')
    assert.strictEqual(price.toNumber() / 10 ** decimals, tobWeiLimit / tobTokenSupply, 'price is not correct')
  })
  it("contract should be able to donate to TOB from owner", async function () {

    const status = await tob.status()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const donate = await tob.donate({
      gasPrice: 40000000000,
      gas: 4642056,
      value: web3.toWei(100, 'ether'),
      from: tobAccount
    }).catch((err) => console.log(err))
  })

  it("contract should be completed tob processed", async function () {

    const status = await tob.status()
    assert.strictEqual(status.toNumber(), 3, 'status is not 3')
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const execTob = await rico.execTOB(now + 1)
    //console.log(execTob)
    // const balanceOfToken = await pod.getBalanceOfToken(projectOwner)
    const statusRico = await rico.status()
    assert.strictEqual(statusRico.toNumber(), 4, 'status is not 4')
  })
  it("contract should be able to donate to SimplePoD from user", async function () {

    const status = await pod.status()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const capOfWei = await pod.proofOfDonationCapOfWei()

    assert.strictEqual(capOfWei.toNumber(), podWeiLimit, 'podWeiLimit is not correct')

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [1],
      id: 0
    })

    const donate = await pod.donate({
      gasPrice: 40000000000,
      gas: 4642056,
      value: web3.toWei(99, 'ether'),
      from: accounts[2]
    }).catch((err) => console.log(err))

    const donate2 = await pod.donate({
      gasPrice: 40000000000,
      gas: 4642056,
      value: web3.toWei(10, 'ether'),
      from: accounts[3]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'transferOwnership is executable')
    })

    const donate3 = await pod.donate({
      gasPrice: 40000000000,
      gas: 4642056,
      value: web3.toWei(1, 'ether'),
      from: accounts[3]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'transferOwnership is executable')
    })

    const status2 = await pod.status()
    assert.strictEqual(status2.toNumber(), 3, 'status is not 3')
  })

  it("should be available to execute first Token Round for projecOwner", async function () {

    const startpod = await rico.startPoD(2)

    const status = await mint1.status()

    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const donate3 = await mint1.donate({
      gasPrice: 40000000000,
      gas: 4642056,
      value: web3.toWei(0, 'ether'),
      from: accounts[2]
    })

    const status2 = await mint1.status()
    assert.strictEqual(status2.toNumber(), 3, 'status is not 3')

  })
  it("should be available to mint first Token Round for projecOwner", async function () {

    const status = await mint1.status.call()
    assert.strictEqual(status.toNumber(), 3, 'status is not 3')
    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [72000],
      id: 0
    })
    const mint = await rico.mintToken(2, projectOwner)
    const balance = await token.balanceOf(projectOwner)
    const resetBalance = await mint1.getBalanceOfToken(projectOwner)

    assert.strictEqual(balance.toNumber(), firstSupply, 'firstSupply is not correct')
    assert.strictEqual(resetBalance.toNumber(), 0, 'resetBalance is not correct')

  })
})