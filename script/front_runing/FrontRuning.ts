// import { ethers } from "ethers";
//
// const ContractAbiFile = require("../artifacts/contracts/Test.sol/Test.json");
//
// /*
// Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
// Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
// */
// async function listen() {
//     const iface = new ethers.utils.Interface(ContractAbiFile.abi);
//     const privateKey = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
//     const provider = ethers.getDefaultProvider("http://localhost:8545");
//     const myWallet = new ethers.Wallet(privateKey, provider);
//
//     // await (provider as any).send("evm_setIntervalMining", [10000]);
//     provider.on("pending", async (tx) => {
//         console.log("tx detected: ", tx);
//         if (tx.data.indexOf(iface.getSighash("mint")) >= 0 && tx.from !== myWallet.address) {
//             // const parsedTx = iface.parseTransaction(tx);
//             // console.log("tx parsed: ", parsedTx);
//
//             const frontRunTx = {
//                 to: tx.to,
//                 value: tx.value,
//                 gasPrice: tx.gasPrice.mul(2),
//                 gasLimit: tx.gasLimit.mul(2),
//                 data: tx.data
//             };
//             const tmpTx = await myWallet.sendTransaction(frontRunTx);
//             console.log("Front Tx=", tmpTx);
//             await tmpTx.wait();
//         }
//     })
// }
//
// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// listen().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });