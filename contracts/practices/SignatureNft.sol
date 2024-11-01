// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title NFT项目方可以利用ECDSA的这个特性发放白名单。由于签名是链下的，不需要gas，
 *        因此这种白名单发放模式比Merkle Tree模式还要经济。方法非常简单，项目方利用项目方账户把白名单发放地址签名（可以加上地址可以铸造的tokenId）。然后mint的时候利用ECDSA检验签名是否有效，如果有效，则给他mint。
 *        SignatureNFT合约实现了利用签名发放NFT白名单。
 * @dev   x
 */
contract SignatureNft is ERC721{
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
//     签名地址
    address  immutable public signer;
//    记录已经妈mint的地址
    mapping(address => bool) public mintedAddress;

    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol){
        signer = _signer;
    }

    function mint(address _account, uint _tokenId, bytes memory _sig) external{
        bytes32 _msgHash = getMessageHash(_account,_tokenId);
        bytes32 _ethSignedMessageHash = _msgHash.toEthSignedMessageHash();
        require(verify(_ethSignedMessageHash,_sig), "Invalid signature");
        require(!mintedAddress[_account], "Already minted");
        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }

    function getMessageHash(address _account, uint _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _sig) public view returns (bool){
        return _msgHash.recover(_sig) == signer;
    }

}
