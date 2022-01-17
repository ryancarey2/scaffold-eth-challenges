// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping (address => uint256) public balances; //Deposit Balance Tracking
  uint256 public constant threshold = 1 ether; //Fundraining threshold
  uint256 public deadline = block.timestamp + 72 hours; //Deadline for Fundraising threshold to be reached
  bool public openForWithdraw = false;

  event Stake(address _staker, uint256 _deposit); 

  modifier notCompleted() {
    require(exampleExternalContract.completed() == false);
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require (block.timestamp <= deadline, "Past Deadline");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, balances[msg.sender]);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    require(block.timestamp > deadline, "Deadline not met");
    require(openForWithdraw == false, "Already open for Withdraw");
    if(address(this).balance >= threshold){
      // transfer contract balance
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      openForWithdraw = true;
    }
  }

  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw(address payable _to) public notCompleted {
    require(openForWithdraw, "Not Open for Withdraw");
    require(balances[msg.sender] > 0, "No Balance");
    uint256 bal = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool sent, ) = _to.call{value: bal}("");
    require(sent, "Failed to send Ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
     if(block.timestamp >= deadline) {
       return 0;
     } else {
       return deadline - block.timestamp;
     }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}