const RICOToken = artifacts.require("./RICOToken.sol");
const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

contract('RICOToken', function (accounts) {
  const owner = accounts[0]
  const projectOwner = accounts[1]

  it("should be deployed and init token for RICOToken", async function () {

    token = await RICOToken.new({
      from: owner
    });
    //deploy contracts and initialize ico.
    const init = await token.init(name, symbol, decimals, {
      from: owner
    });
  })
  it("should be mintable and mint now for projectOwner", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const mintable = await token.mintable(projectOwner, 1000 * 10 ** decimals, now + 3000, {
      from: owner
    });

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [3000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 1000 * 10 ** decimals, 'balance of projectOwner != 1000 * 10 ** decimals')

  })
  it("should be disable mint now for projectOwner", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const projectOwner = accounts[1]
    const mintable = await token.mintable(projectOwner, 1000 * 10 ** decimals, now + 22222, {
      from: owner
    });

    const mint = await token.mint(projectOwner, {
      from: owner
    }).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'token is not generate')
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 1000 * 10 ** decimals, 'assert error balance of projectOwner != 1000 * 10 ** decimals')

  })
  it("should be mintable additional token and mint now for projectOwner", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const mintable = await token.mintable(projectOwner, 1000 * 10 ** decimals, now + 3000, {
      from: owner
    });

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [4000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 2000 * 10 ** decimals, 'balance of projectOwner != 2000 * 10 ** decimals')

  })
  it("should be more mintable additional token and mint now for projectOwner", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const mintable1 = await token.mintable(projectOwner, 1000 * 10 ** decimals, now + 3000, {
      from: owner
    });

    const mintable2 = await token.mintable(projectOwner, 2000 * 10 ** decimals, now + 8000, {
      from: owner
    });

    const mintable3 = await token.mintable(projectOwner, 3000 * 10 ** decimals, now + 9000, {
      from: owner
    });

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [4000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 3000 * 10 ** decimals, 'balance of projectOwner != 3000 * 10 ** decimals')
  })
  it("should be more mintable additional token and mint with elapsed time now for projectOwner", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [4000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 5000 * 10 ** decimals, 'balance of projectOwner != 5000 * 10 ** decimals')
  })

  it("should be more mintable additional token and mint with elapsed time of first 1000 + 5000 + 3000 stack for projectOwner", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [18000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 9000 * 10 ** decimals, 'balance of projectOwner != 9000 * 10 ** decimals')
  })

  it("should be same balance of projectOwner with elapsed time", async function () {

    const setTime = await web3.currentProvider.send({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [18000],
      id: 0
    })

    const mint = await token.mint(projectOwner, {
      from: owner
    })

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 9000 * 10 ** decimals, 'balance of projectOwner != 9000 * 10 ** decimals')
  })

  it("should be changed owner by oldOwner", async function () {

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const newOwner = projectOwner

    const changed = await token.transferOwnership(newOwner, {
      from: owner
    })

    const mintable = await token.mintable(projectOwner, 3000 * 10 ** decimals, now, {
      from: owner
    }).catch(err => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'token is not generate')
    })
  })
})