module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
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
