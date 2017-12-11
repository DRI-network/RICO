const LauncherSample = artifacts.require("./LauncherSample.sol");
const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");
const TokenMintPoD = artifacts.require("./PoDs/TokenMintPoD.sol")
const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")
const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol")
const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 3 / 100
const tobWeiLimit = 100 * 10 ** 18
const podTokenSupply = totalTokenSupply * 20 / 100
const podWeiLimit = 100 * 10 ** 18

const firstSupply = totalTokenSupply * 30 / 100;
const decimals = 18;


module.exports = async function (deployer, network, accounts) {

  if (network === "development") return; // Don't deploy on tests

  deployer.deploy(LauncherSample).then(() => {
    return deployer.deploy(RICO)
  }).then(() => {
    return deployer.deploy(TokenMintPoD)
  }).then(() => {
    return deployer.deploy(RICOToken)
  }).then(() => {
    return deployer.deploy(KaitsukePoD)
  }).then(() => {
    return deployer.deploy(SimplePoD)
  }).then(async() => {
    // certifiers
    projectOwner = accounts[0]
    tobAccount = accounts[1]

    rico = await RICO.deployed()
    token = await RICOToken.deployed()
    launcher = await LauncherSample.deployed()
    tob = await KaitsukePoD.deployed()
    pod = await SimplePoD.deployed()
    mint1 = await TokenMintPoD.deployed()

    pods = [
      tob.address,
      pod.address,
      mint1.address
    ]

    const setConfigToB = await tob.setConfig(decimals, tobTokenSupply, tobWeiLimit, tobAccount)
    const changeOwnerToB = await tob.transferOwnership(rico.address)

    const setConfigPoD = await pod.setConfig(decimals, podTokenSupply, podWeiLimit)
    const changeOwnerPoD = await pod.transferOwnership(rico.address)

    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp

    const setConfigMint1 = await mint1.setConfig(projectOwner, 72000, firstSupply)
    const changeOwnerMint1 = await mint1.transferOwnership(rico.address)

    // changing owner to owner to rico.
    const changeOwnerToken = await token.transferOwnership(rico.address)
    const changeOwnerRICO = await rico.transferOwnership(launcher.address)

    //initializing launcher.
    const init = await launcher.init(rico.address, totalTokenSupply, token.address, pods)

    //setup launcher
    const setup = await launcher.setup(accounts[0]);
  });
}