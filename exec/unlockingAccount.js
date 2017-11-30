module.exports = async function (callback) {

  const accounts = web3.eth.accounts

  const result = web3.personal.unlockAccount(accounts[0], process.env.PASS, 100000)
  
  if (!result) [
    console.log("Error account is locked")
  ]
  console.log("Success! account is unlocked")
}