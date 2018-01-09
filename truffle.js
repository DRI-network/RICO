// This is a bit unruly, and needs to be put in its own package.
// But all this preamble tells Truffle how to sign transactions on
// its own from a bip39 mnemonic (which creates addresses and private keys).
// This allows Truffle deployment to work with infura. Note we do
// this specifically when deploying to the morden network.


let provider;
const HDWalletProvider = require('truffle-hdwallet-provider');
//const mnemonic = "recipe vintage differ tobacco venture federal inquiry cross pig bean adapt seven"

const mnemonic = process.env.MNEMONIC_KEY
ropsten = new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/')
rinkeby = new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/')
mainnet = new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/')


//console.log(rinkebyProvider.address)

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*", // Match test network id
      gas: 4642056,
      gasPrice: 10000000000
    },
    testrpc: {
      host: "localhost",
      port: 9545,
      network_id: 3, // Match ropsten network id
      gas: 4699006,
      gasPrice: 10000000000
    },
    ropsten: {
      provider: ropsten,
      network_id: 3, // Match ropsten network id
      gas: 4680036,
      gasPrice: 240000000000
    },
    rinkeby: {
      provider: rinkeby,
      network_id: 4,
      gas: 4700036,
      gasPrice: 15000000000
    },
    mainnet: {
      provider: mainnet,
      network_id: 1,
      gas: 4700036,
      gasPrice: 15000000000
    },
  }
};