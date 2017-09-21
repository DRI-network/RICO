var SampleICO = artifacts.require("./SampleICO.sol");

contract('SampleICO', function (accounts) {
  it("should put 10000 MetaCoin in the first account", async function () {
    const owner = accounts[0]
    const projectOwner = accounts[1]

    ico = await SampleICO.new();
    const init = await ico.init(projectOwner, {
      from: owner
    });

    console.log(init)

    const confirmed = await ico.strategyConfirm({
      from: projectOwner
    });

    console.log(confirmed)
  })
})