
require('hardhat-gas-reporter')
require('hardhat-spdx-license-identifier')
require('hardhat-deploy')
require('hardhat-abi-exporter')
require('@nomiclabs/hardhat-ethers')
require('dotenv/config')
require('@nomiclabs/hardhat-etherscan')
require('@nomiclabs/hardhat-waffle')
require('solidity-coverage')
require('./tasks')

const { PRIVATE_KEY, INFURA_KEY} = process.env;
let accounts = [];
accounts.push(PRIVATE_KEY);


module.exports = {
  defaultNetwork: 'hardhat',
  abiExporter: {
    path: './abi',
    clear: false,
    flat: true
  },
  gasReporter: {
    enabled: false,
//    currency: 'USD',
  },
  networks: {
    hardhat: {
      forking: {
        enabled: false,
        url: `https://data-seed-prebsc-1-s1.binance.org:8545`
      },
      netallowUnlimitedContractSize: true,
      live: true,
      saveDeployments: false,
      tags: ['local'],
      timeout: 2000000,
      chainId:97
    },
    Mapo: {
      url: `https://rpc.maplabs.io/`,
      chainId : 22776,
      accounts: accounts
    },
    Makalu: {
      url: `https://testnet-rpc.maplabs.io/`,
      chainId : 212,
      accounts: accounts
    },
    Matic: {
      url: `https://rpc-mainnet.maticvigil.com`,
      chainId : 137,
      accounts: accounts
    },
    MaticTest: {
      url: `https://rpc.ankr.com/polygon_mumbai`,
      chainId : 80001,
      accounts: accounts
    },
    Bsc: {
      url: `https://bsc.blockpi.network/v1/rpc/public`,
      chainId : 56,
      accounts: accounts
    },
    BscTest: {
      url: `https://data-seed-prebsc-2-s1.binance.org:8545/`,
      chainId : 97,
      accounts: accounts
     // gasPrice: 11 * 1000000000
    },
    Eth: {
      url: `https://mainnet.infura.io/v3/` + INFURA_KEY,
      chainId : 1,
      accounts: accounts
    },
    Sepolia: {
      url: `https://1rpc.io/sepolia`,
      chainId: 11155111,
      accounts: accounts
    },
    Klay: {
      url: `https://public-node-api.klaytnapi.com/v1/cypress`,
      chainId : 8217,
      accounts: accounts
    },
    KlayTest: {
      url: `https://klaytn-baobab.blockpi.network/v1/rpc/public`,
      chainId : 1001,
      accounts: accounts
    },
    ArbitrumSepolia: {
      chainId: 421614,
      url: `https://sepolia-rollup.arbitrum.io/rpc`,
      accounts: accounts
    },
    DodoTest: {
      url: `https://dodochain-testnet.alt.technology`,
      chainId : 53457,
      accounts: accounts
    },
    TronTest: {
      url: `https://nile.trongrid.io/jsonrpc`,
      chainId: 3448148188,
      accounts: accounts,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.20',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          "evmVersion": "london"
        }
      },
    ]
  },
  spdxLicenseIdentifier: {
    overwrite: false,
    runOnCompile: false
  },
  mocha: {
    timeout: 2000000
  },
  etherscan: {
    apiKey: process.env.BSC_SCAN_KEY
  }
}
