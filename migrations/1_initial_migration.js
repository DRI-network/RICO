var Migrations = artifacts.require("./Migrations.sol");

module.exports = async function (deployer, network, accounts) {

  deployer.deploy(Migrations);
};
