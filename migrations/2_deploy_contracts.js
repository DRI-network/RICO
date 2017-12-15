const RICO = artifacts.require("./RICO.sol");
const RICOToken = artifacts.require("./RICOToken.sol");
const TokenMintPoD = artifacts.require("./PoDs/TokenMintPoD.sol")
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
    return deployer.deploy(TokenMintPoD)
  }).then(() => {
    return deployer.deploy(SimplePoD)
  }).then(() => {
    return deployer.deploy(KaitsukePoD)
  }).then(async() => {
    // certifiers
    projectOwner = accounts[0]
    tobAccount = projectOwner

    rico = await RICO.deployed()
    tob = await KaitsukePoD.deployed()
    pod = await SimplePoD.deployed()
    mint1 = await TokenMintPoD.deployed()

    pods = [
      tob.address,
      pod.address,
      mint1.address
    ]

    const addToken = await rico.newToken(name, symbol, decimals)
    
    const tokenAddr = await rico.tokens.call(0)
    console.log(tokenAddr)
    
    //console.log(projectOwner, tobAccount, pods)
    const init = await rico.init(pods, tokenAddr)
    
    const setConfigToB = await tob.setConfig(decimals, tobTokenSupply, tobWeiLimit, tobAccount)
    const changeOwnerToB = await tob.transferOwnership(rico.address)

    const setConfigPoD = await pod.setConfig(decimals, podTokenSupply, podWeiLimit)
    const changeOwnerPoD = await pod.transferOwnership(rico.address)

    const setConfigMint1 = await mint1.setConfig(projectOwner, 72000, firstSupply)
    const changeOwnerMint1 = await mint1.transferOwnership(rico.address)

    // changing owner to owner to rico.
   // const changeOwnerToken = await token.transferOwnership(rico.address)

    //initializing launcher.

   // const setTOB = await rico.addTokenRound(0);
   // const setPoD = await rico.addTokenRound(1);
   // const setFirstTokenSupply = await rico.addTokenRound(2);
    const setFirstWithdrawal = await rico.addWithdrawalRound(marketMakerAmount, execTime, marketMaker, true);
    //const setSecondWithdrawal = await rico.addWithdrawalRound(podWeiLimit, execTime, projectOwner, false);


  });
}