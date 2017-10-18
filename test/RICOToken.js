const RICOToken = artifacts.require("./RICOToken.sol");
const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

contract('RICOToken', function (accounts) {
  const owner = accounts[0]

  it("should be deployed and init token for RICOToken", async function () {

    token = await RICOToken.new();

    //deploy contracts and initialize ico.
    const init = await token.init(name, symbol, decimals, {
      from: owner
    });
  })
  it("should be mintable and mint now for projectOwner", async function () {
    const now = Math.floor(new Date().getTime() / 1000);

    const projectOwner = accounts[1]
    const init = await token.mintable(projectOwner, 1000 * 10 ** decimals, now, {
      from: owner
    });

    const mint = await token.mint(projectOwner)

    const balance = await token.balanceOf(projectOwner)

    assert.strictEqual(balance.toNumber(), 1000 * 10 ** decimals, 'balance of account2 == 1000 * 10 ** decimals')

  })
  it("should be disable mint now for projectOwner", async function () {
    const now = Math.floor(new Date().getTime() / 1000);
    const account2 = accounts[2]
    
    const projectOwner = accounts[1]
    const init = await token.mintable(account2, 1000 * 10 ** decimals, now+22222, {
      from: owner
    });

    const mint = await token.mint(account2)

    const balance = await token.balanceOf(account2)

    assert.strictEqual(balance.toNumber(), 0, 'assert error balance of account2 != 0')

  })
})