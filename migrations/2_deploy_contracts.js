const RICO = artifacts.require("./RICO.sol");
const Launcher = artifacts.require("./Launcher.sol")
const ContractManager = artifacts.require("./ContractManager.sol")

module.exports = async function (deployer, network, accounts) {

  if (network === "development") return; // Don't deploy on tests

  deployer.deploy(RICO).then(() => {
    return deployer.deploy(Launcher)
  }).then(() => {
    return deployer.deploy(ContractManager)
  }).then(async() => {
    // certifiers
    projectOwner = accounts[0]

    rico = await RICO.deployed()
    launcher = await Launcher.deployed()
    cm = await ContractManager.deployed()
    init = await launcher.init(rico.address, cm.address)

  });
}