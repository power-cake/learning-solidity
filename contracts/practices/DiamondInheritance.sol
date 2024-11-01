// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title x
 * @dev   x
 */
// 钻石继承
contract God {
    event Log(string message);

    function foo() public virtual {
        emit Log("God.foo called");
    }

    function bar() public virtual {
        emit Log("God.bar called");
    }
}


contract Adam is God {
    function foo() public virtual override {
        emit Log("Adam.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Adam.bar called");
        super.bar();
    }
}

contract Eve is God {
    function foo() public virtual override {
        emit Log("Eve.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Eve.bar called");
        super.bar();
    }
}

contract people is Adam, Eve {
    function foo() public override(Adam, Eve) {
        super.foo();
    }

    function bar() public override(Adam, Eve) {
        super.bar();
    }
}

//在多重+菱形继承链条上使用super关键字时，需要注意的是使用super会调用继承链条上的每一个合约的相关函数，而不是只调用最近的父合约
//在这个例子中，调用合约people中的super.bar()会依次调用Eve、Adam，最后是God合约。
//虽然Eve、Adam都是God的子合约，但整个过程中God合约只会被调用一次。原因是Solidity借鉴了Python的方式，强制一个由基类构成的DAG（有向无环图）使其保证一个特定的顺序。更多细节你可以查阅Solidity的官方文档。

/**
 * [
	{
		"from": "0x24f8ceE97aDCc6879b44A5BebfE92167fB1b27F4",
		"topic": "0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab",
		"event": "Log",
		"args": {
			"0": "Eve.bar called",
			"message": "Eve.bar called"
		}
	},
	{
		"from": "0x24f8ceE97aDCc6879b44A5BebfE92167fB1b27F4",
		"topic": "0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab",
		"event": "Log",
		"args": {
			"0": "Adam.bar called",
			"message": "Adam.bar called"
		}
	},
	{
		"from": "0x24f8ceE97aDCc6879b44A5BebfE92167fB1b27F4",
		"topic": "0xcf34ef537ac33ee1ac626ca1587a0a7e8e51561e5514f8cb36afa1c5102b3bab",
		"event": "Log",
		"args": {
			"0": "God.bar called",
			"message": "God.bar called"
		}
	}
]
 */