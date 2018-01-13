const RICO = artifacts.require("./RICO.sol")

module.exports = async function (callback) {

  const rico = await RICO.deployed()

  const tokens = await rico.getTokens()

  console.log(tokens)

  const owner = await getAccount()

  const mintToken = await rico.mintToken(tokens[0], 0, 0x0)
  
  console.log("transaction tx:", mintToken)
}

function getAccount() {
  return new Promise((resolve, reject) => {
    web3.eth.getAccounts((err, accounts) => {
      const owner = accounts[0]
      resolve(owner)
    })
  })
}