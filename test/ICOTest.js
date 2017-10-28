const Launcher = artifacts.require("./Launcher.sol");
const RICO = artifacts.require("./RICO.sol");

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
const firstSupplyTime = now + 4000; // set first mintable time to 40 days.（after 40 days elapsed)
const secondSupply = totalSupply * 18 / 100; // set second token supply to 18% of total supply.
const secondSupplyTime = now + 14000; // set second mintable time to 140 days.（after 140 days elapsed)
const mm_1 = "0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC"; // set first market maker's address 
const mm_1_amount = 100 * ether; // set ether amount to 100 ether for first market maker.
const mmCreateTime = now + 400000; // set ether transferable time to 100 days.
const PoDstrat = 0; //set token strategy.

var rico;
var launcher;

contract('ICOTest', function (accounts) {
  it("should be deployed and init token for ICOTest", async function () {

    const projectOwner = accounts[0]

    rico = await RICO.new();

    launcher = await Launcher.new();

    const changeOwner = await rico.changeOwner(launcher.address, {
      from: projectOwner
    })

    const init = await launcher.init(rico.address, {
      from: projectOwner
    });

    const setup = await launcher.setup({
      from: projectOwner
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
      value: web3.toWei('0.01', 'ether'),
      from: projectOwner
    })

    // console.log(deposit.logs[0].amount)
  })

})

/*
  assert.strictEqual(logs[0].event, 'InitDutchAuction', 'assert error event[0] != InitDutchAuction')
  
  if (PoDstrat == 1) {
    assert.strictEqual(logs[0].event, 'InitDutchAuction', 'assert error event[0] != InitDutchAuction')

    assert.strictEqual(logs[0].args.wallet, projectOwner, 'assert error projectOwner is not defined')

    assert.strictEqual(logs[0].args.tokenSupply.toNumber(), PoDCap * 10 ** 18, 'assert error DutchAuction token supply is not defined')

    assert.strictEqual(logs[0].args.donating.toNumber(), PoDCapWei * 10 ** 18, 'assert error DutchAuction ether supply is not defined')

  }
  assert.strictEqual(logs[1].event, 'InitStructure', 'asset error event[1] != InitStructure')

  assert.strictEqual(logs[1].args.totalSupply.toNumber(), totalSupply * 10 ** 18, 'assert error totalsupply is not defined')

  assert.strictEqual(logs[1].args.po, projectOwner, 'assert error projectOwner is not defined')

  assert.strictEqual(logs[1].args.tobAmountWei.toNumber(), tobAmountWei * 10 ** 18, 'assert error tobAmountWei is not defined')

  assert.strictEqual(logs[1].args.tobAmountToken.toNumber(), tobAmountToken * 10 ** 18, 'assert error tobAmountToken is not defined')

  //initialize Token Data
  assert.strictEqual(logs[2].event, 'InitTokenData', 'assert error even[0] != initTokenData')

  assert.strictEqual(logs[2].args.name, name, 'assert error name is not defined')

  assert.strictEqual(logs[2].args.symbol, symbol, 'assert error symbol is not defined')

  assert.strictEqual(logs[2].args.decimals.toNumber(), decimals, 'assert error decimals is not defined')

  //add Token Supply Round as firstSupply

  assert.strictEqual(logs[3].event, 'AddTokenRound', 'assert error even[3] != AddTokenRound')

  assert.strictEqual(logs[3].args.supply.toNumber(), firstSupply * 10 ** 18, 'assert error firstSupply is not defined')

  // assert.strictEqual(logs[3].args.execTime.toNumber(), firstSupplyTime, 'assert error firstSupplyTime is not defined')

  assert.strictEqual(logs[3].args.to, projectOwner, 'assert error token creation address is not defined projectOwner')

  //add Token Supply Round as secondSupply

  assert.strictEqual(logs[4].event, 'AddTokenRound', 'assert error even[3] != AddTokenRound')

  assert.strictEqual(logs[4].args.supply.toNumber(), secondSupply * 10 ** 18, 'assert error secondSupply is not defined')

  // assert.strictEqual(logs[3].args.execTime.toNumber(), secondSupplyTime, 'assert error secondSupplyTime is not defined')

  assert.strictEqual(logs[4].args.to, projectOwner, 'assert error token creation address is not defined projectOwner')


  //add Ether Distribute for MarketMaker when mmDistributeTime_1 has passed

  assert.strictEqual(logs[5].event, 'AddMarketMaker', 'assert error even[4] != AddMarketMaker')

  assert.strictEqual(logs[5].args.distributeWei.toNumber(), distributeWei_1 * 10 ** 18, 'assert error distributeWei_1 is not defined ')

  //assert.strictEqual(logs[4].args.execTime.toNumber(), mmDistributeTime_1, 'assert error mmDistributeTime_1 is not defined')

  assert.strictEqual(logs[5].args.maker, mm_1, 'assert error mm_1 is not defined ')

  assert.strictEqual(web3.toAscii(logs[5].args.metaData).replace(/\0/g, ''), "YUSAKUSENGA", 'assert error metaData is not defined')
  */