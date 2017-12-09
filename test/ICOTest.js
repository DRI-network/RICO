
const LauncherSample = artifacts.require("./LauncherSample.sol");
const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");
const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol")
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol")
const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")

const ether = 10 ** 18;

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 3 / 100
const tobWeiLimit = 100 * 10 ** 18
const podTokenSupply = totalTokenSupply * 20 / 100
const podWeiLimit = 1000 * 10 ** 18

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
    token = await RICOToken.new()
    launcher = await LauncherSample.new()
    tob = await KaitsukePoD.new()
    pod = await SimplePoD.new()
    multisig = await MultiSigWallet.new(accounts, 2)

    pods = [
      tob.address,
      pod.address,
    ]

    const setConfigToB = await tob.setConfig(decimals, tobTokenSupply, tobWeiLimit, tobAccount)
    const changeOwnerToB = await tob.transferOwnership(rico.address)

    const setConfigPoD = await pod.setConfig(decimals, podTokenSupply, podWeiLimit)
    const changeOwnerPoD = await pod.transferOwnership(rico.address)


    // changing owner to owner to rico.
    const changeOwnerToken = await token.transferOwnership(rico.address)
    const changeOwnerRICO = await rico.transferOwnership(launcher.address)

    //initializing launcher.
    const init = await launcher.init(rico.address, totalTokenSupply, token.address, pods)

    //setup launcher
    const setup = await launcher.setup(accounts[0]);

    const status = await rico.status.call()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const test = await rico.transferOwnership(launcher.address).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'transferOwnership is executable')
    })
  })
  it("should be confirmed strategy for ICOTest", async function () {

    const projectOwner = accounts[0]

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
  it("contract should be able to donate to project", async function () {
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

    const execTob = await rico.execTOB(now+2)
    console.log(execTob)
    // const balanceOfToken = await pod.getBalanceOfToken(projectOwner)
    const statusRico = await rico.status()
    assert.strictEqual(statusRico.toNumber(), 4, 'status is not 4')
  })
  it("should be available to execute first Token Round for projecOwner", async function () {
    const nows = web3.eth.getBlock(web3.eth.blockNumber).timestamp
    const projectOwner = accounts[0]

    const tokenmint = await rico.execTokenRound(0, {
      from: projectOwner
    })
    const tokenmint2 = await rico.execTokenRound(1, {
      from: projectOwner
    })
    const balanceToken = await token.balanceOf(projectOwner)
    assert.equal(balanceToken.toNumber(), web3.toWei('0', 'ether'), 'balanceToken is not equal to 0 ')

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [firstSupplyTime],
      id: 0
    })

    const mint = await rico.execTokenRound(0, {
      from: projectOwner
    })

    const balanceToken2 = await token.balanceOf(projectOwner)
    assert.equal(balanceToken2.toNumber(), firstSupply, 'balanceToken2 is not equal to firstSupply + 200 ')

  })
  it("should be available to execute second Token Round for projecOwner", async function () {
    const nows = web3.eth.getBlock(web3.eth.blockNumber).timestamp
    const projectOwner = accounts[0]

    const tokenmint = await rico.execTokenRound(0, {
      from: projectOwner
    })
    const tokenmint2 = await rico.execTokenRound(1, {
      from: projectOwner
    })

    const tokenmint3 = await rico.execTokenRound(2, {
      from: projectOwner
    })

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [secondSupplyTime],
      id: 0
    })

    const mint1 = await rico.execTokenRound(0, {
      from: projectOwner
    })
    const mint2 = await rico.execTokenRound(1, {
      from: projectOwner
    })
    const mint3 = await rico.execTokenRound(2, {
      from: projectOwner
    })


    const balanceToken2 = await token.balanceOf(projectOwner)
    assert.equal(balanceToken2.toNumber(), secondSupply + firstSupply, 'balanceToken2 is not equal to secondSupply + firstSupply ')

  })
  it("should be available to all minting token for projecOwner", async function () {
    const nows = web3.eth.getBlock(web3.eth.blockNumber).timestamp
    const projectOwner = accounts[0]

    const tokenmint = await rico.execTokenRound(0, {
      from: projectOwner
    })
    const tokenmint2 = await rico.execTokenRound(1, {
      from: projectOwner
    })

    const tokenmint3 = await rico.execTokenRound(2, {
      from: projectOwner
    })

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [mmCreateTime],
      id: 0
    })

    const mint1 = await rico.execTokenRound(0, {
      from: projectOwner
    })
    const mint2 = await rico.execTokenRound(1, {
      from: projectOwner
    })
    const mint3 = await rico.execTokenRound(2, {
      from: projectOwner
    })
    const mint = await rico.mintToken(projectOwner, {
      from: projectOwner
    })

    const balanceToken = await token.balanceOf(projectOwner)
    const sum = secondSupply + firstSupply + Number(web3.toWei('200', 'ether'))
    //console.log(balanceToken.toNumber())
    assert.equal(balanceToken.toNumber(), (tobAmountToken / 1000 + sum / 1000) * 1000, 'balanceToken2 is not equal to 8200 ')

  })
})