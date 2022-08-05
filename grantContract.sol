// SPDX-License-Identifier: GPL-3.0;


pragma solidity 0.8.7;

//* A Contract where only owner gives grant to beneficiary
//* For security check the grant is locked for a while before a benefeciary can withdraw 
//* Owner of the grant have access to revert the grant before locked period elapsed
//* Beneficiary can see the amount allocated before specifying amount to withdraw
//* Owner can check the history of all grants
//* Status of the grant is specified

contract Grant{

    //**********************************State Variables***********************************/

    address owner;
    // A unique id declaration for every contract created
    uint ticketNumber = 1;
    enum Status{
        grantCreated,
        grantWithdraen,
        grantPartlyWithdrawn, 
        grantCancelled
    }
    error UserError(string);
    


    //* Structs

    struct BenefeciaryProperties {
        address BeneficiaryAddress;
        uint AmountAllocated;
        uint timeAllocated;
        Status status;
    }

    //* Mapping

    mapping(uint => BenefeciaryProperties) beneficiaryProperties;



    //* Modifiers
    modifier onlyOwner{
        if (msg.sender != owner){
            revert UserError("Not Owner");
        }

        _;

    }


    constructor(){
        owner = msg.sender;
    }





    //**********************************Functions************************************/

    function createGrant(address _beneficiary, uint _time) external payable onlyOwner {
        BenefeciaryProperties storage benefactor = beneficiaryProperties[ticketNumber];
        benefactor.BeneficiaryAddress = _beneficiary;
        benefactor.AmountAllocated =  msg.value;
        benefactor.timeAllocated = block.timestamp + (_time * 1 hours); 


        ticketNumber++; 
    }

//* Beneficairy can decide to withdraw part or all the money allocated to him/her
    function beneficiaryWithdraw(uint _ticketNumber, uint _withdrawAmount) external {
        BenefeciaryProperties storage benefactor = beneficiaryProperties[_ticketNumber];
        address user = benefactor.BeneficiaryAddress;
        if(user != msg.sender){
            revert UserError("You are not a benefactor");
        }
        uint amount = benefactor.AmountAllocated;
        if(amount < 0){
            revert UserError("You have no money");
        }
        if(_withdrawAmount > amount){
            revert UserError("Insufficient Balance");
        }
        benefactor.AmountAllocated -= _withdrawAmount;

        payable(user).transfer(_withdrawAmount);

    }

}