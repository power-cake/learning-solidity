// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 使用外部合约隐藏恶意代码
 * @dev   在solidity中， 任何地址都可以转换为特定合约，即使该地址的合约不是被转换的合约
          这可能被用来隐藏恶意代码。让我们看看如何。
 */


/*
Let's say Alice can see the code of Foo and Bar but not Mal.
It is obvious to Alice that Foo.callBar() executes the code inside Bar.log().
However Eve deploys Foo with the address of Mal, so that calling Foo.callBar()
will actually execute the code at Mal.
*/

/*
1. Eve deploys Mal
2. Eve deploys Foo with the address of Mal
3. Alice calls Foo.callBar() after reading the code and judging that it is
   safe to call.
4. Although Alice expected Bar.log() to be execute, Mal.log() was executed.
*/

contract foo {
    Bar bar;

    constructor(address _bar) {
        bar = Bar(_bar);
    }

    function callBar() public {
        bar.log();
    }
}

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}

contract Mal {
    event Log(string message);

    // function () external {
    //     emit Log("Mal was called");
    // }

    // Actually we can execute the same exploit even if this function does
    // not exist by using the fallback

    function log() public {
        emit Log("Mal was called");
    }
}

//预防技术
//在构造函数中初始化新合约
//制作外部合约的地址public，以便可以审查外部合约的代码
//Bar public bar;
//
//constructor() public {
//bar = new Bar();
//}