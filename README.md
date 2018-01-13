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
$ rico new helloico && cd helloico 
```

### Testnet deploy (ropsten)

**Caution: ropsten hit the Byzantium HardFork #1700000 you have to update geth to v1.7 and sync to the latest block.**

```
$ npm install truffle-hdwallet-provider
```
Attachment contracts:
```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR=0x9e18e5bdb7f47631cf212b34a42cd54cfd713a6d
$ export LAUNCHER_ADDR=0x40c75eb39c3a06c50b9109d36b1e488d99aadf97
$ truffle exec exec/KickStart/deploy.js --network ropsten
``` 

### Mainnet deploy

```bash
$ export MNEMONIC_KEY="your mnemonic key 12 words" 
$ export RICO_ADDR="non"
$ export LAUNCHER_ADDR="non"
$ truffle exec exec/KickStart/deploy.js --network mainnet
``` 

### Customize KickStart project

To customizing ico deploy files -> exec/KickStart/deploy.js
```js
const Launcher = artifacts.require("./Launcher.sol")
const RICO = artifacts.require("./RICO.sol")
const MultiSigWalletWithDailyLimit = artifacts.require("./MultiSigWalletWithDailyLimit.sol")

const name = "Responsible ICO Token";
const symbol = "RIT";
const decimals = 18;

const totalTokenSupply = 400000 * 10 ** 18; // set maximum supply to 400,000.
const tobTokenSupply = totalTokenSupply * 10 / 100
const tobWeiLimit = 100 * 10 ** 18
const now = parseInt(new Date() / 1000)
const tobStartTime = now + 72000; //sec

const podTokenSupply = totalTokenSupply * 90 / 100
const podWeiLimit = 100 * 10 ** 18
const podStartTime = now + 172000; //sec

const lastSupply = totalTokenSupply * 30 / 100;

const marketMaker = 0x1d0DcC8d8BcaFa8e8502BEaEeF6CBD49d3AFFCDC; // set first market maker's address 
const owner = 0x8a20a13b75d0aefb995c0626f22df0d98031a4b6;
const dailyLimit = 200 * 10 ** 18

module.exports = async function (callback) {

  const rico = await RICO.at(process.env.RICO_ADDR) // ropsten tsetnet
  const launcher = await Launcher.at(process.env.LAUNCHER_ADDR) //ropsten testnet
  const po = await getAccount()

  console.log(`RICO: ${rico.address} launcher: ${launcher.address}`)

  const wallet = await MultiSigWalletWithDailyLimit.new([owner, po], 2, dailyLimit)

  console.log(`MultisigWallet: ${wallet.address}`)

  const kickStart = await launcher.kickStartB(
      name,
      symbol,
      decimals,
      wallet.address, [podStartTime, podTokenSupply, podWeiLimit], [podTokenSupply / 2, podStartTime + 78000]
    )
  }

  console.log(`tx:${kickStart.tx}`)

}

```

To call  `kickStartA` process mean that use to RICO standard pods.
```js
  kickStart = await launcher.kickStartA(
    rico.address,
    name,
    symbol,
    decimals,
    wallet.address,
    0, [tobStartTime, tobTokenSupply, tobWeiLimit, lastSupply], [podStartTime, podTokenSupply, podWeiLimit], [po, owner], [marketMaker]
  )
```

## Test 

### testing on ganache-cli

running ganache-cli with account balance.

```bash
$ ./rpcrun.bash
```

```bash
$ truffle test 
```

## LICENSE
RICO is licensed under the GNU General Public License v3.0.