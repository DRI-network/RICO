// This is a bit unruly, and needs to be put in its own package.
// But all this preamble tells Truffle how to sign transactions on
// its own from a bip39 mnemonic (which creates addresses and private keys).
// This allows Truffle deployment to work with infura. Note we do
// this specifically when deploying to the morden network.


let provider;
const HDWalletProvider = require('truffle-hdwallet-provider');
//const mnemonic = "recipe vintage differ tobacco venture federal inquiry cross pig bean adapt seven"
const mnemonic = process.env.KEY
ropsten = new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/')
rinkeby = new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/')

//console.log(rinkebyProvider.address)

module.exports = {
 
};