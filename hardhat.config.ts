import "@nomiclabs/hardhat-waffle"
import "@nomicfoundation/hardhat-chai-matchers"
import "@typechain/hardhat"
import "solidity-coverage"
import "hardhat-deploy"
import "hardhat-gas-reporter"
import { HardhatUserConfig } from "hardhat/config"
import { resolve } from "path"
import { config as dotenvConfig } from "dotenv"

dotenvConfig({ path: resolve(__dirname, "./.env") })

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.12",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    namedAccounts: {
        deployer: 0,
    },
    networks: {
        hardhat: {
            allowUnlimitedContractSize: true,
            // gas: 299021464,
            // blockGasLimit: 299021464,
        },
    },
    typechain: {
        outDir: "typechain",
    },
    paths: {
        tests: "./test2",
    },
}

export default config
