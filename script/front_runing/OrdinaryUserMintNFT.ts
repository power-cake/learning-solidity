// import {task} from "hardhat/config";
// import { ethers } from 'ethers';
//
// task("test-transaction", "This task is broken")
//     .setAction(async () => {
//         const tokenId = 25;
//         const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
//         const test = await ethers.getContractAt('Test', contractAddress);
//
//         try {
//             const tx = await test.mint(tokenId);
//             await tx.wait();
//         } catch (e) {
//             console.error(e);
//         } finally {
//             const owner = await test.ownerOf(tokenId);
//             console.log(`owner of ${tokenId}: ${owner}`);
//         }
//     });