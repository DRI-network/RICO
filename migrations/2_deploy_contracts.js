var SampleICO = artifacts.require("./SampleICO.sol");

module.exports = function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests
  
  deployer.deploy(SampleICO).then(async() => {
    const si = await SampleICO.deployed();


    const init = await si.init(accounts[1], {
      from: accounts[0]
    });

    console.log(init.logs[1].args)
    console.log(init.logs[2].args)
    
    
    const confirmed = await si.structureConfirm({
      from: accounts[1]
    })
    
  })
};