//合约地址：0x2f044f58488bf65998fef6a7de60f230fd13fef4
// Version of Solidity compiler this program was written for
pragma solidity ^0.4.22;

contract owned {
	address owner;
	// Contract constructor: set owner
	constructor() {
		owner = msg.sender;
	}
	// Access control modifier
	modifier onlyOwner {
		require(msg.sender == owner, "Only the contract owner can call this function");
		_;
	}
}

contract mortal is owned {
	// Contract destructor
	function destroy() public onlyOwner {
		selfdestruct(owner);
	}
}

contract Faucet is mortal {
	event Withdrawal(address indexed to, uint amount);
	event Deposit(address indexed from, uint amount);

	// Give out ether to anyone who asks
	function withdraw(uint withdraw_amount) public {
		// Limit withdrawal amount
		require(withdraw_amount <= 0.1 ether);

		require(this.balance >= withdraw_amount,
			"Insufficient balance in faucet for withdrawal request");

		//msg 对象是所有合约可以访问的输入之一。它代表触发执行此合约的交易。属性 sender 是交易的发件人地址。函数 transfer 是一个内置函数，它将ether从合约传递到调用它的地址。从后往前读，表示 transfer 到触发此合约执行的 msg 的 sender。transfer 函数将一个金额作为唯一的参数。我们传递之前声明为 withdraw 方法的参数的 withdraw_amount 值。
		msg.sender.transfer(withdraw_amount);

		emit Withdrawal(msg.sender, withdraw_amount);
	}
	// Accept any incoming amount
	function () public payable {
		emit Deposit(msg.sender, msg.value);
	}
}