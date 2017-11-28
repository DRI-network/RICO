const LauncherSample = artifacts.require("./LauncherSample.sol");
const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");

const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")

module.exports = async function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests

  deployer.deploy(LauncherSample).then(() => {
    return deployer.deploy(RICO)
  }).then(() => {
    return deployer.deploy(SimplePoD)
  }).then(() => {
    return deployer.deploy(RICOToken)
  }).then(async() => {
    // certifiers
    const addresses = [
      accounts[0],
      accounts[1],
      accounts[2]
    ]

    const rico = await RICO.deployed()
    const token = await RICOToken.deployed()
    const launcher = await LauncherSample.deployed()
    const simplePoD = await SimplePoD.deployed()


    // changing owner to owner -> launcher.
    const changeOwner = await rico.transferOwnership(launcher.address, {
      from: accounts[0]
    })

    // changing owner to owner to rico.
    const changeOwner2 = await token.transferOwnership(rico.address, {
      from: accounts[0]
    })

    const changeOwner3 = await simplePoD.transferOwnership(rico.address, {
      from: accounts[0]
    })

    //initializing launcher.
    const init = await launcher.init(rico.address, token.address, simplePoD.address, {
      from: accounts[0]
    });

    //setup launcher
    const setup = await launcher.setup({
      from: accounts[0]
    });
  });
}