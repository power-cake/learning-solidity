// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

 /**
 * @title 可升级的代理合约， 透明代理， 主要展示delegatecall 和  返回数据
 * @dev   x
 */
contract Proxy {
    address public implementation;

    function seImplementation(address _imp) external {
        implementation = _imp;
    }

    function _delegate(address _imp) internal virtual {
        assembly {
             // calldatacopy(t, f, s)
            // copy s bytes from calldata at position f to mem at position t
            calldatacopy(0, 0, calldatasize())


            // delegatecall(g, a, in, insize, out, outsize)
            // - call contract at address a
            // - with input mem[in…(in+insize))
            // - providing g gas
            // - and output area mem[out…(out+outsize))
            // - returning 0 on error and 1 on success
            let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)

            // returndatacopy(t, f, s)
            // copy s bytes from returndata at position f to mem at position t
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                // revert(p, s)
                // end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
            default {
                // return(p, s)
                // end execution, return data mem[p…(p+s))
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {}

}

contract v1 {
    address public implementation;
    uint public x;

    function inc() external {
        x += 1;
    }

}


contract V2 {
    address public implementation;
    uint public x;

    function inc() external {
        x += 1;
    } 

    function dec() external {
        x -= 1;    
    }
}