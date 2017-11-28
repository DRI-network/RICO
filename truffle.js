
// This is a bit unruly, and needs to be put in its own package.
// But all this preamble tells Truffle how to sign transactions on
// its own from a bip39 mnemonic (which creates addresses and private keys).
// This allows Truffle deployment to work with infura. Note we do
// this specifically when deploying to the morden network.


var provider;
var HDWalletProvider = require('truffle-hdwallet-provider');
var mnemonic = "plastic tape elbow naive gloom reject spot just iron horror wine around ramp ready damage"

if (!process.env.SOLIDITY_COVERAGE){
  provider = new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/')
}

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*", // Match test network id
      gas: 4602056,
      gasPrice: 10000000000
    },
    testnet: {
      host: "192.168.0.103",
      port: 8545,
      network_id: 3, // Match ropsten network id
      gas: 4700036,
      gasPrice: 15000000000
    },
    mainnet: {
      host: "10.23.122.2",
      port: 8545,
      network_id: 1, // Match main network id
      gas: 7000000,  // Gaslimit based on latestblock
      gasPrice: 30000000000
    }
  }
};
