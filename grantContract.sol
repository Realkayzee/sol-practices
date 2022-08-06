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

    struct BeneficiaryProperties {
        address BeneficiaryAddress;
        uint AmountAllocated;
        uint timeAllocated;
        Status status;
    }
    uint[] allticketNumber; 
    BeneficiaryProperties[] benefactor;

    //* Mapping

    mapping(uint => BeneficiaryProperties) beneficiaryProperties;



    //* Modifiers
    modifier onlyOwner{
        if (msg.sender != owner){
            revert UserError("Not Owner");
        }

        _;

    }

    modifier lockedTime(uint _ticketNumber){
        BeneficiaryProperties memory benefactor = beneficiaryProperties[_ticketNumber];
        uint AllocatedTime = benefactor.timeAllocated;
        require(block.timestamp > AllocatedTime, "Money still locked");
        _;
    }


    constructor(){
        owner = msg.sender;
    }





    //**********************************Functions************************************/

    function createGrant(address _beneficiary, uint _time) external payable onlyOwner {
        BeneficiaryProperties storage benefactor = beneficiaryProperties[ticketNumber];
        benefactor.BeneficiaryAddress = _beneficiary;
        benefactor.AmountAllocated =  msg.value;
        benefactor.timeAllocated = block.timestamp + (_time * 1 hours); 
        allticketNumber.push(ticketNumber);

        ticketNumber++; 
    }

//* Beneficairy can decide to withdraw part or all the money allocated to him/her
//* Provided the locking period is over
    function beneficiaryWithdraw(uint _ticketNumber, uint _withdrawAmount) external lockedTime(_ticketNumber) {
        BeneficiaryProperties storage benefactor = beneficiaryProperties[_ticketNumber];
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

//* Function for owner to revert grant before timeelapsed
    function revertGrant(uint _ticketNumber) external onlyOwner {
        BeneficiaryProperties storage benefactor = beneficiaryProperties[_ticketNumber];
        uint amount = benefactor.AmountAllocated;
        benefactor.AmountAllocated = 0;
        payable(msg.sender).transfer(amount); // owner revert the total amount allocated for this grant;

    }

//* amount allocated check for beneficiary
    function checkAmountAllocated(uint _ticketNumber) external view returns (uint256 amount){
        BeneficiaryProperties memory benefactor = beneficiaryProperties[_ticketNumber];
        amount = benefactor.AmountAllocated;
    }
//* Check beneficiary properties with a ticketNumber
    function checkBeneficiaryProp(uint _ticketNumber) external view returns(BeneficiaryProperties memory benefactor){
        benefactor = beneficiaryProperties[_ticketNumber];
    }
//* Check all available grant in the contract
    function checkAllBeneficiary() external view returns(BeneficiaryProperties[] memory _benefactor){
        uint[] memory all = allticketNumber;
        _benefactor = new BeneficiaryProperties[](all.length);

        for(uint256 i = 0; i < all.length; i++){
            _benefactor[i] = beneficiaryProperties[all[i]];
        }
    }

}