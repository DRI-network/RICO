var SampleICO = artifacts.require("./SampleICO.sol");

contract('SampleICO', function(accounts) {
  it("should put 10000 MetaCoin in the first account", async function() {
    

    ico = await SampleICO.new();


    const init = await ico.init(accounts[1], {
      from: accounts[0]
    });
    console.log(init)
  })
})

    