
// This is a bit unruly, and needs to be put in its own package.
// But all this preamble tells Truffle how to sign transactions on
// its own from a bip39 mnemonic (which creates addresses and private keys).
// This allows Truffle deployment to work with infura. Note we do
// this specifically when deploying to the morden network.

var hdkey = require('ethereumjs-wallet/hdkey');
var bip39 = require("bip39");
var ProviderEngine = require("web3-provider-engine");
var WalletSubprovider = require('web3-provider-engine/subproviders/wallet.js');
var Web3Subprovider = require("web3-provider-engine/subproviders/web3.js");
var Web3 = require("web3");
var fs = require("fs");
var path = require("path")

// Read the mnemonic from a file that's not committed to github, for security.
var mnemonic = fs.readFileSync(path.join(__dirname, "deploy_mnemonic.key"), {encoding: "utf8"}).trim();

var wallet_hdpath = "m/44'/60'/0'/0/";
var hd = hdkey.fromMasterSeed(bip39.mnemonicToSeed(mnemonic));

// Get the first account
var account = hd.derivePath(wallet_hdpath + "0")
var wallet = account.getWallet();
var address = "0x" + wallet.getAddress().toString("hex");

var providerUrl = "https://morden.infura.io:8545";

var engine = new ProviderEngine();
engine.addProvider(new WalletSubprovider(wallet, {}));
engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(providerUrl)));
engine.start(engine);

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
