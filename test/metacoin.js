var SampleICO = artifacts.require("./SampleICO.sol");

contract('MetaCoin', function(accounts) {
  it("should put 10000 MetaCoin in the first account", async function() {
    

    ico = await SampleICO.new();

    console.log(ico)
  })
})

    