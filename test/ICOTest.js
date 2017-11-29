const Launcher = artifacts.require("./LauncherSample.sol");
const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");
const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")

const now = Math.floor(new Date().getTime() / 1000);

const name = "Responsible ICO Token";

const ether = 10 ** 18;

const symbol = "RIT";
const decimals = 18;
const totalSupply = 400000 * ether; // set maximum supply to 400,000.
const tobAmountToken = totalSupply * 2 / 100; // set token TOB ratio to 2% of total supply.
const tobAmountWei = 100 * ether; // set ether TOB spent to 100 ether.
const PoDCapToken = totalSupply * 50 / 100; // set proof of donation token cap to 50% of Total Supply.
const PoDCapWei = 10000 * ether; // set proof of donation ether cap to 10,000 ether.
const firstSupply = totalSupply * 30 / 100; // set first token supply to 30% of total supply.
const firstSupplyTime = 3456000; // set first mintable time to 40 days.（after 40 days elapsed)
const secondSupply = totalSupply * 18 / 100; // set second token supply to 18% of total supply.
const secondSupplyTime = 10097000; // set second mintable time to 140 days.（after 140 days elapsed)
const mm_1 = "0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC"; // set first market maker's address 
const mm_1_amount = 100 * ether; // set ether amount to 100 ether for first market maker.
const mmCreateTime = 15552000 // set ether transferable time to 100 days.
const PoDstrat = 0; //set token strategy.

contract('RICO', function (accounts) {
  it("should be deployed and init token for ICOTest", async function () {

    const projectOwner = accounts[0]

    const rico = await RICO.deployed()
    const token = await RICOToken.deployed()
    const launcher = await LauncherSample.deployed()
    const simplePoD = await SimplePoD.deployed()


    // changing owner to owner -> launcher.
    const changeOwner = await rico.transferOwnership(launcher.address, {
      from: accounts[0]
    })

    // changing owner to owner to rico.
    const changeOwner2 = await token.transferOwnership(rico.address, {
      from: accounts[0]
    })

    const changeOwner3 = await simplePoD.transferOwnership(rico.address, {
      from: accounts[0]
    })

    //initializing launcher.
    const init = await launcher.init(rico.address, token.address, simplePoD.address, {
      from: accounts[0]
    });

    //setup launcher
    const setup = await launcher.setup({
      from: accounts[0]
    });



    const status = await rico.status.call()
    assert.strictEqual(status.toNumber(), 1, 'status is not 1')

    const test = await rico.changeOwner(launcher.address, {
      from: projectOwner
    }).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'changeOwner is executable')
    })
  })
  it("should be confirmed strategy for ICOTest", async function () {

    const projectOwner = accounts[0]

    const confirmed = await rico.strategyConfirm({
      from: projectOwner
    });

    const status = await rico.status.call()
    assert.strictEqual(status.toNumber(), 2, 'status is not 2')

    const reinit = await launcher.init(rico.address, {
      from: projectOwner
    }).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'changeOwner is executable')
    })

    //console.log(confirmed)
  })
  it("should be available deposit ether to this contract", async function () {

    const projectOwner = accounts[0]

    const deposit = await rico.deposit({
      value: web3.toWei('120', 'ether'),
      from: projectOwner
    })

    const balance = await rico.getBalanceOfWei(projectOwner)
    assert.equal(balance.toNumber(), web3.toWei('120', 'ether'), 'balance is not equal to 120 ether')
  })
  it("should be available withdrawal ether from this contract", async function () {

    const projectOwner = accounts[0]

    const withdraw = await rico.withdraw(web3.toWei('10', 'ether'), {
      from: projectOwner
    })

    const balance = await rico.getBalanceOfWei(projectOwner)
    assert.equal(balance.toNumber(), web3.toWei('110', 'ether'), 'balance is not equal to 110 ether')
  })
  it("should be available TOB executes in this contract and should be able to donate to project", async function () {

    const projectOwner = accounts[0]
    const nows = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const podStartTime = nows + 14
    // Error
    const execTOB = await rico.execTOB(podStartTime, {
      from: projectOwner
    })

    const balance = await rico.getBalanceOfWei(projectOwner)
    assert.equal(balance.toNumber(), web3.toWei('0', 'ether'), 'balance is not equal to 0 ether')

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [1600],
      id: 0
    })

    const status = await rico.status.call()
    assert.strictEqual(status.toNumber(), 3, 'status is not 3')

    // Error
    /*
    const donate = await web3.eth.sendTransaction({
      value: web3.toWei('10', 'ether'),
      to: rico.address,
      from: projectOwner,
      gas: 2000000
    })
    */

    const donate = await rico.donate({
      value: web3.toWei('10', 'ether'),
      from: projectOwner,
      gas: 2000000
    })

    const balances = await rico.getBalanceOfWei(projectOwner)
    assert.equal(balances.toNumber(), web3.toWei('0', 'ether'), 'balance is not equal to 0 ether')
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
    assert.equal(balanceToken2.toNumber(), firstSupply + Number(web3.toWei('200', 'ether')), 'balanceToken2 is not equal to firstSupply + 200 ')

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
    assert.equal(balanceToken2.toNumber(), secondSupply + firstSupply + Number(web3.toWei('200', 'ether')), 'balanceToken2 is not equal to secondSupply + firstSupply + 200 ')

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
    const mint = await rico.mintToken({
      from: projectOwner
    })

    const balanceToken = await token.balanceOf(projectOwner)
    const sum = secondSupply + firstSupply + Number(web3.toWei('200', 'ether'))
    //console.log(balanceToken.toNumber())
    assert.equal(balanceToken.toNumber(), (tobAmountToken / 1000 + sum / 1000) * 1000, 'balanceToken2 is not equal to 8200 ')

  })
})