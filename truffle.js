module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4612188,
      gasPrice: 30000000000
    },
    testnet: {
      host: "192.168.0.103",
      port: 8545,
      network_id: 3, // Match any network id
      gas: 4612188,
      gasPrice: 30000000000
    }
  }
};