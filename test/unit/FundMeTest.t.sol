// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address FUNDER = makeAddr("funder");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant START_BALANCE = 10 ether;  

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        // arrange

        //act/assert
        vm.expectRevert();
        fundMe.fund();        
    }

    function testFundUpdatesFundedDataStructure() public {
        // arrange              
        vm.prank(FUNDER);
        vm.deal(FUNDER, START_BALANCE);

        // act
        fundMe.fund{value: SEND_VALUE}();

        // assert
        assertEq(FUNDER, fundMe.getFunder(0));
        assertEq(SEND_VALUE, fundMe.getAddressToAmountFunded(FUNDER));

    }
    
    /**
     * Start the test with a funded contract.
     */
    modifier funded() {
        vm.prank(FUNDER);
        vm.deal(FUNDER, START_BALANCE);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }


    function testWithdrawOnlyOwnerCanWithdraw() public funded {
        
        // arrange
        vm.prank(FUNDER);

        //act/assert
        vm.expectRevert();
        fundMe.withdraw();

    }

    function testWithdrawWithSingleFunderPaysContractBalanceAndUpdatesDataStructure() public funded {
        
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 topFundMeBalance = address(fundMe).balance;
        address contractOwner = fundMe.getOwner();
        vm.prank(contractOwner);
        

        // act - WD
        fundMe.withdraw();

        // assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);        
        assertEq(startingOwnerBalance + topFundMeBalance, endingOwnerBalance);

    }

    function testWithdrawWithManyFunderPaysContractBalanceAndUpdatesDataStructure() public {

        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;        

        // address(index) from solidity ^0.8 requires index to be of type uint160 !
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // to avoid the address(0) call
        for (uint160 index = startingFunderIndex; index == numberOfFunders; index++) {
            hoax(address(index), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 topFundMeBalance = address(fundMe).balance;

        address contractOwner = fundMe.getOwner();
        vm.prank(contractOwner);

        // act
        fundMe.withdraw();

        // assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(topFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

}