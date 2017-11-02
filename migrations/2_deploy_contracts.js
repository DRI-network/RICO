var Launcher = artifacts.require("./Launcher.sol");
var RICO = artifacts.require("./RICO.sol");

module.exports = async function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests
 
  // owner is geth accounts [0]
  const projectOwner = accounts[0]

  // deploying rico.
  const rico = await RICO.new();

  // deploying launcher.
  const launcher = await Launcher.new();
  
  // changing owner to projectOwner -> launcher.
  const changeOwner = await rico.changeOwner(launcher.address, {
    from: accounts[0]
  })

  //initializing launcher.
  const init = await launcher.init(rico.address, {
    from: accounts[0]
  });

  //setup launcher
  const setup = await launcher.setup({
    from: accounts[0]
  });
};