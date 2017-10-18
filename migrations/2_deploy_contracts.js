var Launcher = artifacts.require("./Launcher.sol");
var RICO = artifacts.require("./RICO.sol");

module.exports = async function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests

  const rico = await deployer.deploy(RICO)
  const launcher = await deployer.deploy(Launcher)

  const rico_i = await RICO.deployed();
  const launcher_i = await launcher.deployed();
  console.log(rico_i)

  const init = await launcher_i.init(rico_i.address, {
    from: accounts[0]
  });
  //const ss = await si.setup()
  process.on('unhandledRejection', console.dir);
  
};