// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}


contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

contract U is S("s"), T("t") {

}

contract V is S, T {
//    合约的构造函数是会按照合约的继承顺序进行初始化的
    constructor(string memory _name,string memory _text) S(_name) T(_text) {

    }
}

//混合使用
contract VV is S("s"), T {
    constructor(string memory _text) T(_text) {

    }
}