import { ethers } from 'ethers';

async function main () {
    const provider = ethers.getDefaultProvider("http://localhots:8545");

    await (provider as any).send("evm_setAutomine", [false]);
    await (provider as any).send("evm_setIntervalMining", [10000]);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})
