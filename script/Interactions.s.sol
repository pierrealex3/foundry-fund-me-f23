// SPDX-License-Identifier: MIT
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

pragma solidity ^0.8.18;

// Fund
// Withdraw

// here we want to fund our most recently deployed contract
contract FundFundMe is Script {

    uint256 SEND_VALUE = 0.01 ether;

    /**
     * Call the fund function on the most recently deployed contract on the target chain.
     * Note: we do NOT deploy the contract, we do interact with a deployed contract.
     */
    function fundFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();  
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();       
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }


}

contract WithdrawFundMe is Script {

    function withdrawFundMe(address mostRecentDeployed) public {  
        vm.startBroadcast();      
        FundMe(payable(mostRecentDeployed)).withdraw();       
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }


}