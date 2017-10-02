const SimpleICO = artifacts.require("./SimpleICO.sol");

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;
const now = Math.floor(new Date().getTime() / 1000)
const totalSupply = 400000 * 10 ** 18; // 40万 Tokenを最大発行上限
const tobAmountToken = totalSupply * 0.01; // TOBの割合 1%
const tobAmountWei = 100 * 10 ** 18; // TOBでのETH消費量 100ETH
const PoDCap = totalSupply * 20 / 100; // PoDでの発行20%
const poDCapWei = 10000 * 10 ** 18; // PoDでの寄付10000ETH
const firstSupply = totalSupply * 10 / 100; // 1回目の発行量 10%
const firstSupplyTime = now + 40; // 1回目の発行時間（生成時から40日後)
const secondSupply = totalSupply * 69 / 100; // 2回目の発行量　69%
const secondSupplyTime = now + 140; // 1回目の発行時間（生成時から40日後)
const mm_1 = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; //マーケットメイカー
const mm_1_amount = 100; //マーケットメイカーへの寄付額
const mmCreateTime = now + 100; //マーケットメイカーの寄付実行時間

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
    console.log(logs)
    
    //initialize Dutch Auction
    assert.strictEqual(logs[0].event, 'InitDutchAuction', 'assert error event[0] != InitDutchAuction')

    assert.strictEqual(logs[0].args.wallet, projectOwner, 'assert error projectOwner is not match')

    assert.strictEqual(logs[0].args.tokenSupply.toNumber(), PoDCap, 'assert error DutchAuction token supply is not match')

    assert.strictEqual(logs[0].args.donating.toNumber(), poDCapWei, 'assert error DutchAuction ether supply is not match')
    
    assert.strictEqual(logs[1].event, 'InitStructure', 'asset error event[1] != InitStructure')

    assert.strictEqual(logs[1].args.totalSupply.toNumber(), totalSupply, 'assert error totalsupply is not match')

    assert.strictEqual(logs[1].args.po, projectOwner, 'assert error projectOwner is not match')

    assert.strictEqual(logs[1].args.tobAmountWei.toNumber(), tobAmountWei, 'assert error tobAmountWei is not match')

    assert.strictEqual(logs[1].args.tobAmountToken.toNumber(), tobAmountToken, 'assert error tobAmountToken is not match')


    assert.strictEqual(logs[2].event, 'InitTokenData', 'assert error even[0] != initTokenData')

    assert.strictEqual(logs[2].args.name.toString(), name, 'assert error name is not match')
    


    const confirmed = await ico.strategyConfirm({
      from: projectOwner
    });

    console.log(confirmed)
  })
})