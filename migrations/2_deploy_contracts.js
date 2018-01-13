const RICO = artifacts.require("./RICO.sol");
const Launcher = artifacts.require("./Launcher.sol")
const ContractManager = artifacts.require("./ContractManager.sol")

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 1 / 10
const tobWeiLimit = 100 * 10 ** 18
const now = parseInt(new Date() / 1000)
const tobStartTime = now + 72000; //sec

const podTokenSupply = totalTokenSupply * 90 / 100
const podWeiLimit = 100 * 10 ** 18
const podStartTime = now + 172000; //sec

const lastSupply = totalTokenSupply * 30 / 100;

const marketMaker = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set first market maker's address 
const owner = 0x8a20a13b75d0aefb995c0626f22df0d98031a4b6;

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

    const standardICO = await launcher.standardICO(
      name,
      symbol,
      decimals,
      projectOwner, [tobStartTime, tobTokenSupply, tobWeiLimit, lastSupply], [podStartTime, podTokenSupply, podWeiLimit], [projectOwner, owner], [marketMaker, owner]
    )

    const simpleICO = await launcher.simpleICO(
      name,
      symbol,
      decimals,
      projectOwner, [podStartTime, podTokenSupply, podWeiLimit], [podTokenSupply / 2, podStartTime + 78000]
    )

  });
}