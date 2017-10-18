var SimpleICO = artifacts.require("./SimpleICO.sol");
var RICO = artifacts.require("./RICO.sol");

module.exports = function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests
  
  deployer.deploy(SimpleICO).then(async() => {
    const si = await SimpleICO.deployed();
   // const init = await si.init(accounts[1], {
     // from: accounts[0]
    //});
    //const ss = await si.setup()
  })
};