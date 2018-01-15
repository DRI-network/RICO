const DaicoPoD = artifacts.require("./PoDs/DaicoPoD.sol")
const MultiSigWalletWithDailyLimit = artifacts.require("./MultiSigWalletWithDailyLimit.sol")
const MintableToken = artifacts.require("./MintableToken.sol")

module.exports = async function (callback) {

    const owner = await getAccount()
    const daico = await DaicoPoD.new()
    const token = await MintableToken.new()

    const tokenDecimals = 18
    const tokenInitialized = await token.init("DAICOToken", "DIO", tokenDecimals, owner)

    const validator = 0x8a20a13b75d0aefb995c0626f22df0d98031a4b6;

    const wallet = await MultiSigWalletWithDailyLimit.new([owner, validator], 2, 200 * 10 ** 18)

    console.log(`token: ${token.address}, decimals: ${tokenDecimals}, multisigWallet:${wallet.address}`)

    const init = await daico.init(wallet.address, tokenDecimals, token.address);

}

function getAccount() {
    return new Promise((resolve, reject) => {
        web3.eth.getAccounts((err, accounts) => {
            const owner = accounts[0]
            resolve(owner)
        })
    })
}