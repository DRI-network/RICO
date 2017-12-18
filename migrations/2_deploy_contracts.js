const RICO = artifacts.require("./RICO.sol");
const SimplePoD = artifacts.require("./PoDs/SimplePoD.sol")
const KaitsukePoD = artifacts.require("./PoDs/KaitsukePoD.sol")
const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 3 / 100
const tobWeiLimit = 100 * 10 ** 18
const podTokenSupply = totalTokenSupply * 20 / 100
const podWeiLimit = 100 * 10 ** 18

const firstSupply = totalTokenSupply * 30 / 100;
const firstSupplyAge = 72000; //sec

const marketMaker = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set first market maker's address 
const marketMakerAmount = tobWeiLimit; // set ether amount to 100 ether for first market maker.
const now = parseInt(new Date() / 1000)
const execTime = now + 72000;

module.exports = async function (deployer, network, accounts) {

  if (network === "development") return; // Don't deploy on tests

  deployer.deploy(RICO).then(() => {
    return deployer.deploy(SimplePoD)
  }).then(() => {
    return deployer.deploy(KaitsukePoD)
  }).then(async() => {
    // certifiers
    projectOwner = accounts[0]

    rico = await RICO.deployed()
    tob = await KaitsukePoD.deployed()
    pod = await SimplePoD.deployed()

    pods = [
      tob.address,
      pod.address
    ]


    const setConfigTOB = await tob.setConfig(decimals, tobTokenSupply, tobWeiLimit, projectOwner)
    const initTOB = await tob.init(execTime)
    const changeOwnerToB = await tob.transferOwnership(rico.address)

    const setConfigPoD = await pod.setConfig(decimals, podTokenSupply, podWeiLimit)
    const initPoD = await pod.init(execTime)
    const changeOwnerPoD = await pod.transferOwnership(rico.address)

    const addNewProject = await rico.newProject(name, symbol, decimals, totalTokenSupply, pods)

  });
}