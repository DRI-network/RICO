![](https://cdn.dri.network/static/images/rico-banner.png)
[![npm version](https://badge.fury.io/js/rico-core.svg)](https://badge.fury.io/js/rico-core)
[![CircleCI](https://circleci.com/gh/DRI-network/RICO/tree/master.svg?style=shield)](https://circleci.com/gh/DRI-project/RICO/tree/master)
[![Slack Channel](https://dri-slack.now.sh/badge.svg)](https://dri-slack.now.sh/)

**This is a Beta version and may still contain bugs. We are not responsible for any losses caused by this version.**

<!-- MarkdownTOC -->

- [Design Concept][design-concept]
- [Docs][docs]
  - [Whitepaper][whitepaper]
  - [Tutorial][tutorial]
- [Dependencies][dependencies]
- [Installation & overview][installation--overview]
  - [RICO file structure][rico-file-structure]
  - [RICO templates][rico-templates]
- [Using RICO][using-rico]
  - [Deploying the RICO contracts][deploying-the-rico-contracts]
  - [Customize and initialize your ICO][customize-and-initialize-your-ico]
- [LICENSE][license]

<!-- /MarkdownTOC -->

## Design Concept

RICO is a framework which forms a robust boilerplate for decentralized initial coin offerings (ICO). With RICO your ICO will be more responsible and be easier to set up and launch.

##### The problems with conventional ICO's

With a conventional ICO, the project owner can freely decide the process how tokens are generated. That is, the token design and holding ratio is decided by the project owner. After an initial issuance these tokens are sold to supporters at a certain price or exchanged for the total raised funds during the ICO.

##### RICO's approach

With RICO's approach the entire execution process of issuing tokens is strictly defined on the Ethereum Virtual Machine (EVM) and executed automatically. With RICO your ICO will be fully automatic and decentrilized. The decentrilized nature of an ICO created with RICO implements a true fair distribution system.

An ICO made with RICO is:
- Decentralized
- Autonomous
- Fair
- Mintable
- Easy to use

## Docs

### Whitepaper

- [Whitepaper[EN]](https://dri.network/static/RICO-whitepaper-en.pdf)
- [Whitepaper[JP]](https://dri.network/static/RICO-whitepaper.pdf)

### Tutorial

- [RICOTrutorial[JP]](https://scrapbox.io/DRI-community/RICO_Tutorial（日本語版）)

## Dependencies

- [Node](https://nodejs.org/en/) v9.0.0
- [Truffle](http://truffleframework.com/) v4.0.1
- solidity-compiler v0.4.18

Install dependencies:

```bash
$ npm install truffle@4.0.1 -g 
$ npm install ganache-cli -g
```
(You can use ethereumjs-testrpc to test your RICO build.)

## Installation & overview

Install rico-core and generate a new rico project.

```bash
$ npm install -g rico-core
$ rico new helloico && cd helloico
```

### RICO file structure

When we look in the new directory we'll see a lot of different contracts. Here is a quick overview of the most important files that make up RICO.

Contracts:
- **RICO.sol** handles the minting of the Tokens of your ICO.
- **PoD.sol** stands for "Proof of Donation". This handles all the donation logic during your ICO. This contract extends the other PoDs inside the PoDs folder.
- **PoDs/SimplePoD.sol** handles the donations for the public sale.
- **PoDs/RICOStandardPoD.sol** handles the initial Take Over Bid and rewarding the market makers.
- **PoDs/TokenMintPoD.sol** handles a separate token allocation outside of the public sale.
- **PoDs/DutchAuctionPoD.sol** handles the Dutch Auction ICO format.
- **Launcher.sol** can deploy and initialize your ICO based on your own parameters.

Execution scripts:
- **KickStarter/deploy.js** is your startpoint to set your ICO's parameters and send them to the Launcher.

### RICO templates

The RICO framework makes it possible to easily kickstart your ICO with your own ICO requirements. Currently there are three templates available for generating an ICO boilerplate: standard ICO, simple ICO and Dutch Auction.

#### RICO Standard ICO

RICO Standard ICO utilizes the `RICOStandardPoD.sol` and `SimplePoD.sol` for your RICO. This method is our suggested method and integrates a Take Over Bid and offers functionality for rewarding market makers. The tokens the owner receives from the Take Over Bid are locked for a fixed period of a 180 days.

#### Simple ICO

A Simple ICO utilizes the `TokenMintPoD.sol` and `SimplePoD.sol` for your RICO. This method is more old school, having a separate allocation for the owner and offering the remainder of the tokens through a capped or uncapped public sale. The tokens the owner receives from the separate allocation can be locked for a fixed period which can be set freely.

#### Dutch Auction

A Dutch Auction utilizes the `DutchAuctionPoD.sol` for your RICO. This is a more advanced method. The template cannot be initialized via the Launcher contract. It can be initialized via the `init.js` script inside `exec/DutchAuction`, but you will need to deploy the DutchAuctionPoD contract manually.

## Using RICO

RICO is really straightforward:

1. Deploy RICO to the blockchain.
2. Initialize your ICO with the Launcher contract.
3. Mint tokens through the RICO contract.

### Deploying the RICO contracts

You need to deploy three contracts to the network before you can initialize your ICO: `RICO.sol`, `Launcher.sol` and `ContractManager.sol`. We made it very easy by providing a truffle migration file to deploy these contracts. Please see the `migrations/2_deploy_contracts.js`.

#### Local Testnet deploy

First you need to open a local testnet by either (a) opening [Ganache](http://truffleframework.com/ganache/) or (b) run `ganache-cli`. For `ganache-cli` we have already prepared the script inside the file called `rpcrun.bash`.

```bash
# (Mac only) make rpcrun executable
$ chmod +x rpcrun.bash
# run the script
$ ./rpcrun.bash
# migrate and deploy rico with truffle
$ truffle migrate --reset --network testrpc
```

Now we need to obtain the address that RICO was deployed to. After the migration you should see these lines in your terminal:
> Replacing RICO...
... 0x66b3f9a7ab2d993a0336a55c169372762a9e33b5298de468b83321f17a96964c
RICO: 0x1c6f2526b0a5128b89ee0f921f8b8b794189f2ed
Replacing Launcher...
... 0xb8d1c92c5b2d8522bb038bfc86a91e30a3e24a02ba9159c0910bac6cc18495ad
Launcher: 0x39326f43557b33afdad3cec0d0272619c0d7ad9b

We will need the RICO and Launcher addresses as written above.
Continue to [Customize and initialize your ICO](#customize-and-initialize-your-ico).

#### Testnet deploy (ropsten)

**Caution: ropsten hit the Byzantium HardFork #1700000 you have to update geth to v1.7 and sync to the latest block.**

```bash
$ npm install truffle-hdwallet-provider
```

The required contracts are already deployed on the ropsten network:

- **Launcher.sol** address: `0x40c75eb39c3a06c50b9109d36b1e488d99aadf97`
[etherscan](https://ropsten.etherscan.io/address/0x40c75eb39c3a06c50b9109d36b1e488d99aadf97)
- **RICO.sol** address: `0x9e18e5bdb7f47631cf212b34a42cd54cfd713a6d`
[etherscan](https://ropsten.etherscan.io/address/0x9e18e5bdb7f47631cf212b34a42cd54cfd713a6d)

We will need the RICO and Launcher addresses as written above.
Continue to [Customize and initialize your ICO](#customize-and-initialize-your-ico).

#### Mainnet deploy

We haven't deployed the RICO and Launcher contracts to the mainnet yet. Please use truffle console to migrate and deploy the contracts.

### Customize and initialize your ICO

It's time to initialize your ICO with the `deploy.js` script in `exec/KickStarter`. Please check the contents and edit it to your own requirements.

```bash
# Your Mnemonic key will be saved as a process.env variable and is used in the truffle.js file. This wallet will be the project owner's wallet to be used during the ICO.
$ export MNEMONIC_KEY="your mnemonic key 12 words"
# Paste the correct contract address of the deployed RICO contract.
$ export RICO_ADDR=0x1c6f2526b0a5128b89ee0f921f8b8b794189f2ed
# Paste the correct contract address of the deployed Launcher contract.
$ export LAUNCHER_ADDR=0x39326f43557b33afdad3cec0d0272619c0d7ad9b
# Run the deploy.js script.
$ truffle exec exec/KickStarter/deploy.js --network testrpc
```

## LICENSE
RICO is licensed under the GNU General Public License v3.0.
