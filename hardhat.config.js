require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-ignition-ethers");
require("hardhat-contract-sizer");

// 代理
const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:33210");
setGlobalDispatcher(proxyAgent);

const ETHERSCAN_API_KEY =  vars.get("ETHERSCAN_API_KEY");
const ALCHEMY_API_KEY = vars.get("ALCHEMY_API_KEY");
const PRIVATE_KEY = vars.get("PRIVATE_KEY");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.24",
        settings: {
            optimizer: {
                enabled: true,
                runs: 100,
            },
            viaIR: true
        },
    },
    networks: {
        sepolia: {
            url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
        },
        mainnet: {
            url:`https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
            accounts: [PRIVATE_KEY],
            gasPrice: 20000000000,
            gas: 12000000
        }
    },
    etherscan: {
        apiKey: {
            sepolia: ETHERSCAN_API_KEY,
            mainnet: ETHERSCAN_API_KEY
        }
    },
    contractSizer: {
        alphaSort: true,
        disambiguatePaths: false,
        runOnCompile: true,
        strict: true,
        // only: [':ERC20$'],
        only: [],
    }
};
