![](https://dri.network/static/images/rico-banner.png)
[![npm version](https://badge.fury.io/js/rico-core.svg)](https://badge.fury.io/js/rico-core)
[![CircleCI](https://circleci.com/gh/DRI-network/RICO/tree/master.svg?style=shield)](https://circleci.com/gh/DRI-project/RICO/tree/master)
[![Slack Channel](https://dri-slack.now.sh/badge.svg)](https://dri-slack.now.sh/)

**This is an Alpha version and may still contain bugs. We are not responsible for any losses caused by this version.**

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
- [RICOTrutorial[JP]](https://scrapbox.io/DRI-community/RICO_Tutorial%EF%BC%88%E3%83%AA%E3%82%B3%E3%83%BC%E3%81%AE%E3%83%81%E3%83%A5%E3%83%BC%E3%83%88%E3%83%AA%E3%82%A2%E3%83%AB%EF%BC%89)


## Dependencies

- Mac OSX 10.13.1
- Node v9.0.0
- Truffle v4.0.1
- solidity-compiler v0.4.18

This project requires the [truffle framework](http://truffleframework.com/) to be installed globally. Please make sure you install this globally first:
```bash
$ npm install truffle@4.0.1 -g 
```
You can use ethereumjs-testrpc to test your RICO build.
```bash
$ npm install ganache-cli -g
```

## Getting Started 

### install rico-core
```bash
$ npm install -g rico-core
```

### new project generate
```bash
$ rico new ./helloico && cd ./helloico 
```

### Testnet deploy (rinkeby)

**Caution: ropsten hit the Byzantium HardFork #1700000 you have to update geth to v1.7 and sync to the latest block.**

```
$ npm install truffle-hdwallet-provider
```
Attachment contracts:
```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR=0xdc063bd44f1a395c5d1f3d4bdc75396aaf8b4b75
$ export LAUNCHER_ADDR=0x9851fa8938542234ed9261258dd19281a60f348a
$ truffle exec exec/KickStart/deploy.js --network rinkeby
``` 

### Mainnet deploy

```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR="non"
$ export LAUNCHER_ADDR="non"
$ truffle exec exec/KickStart/deploy.js --network mainnet
``` 

## Test 

### testing on ethereumjs-testrpc

running testrpc with account balance.

```bash
$ ./rpcrun.bash
```

```bash
$ truffle test 
```
### testing on ropsten testnet

please set the timeout to `this.timeout` if the block confirmation is too slow.

```bash
$ truffle test --network testnet
```

## LICENSE
RICO is licensed under the GNU General Public License v3.0.