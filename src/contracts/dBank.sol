// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Token.sol";

contract dBank {

  //assign Token contract to variable
  Token private token;
  
  //MAPPINGS
  //R Stores ether balance of each address
  mapping(address => uint) public etherBalanceOf;
  //R Stores start block # of deposit (for calculating interest time)
  mapping(address => uint) public depositStart;
  //R Deposit status
  mapping(address => bool) public isDeposited;
  
  //add events
  //R Deposit event
  event Deposit(address indexed user, uint etherAmount, uint timeStart);
  //R Withdraw event
  event Withdraw(address indexed user, uint etherAmount, uint depositTime, uint interest);

  //pass as constructor argument deployed Token contract
  constructor(Token _token) {
    //assign token deployed contract to variable
    token = _token;
  }

  function deposit() payable public {
    //check if msg.sender didn't already deposited funds
    require(isDeposited[msg.sender] == false, 'Error, deposit already active');
    //check if msg.value is >= than 0.01 ETH
    require(msg.value>=1e16, 'Error, deposit must be >= 0.01 ETH');
    
    //R Increase the balance of the msg sending user with the sent value
    etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] + msg.value;
    
    //start msg.sender hodling time
    depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;

    //set msg.sender deposit status to true
    isDeposited[msg.sender] = true;
    //emit Deposit event
    emit Deposit(msg.sender, msg.value, block.timestamp);
  }

  function withdraw() public {
    //check if msg.sender deposit status is true
    require(isDeposited[msg.sender]==true, 'Error, no previous deposit');
    //assign msg.sender ether deposit balance to variable for event
    uint userBalance = etherBalanceOf[msg.sender];

    //check user's hodl time
    uint depositTime = block.timestamp - depositStart[msg.sender];

    //R Calculate interest    
    //31668017 - interest(10% APY) per second for min. deposit amount (0.01 ETH)
    //1e15(10% of 0.01 ETH) / 31577600 (seconds in 365.25 days)

    uint interestPerSecond = 31668017 * (userBalance / 1e16);
    uint interest = interestPerSecond * depositTime;

    //send eth back to user
    msg.sender.transfer(userBalance);
    //send interest in tokens to user
    token.mint(msg.sender, interest);
    //reset depositer data
    depositStart[msg.sender] = 0;
    etherBalanceOf[msg.sender] = 0;
    isDeposited[msg.sender] = false;
    //emit event
    emit Withdraw(msg.sender, userBalance, depositTime, interest);
  }

  function borrow() payable public {
    //check if collateral is >= than 0.01 ETH
    //check if user doesn't have active loan

    //add msg.value to ether collateral

    //calc tokens amount to mint, 50% of msg.value

    //mint&send tokens to user

    //activate borrower's loan status

    //emit event
  }

  function payOff() public {
    //check if loan is active
    //transfer tokens from user back to the contract

    //calc fee

    //send user's collateral minus fee

    //reset borrower's data

    //emit event
  }
}