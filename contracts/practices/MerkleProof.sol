// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 默克尔树证明
 * @dev
 */
contract MerkleProof {
    function verify(
        bytes32[] memory proof, // 路径
        bytes32 root,
        bytes32 leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 hash = leaf;
        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            }else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
            index = index / 2;
        }

        return hash == root;
    }
}

contract TestMerkleProof is  MerkleProof {
    bytes32[] public hashes;

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> deve",
            "carol -> alice",
            "dave -> bob"
        ];

        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint n = transactions.length;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n -1 ; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i],hashes[offset + i + 1])
                    )
                );
            }
            offset += n ;
            n = n / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }
}

//0x78a93af7ef9f1380d64a61c552cbefc298da07acb65530265b8ade6ebe8218c4  a
//0x27d675649b34c1dba39dd5412cbb4f0f80fa663719bf696df9cd9b3b8e991ec0  b
//0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b  c
//0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950  d
//0xce606f59371cc346c4d12b0c06ed9c3a13ced32c9f291f9d4aa04dd8d1f6f285  a&b
//0x2f71627ef88774789455f181c533a6f7a68fe16e76e7a50362af377269aabfee  c&d
////0x3d9c864da34d5c8b20bc2b1001ceed79f07cd1ea46c3204d5ca48165bfeeb6bb  root

//verify参数：
// proof（路径） = ["0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950","0xce606f59371cc346c4d12b0c06ed9c3a13ced32c9f291f9d4aa04dd8d1f6f285"]
// root = 0x3d9c864da34d5c8b20bc2b1001ceed79f07cd1ea46c3204d5ca48165bfeeb6bb
// leaf = 0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b  叶子节点
// index = 2