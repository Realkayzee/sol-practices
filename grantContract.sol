// SPDX-License-Identifier: GPL-3.0;


pragma solidity 0.8.7;

//* A Contract where only owner gives grant to beneficiary
//* The beneficiary address must be an EOA address (not a contract address)
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
        benefactor.timeAllocated = block.timestamp + _time;  
    }



}