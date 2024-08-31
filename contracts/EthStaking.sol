// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract EtherStaking {
    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool withdrawn;
    }

    mapping(address => Stake) public stakes;
    uint256 public rewardRate;
    uint256 public stakingPeriod;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    event Staked(address indexed user, uint256 amount, uint256 time);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    constructor(uint256 _rewardRate, uint256 _stakingPeriod) {
        require(_rewardRate > 0, "Reward rate must be greater than 0");
        require(_stakingPeriod > 0, "Staking period must be greater than 0");
        rewardRate = _rewardRate;
        stakingPeriod = _stakingPeriod;
        owner = msg.sender;
    }

    function stakeEther() external payable {
        require(msg.value > 0, "Stake amount must be greater than 0");
        require(stakes[msg.sender].amount == 0, "Already staking");

        stakes[msg.sender] = Stake({
            amount: msg.value,
            startTime: block.timestamp,
            withdrawn: false
        });

        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    function calculateReward(address staker) public view returns (uint256) {
        Stake storage stakeInfo = stakes[staker];
        require(stakeInfo.amount > 0, "No stake found");

        uint256 stakingDuration = block.timestamp - stakeInfo.startTime;
        uint256 reward = 0;

        if (stakingDuration >= stakingPeriod) {
            reward = (stakeInfo.amount * rewardRate * stakingDuration) / (stakingPeriod * 100);
        }

        return reward;
    }

    function withdraw() external {
        Stake storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount > 0, "No stake found");
        require(!stakeInfo.withdrawn, "Already withdrawn");
        require(block.timestamp >= stakeInfo.startTime + stakingPeriod, "Staking period not yet ended");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = stakeInfo.amount + reward;

        stakeInfo.withdrawn = true;
        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, stakeInfo.amount, reward);
    }

    function withdrawContractBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function setStakingPeriod(uint256 _stakingPeriod) external onlyOwner {
        stakingPeriod = _stakingPeriod;
    }

    receive() external payable {}
}
