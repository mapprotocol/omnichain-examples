# OmniDictionary Contract Examples

## Setup Instructions

Edit the .env-example.txt file and save it as .env

The following node and npm versions are required

```
$ node -v
v14.17.1
$ npm -v
6.14.13
```

Configuration file description

PRIVATE_KEY User-deployed private key

INFURA_KEY User-deployed infura key

DEPLOY_FACTORY Factory-contract address

OMNICHAIN_SALT User-deployed OmniDictionary contract salt



## Build

```
git clone https://github.com/mapprotocol/omnichain-examples.git
cd omnichain-examples/evm/
npm install
```

## Deploy

Follow any of the tutorials below

### omniDictionary.sol

1. Deploy omniDictionary contract

```
npx hardhat factoryDeploy --mos <MOS contract address Optional> --network <network>
```



## Instruct Setup

The two commands can be used to complete the call of chain A to chain B contract and verify the result

1.getDictionary

```
npx hardhat getDictionary --address <omniDictionary contract address> --key <Query key string> --network <network>
```

2.sendDictionary

```
npx hardhat sendDictionary --address <omniDictionary contract address> --key < key string> --value <value string> --chainid <The cross-chain chainId of the message> --target <Target chain execution address> --network <network>
```

