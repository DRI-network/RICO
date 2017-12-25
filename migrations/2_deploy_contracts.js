const RICO = artifacts.require("./RICO.sol");
const Launcher = artifacts.require("./Launcher.sol")
const KaitsukePoD = artifacts.require("./PoDs/StandardPoD.sol")
const DutchAuctionPoD = artifacts.require("./PoDs/DutchAuctionPoD.sol")

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 10 / 100
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
  }).then(async() => {
    // certifiers
    projectOwner = accounts[0]

    rico = await RICO.deployed()
    launcher = await Launcher.deployed()

    const kickStart = await launcher.kickStart(
      rico.address,
      name,
      symbol,
      decimals,
      0, [tobStartTime, tobTokenSupply, tobWeiLimit, lastSupply], [podStartTime, podTokenSupply, podWeiLimit], [accounts[0], owner], [marketMaker]
    )

    //console.log(kickStart)

  });
}