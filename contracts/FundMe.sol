//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../libraries/PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    
    constructor(){
        i_owner =  msg.sender;
    }

    function fund() public payable {
        require(msg.value.getCoversionRate() >= MINIMUM_USD, "Error: Minimum deposit 50USD");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }
    
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){ // for(starting index; ending index; step amount)
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // reset array
        
        // payable(msg.sender).transfer(address().balance); //withdraw fund
        // bool sendSuccess =  payable(msg.sender).send(address().balance);
        // require(sendSuccess, "Send failed");

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");


    }

    modifier onlyOwner{
        if(msg.sender != i_owner){revert NotOwner(); }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}