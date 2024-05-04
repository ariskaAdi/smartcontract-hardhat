// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ReentrancyGuard.sol";

contract crowdfunding is ReentrancyGuard {
    address private  immutable owner; 
    uint256 public minimumContribution;
    uint256 public totalContribution;
    uint256 public targetGoal;
    bool private stopped = false;


    mapping (address => uint256) public contributions;

    event DonationReceived(address backer, uint256 amount);
    event FundsWithdrawn(address owner, uint256 amount);


    constructor(){
       owner = msg.sender;
        minimumContribution = 1000000000000000 wei;
        targetGoal = 100 ether;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "only the owner can call this function");
        _;
    }

    modifier stopInEmergency { require(!stopped, "Contract is stopped"); _; }

    


   function donate() public payable nonReentrant  stopInEmergency{
        require(msg.value >= minimumContribution, "Donation below minimum standart contribution");

        contributions[msg.sender] += msg.value;
        totalContribution += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    function withdraw() public nonReentrant onlyOwner  {
    uint256 amount = address(this).balance;
    require(amount > 0, "No funds to withdraw");

     emit FundsWithdrawn(owner, amount);

    (bool sent, ) = owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
}
   
    function toggleCircuitBreaker() external onlyOwner {
    stopped = !stopped;
}
}