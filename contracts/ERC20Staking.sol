// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC20Staking is Ownable {
    using SafeMath for uint256;

    // ERC20 token to be staked
    IERC20 public stakingToken;

    // Reward rate per second
    uint256 public rewardRate;

    // Staking period in seconds
    uint256 public stakingPeriod;

    // Information about each stake
    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool withdrawn;
    }

    // Mapping of user address to their stake
    mapping(address => Stake) public stakes;

    // Events
    event Staked(address indexed user, uint256 amount, uint256 startTime);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    // Constructor
    constructor(IERC20 _stakingToken, uint256 _rewardRate, uint256 _stakingPeriod) {
        stakingToken = _stakingToken;
        rewardRate = _rewardRate;
        stakingPeriod = _stakingPeriod;
    }

    // Function to stake tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        Stake storage stake = stakes[msg.sender];
        require(stake.amount == 0, "Already staking");

        stake.amount = _amount;
        stake.startTime = block.timestamp;
        stake.withdrawn = false;

        emit Staked(msg.sender, _amount, stake.startTime);
    }

    // Function to withdraw staked tokens and rewards
    function withdraw() external {
        Stake storage stake = stakes[msg.sender];
        require(stake.amount > 0, "No stake found");
        require(!stake.withdrawn, "Already withdrawn");
        require(block.timestamp >= stake.startTime + stakingPeriod, "Staking period not yet ended");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = stake.amount.add(reward);

        stake.withdrawn = true;

        require(stakingToken.transfer(msg.sender, stake.amount), "Transfer failed");
        require(stakingToken.transfer(msg.sender, reward), "Reward transfer failed");

        emit Withdrawn(msg.sender, stake.amount, reward);
    }

    // Function to calculate reward based on staking duration
    function calculateReward(address _user) public view returns (uint256) {
        Stake memory stake = stakes[_user];
        if (stake.amount == 0 || block.timestamp < stake.startTime + stakingPeriod) {
            return 0;
        }
        uint256 stakingDuration = block.timestamp.sub(stake.startTime);
        return stake.amount.mul(rewardRate).mul(stakingDuration).div(1e18); // assuming rewardRate is in 1e18
    }

    // Function to set reward rate
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    // Function to set staking period
    function setStakingPeriod(uint256 _stakingPeriod) external onlyOwner {
        stakingPeriod = _stakingPeriod;
    }

    // Function to withdraw contract balance (not used in this case, but available)
    function withdrawContractBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
