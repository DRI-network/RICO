var Launcher = artifacts.require("./Launcher.sol");
var RICO = artifacts.require("./RICO.sol");

module.exports = async function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests


  const rico = await RICO.new();

  const launcher = await Launcher.new();
  
  const changeOwner = await rico.changeOwner(launcher.address, {
    from: accounts[0]
  })

  const init = await launcher.init(rico.address, {
    from: accounts[0]
  });

  const setup = await launcher.setup({
    from: accounts[0]
  });

  //const ss = await si.setup()
  process.on('unhandledRejection', console.dir);

};