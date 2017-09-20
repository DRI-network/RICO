var SampleICO = artifacts.require("./SampleICO.sol");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(SampleICO).then(async() => {
    const si = await SampleICO.deployed();

    console.log(si)

    const init = await si.init(accounts[1], {
      from: accounts[0]
    });
    const confirmed = await si.confirmed({
      from: accounts[1]
    })
  })
};