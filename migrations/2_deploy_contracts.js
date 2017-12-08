const LauncherSample = artifacts.require("./LauncherSample.sol");
const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");

const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")
const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol")
const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 3 / 100
const tobWeiLimit = 100 * 10 ** 18
const podTokenSupply = totalTokenSupply * 20 / 100
const podWeiLimit = 1000 * 10 ** 18


module.exports = async function (deployer, network, accounts) {

  if (network === "development") return; // Don't deploy on tests

  deployer.deploy(LauncherSample).then(() => {
    return deployer.deploy(RICO)
  }).then(() => {
    return deployer.deploy(RICOToken)
  }).then(() => {
    return deployer.deploy(KaitsukePoD)
  }).then(() => {
    return deployer.deploy(SimplePoD)
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
    const tob = await KaitsukePoD.deployed()
    const pod = await SimplePoD.deployed()

    const pods = [
      tob.address,
      pod.address,
    ]

    const setConfigToB = await tob.setConfig(tobTokenSupply, tobWeiLimit)
    const changeOwnerToB = await tob.transferOwnership(rico.address)

    const setConfigPoD = await pod.setConfig(podTokenSupply, podWeiLimit)
    const changeOwnerPoD = await pod.transferOwnership(rico.address)


    // changing owner to owner to rico.
    const changeOwnerToken = await token.transferOwnership(rico.address)

    const changeOwnerRICO = await token.transferOwnership(launcher.address)
    
    //initializing launcher.
    const init = await launcher.init(rico.address, totalTokenSupply, token.address, pods, {
      from: accounts[0]
    }).catch((err) => {
      console.log(err)
    })

    //setup launcher
    const setup = await launcher.setup(accounts[0], {
      from: accounts[0]
    });
  });
}