pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 _amountTokens) public {
    uint256 amountOfETH = _amountTokens / tokensPerEth;
    require(address(this).balance >= amountOfETH, "Vendor does not have enough ETH for this sale");
    yourToken.transferFrom(msg.sender, address(this), _amountTokens);
    (bool sent,) = msg.sender.call{value: amountOfETH}("");
    require(sent, "Failed to send Ether");
    emit SellTokens(msg.sender, amountOfETH, _amountTokens);
  }

}
