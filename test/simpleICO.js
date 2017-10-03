const SimpleICO = artifacts.require("./SimpleICO.sol");

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;
const now = Math.floor(new Date().getTime() / 1000);

const totalSupply = 400000; // 40万 Tokenを最大発行上限

const tobAmountToken = totalSupply * 0.02; // TOBの割合 2%
const tobAmountWei = 100; // TOBでのETH消費量 100ETH

const PoDCap = totalSupply * 0.3; // PoDでの発行30%
const PoDCapWei = 10000; // PoDでの寄付10000ETH

const firstSupply = totalSupply * 0.3; // 1回目の発行量 30%
const firstSupplyTime = now + 40; // 1回目の発行時間（生成時から40日後)

const secondSupply = totalSupply * 0.38; // 2回目の発行量　38%
const secondSupplyTime = now + 140; // 1回目の発行時間（生成時から40日後)

const mm_1 = '0x1d0dcc8d8bcafa8e8502beaeef6cbd49d3affcdc'; //マーケットメイカー1
const distributeWei_1 = 100; //マーケットメイカー1への寄付額
const mmDistributeTime_1 = now + 100; //マーケットメイカー1への寄付実行時間

contract('SimpleICO', function (accounts) {
  it("should be deployed and init token for SimpleICO", async function () {

    const owner = accounts[0]
    const projectOwner = accounts[1]


    ico = await SimpleICO.new();

    //deploy contracts and initialize ico.
    const init = await ico.init(projectOwner, {
      from: owner
    });

    const logs = init.logs
    // console.log(logs)

    //initialize Dutch Auction
    assert.strictEqual(logs[0].event, 'InitDutchAuction', 'assert error event[0] != InitDutchAuction')

    assert.strictEqual(logs[0].args.wallet, projectOwner, 'assert error projectOwner is not defined')

    assert.strictEqual(logs[0].args.tokenSupply.toNumber(), PoDCap * 10 ** 18, 'assert error DutchAuction token supply is not defined')

    assert.strictEqual(logs[0].args.donating.toNumber(), PoDCapWei * 10 ** 18, 'assert error DutchAuction ether supply is not defined')

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


  })
  it("should be confirmed strategy for SimpleICO", async function () {

    const owner = accounts[0]
    const projectOwner = accounts[1]

    const confirmed = await ico.strategyConfirm({
      from: projectOwner
    });

    // error 
    /*
    const init = await ico.init(projectOwner, {
      from: owner
    });
    */

    //console.log(confirmed)
  })
  it("should be confirmed strategy for SimpleICO", async function () {

    const projectOwner = accounts[1]


    const deposit = await ico.deposit({
      value: web3.toWei('0.01', 'ether'),
      from: projectOwner
    })

    console.log(deposit.logs[0].amount.toNumber())
  })

})