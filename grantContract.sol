// SPDX-License-Identifier: GPL-3.0;


pragma solidity 0.8.7;


/// @title A Grant Contract
/// @author Kayzee
/// @notice Only owner can give grant to beneficiary
/// @notice For security check the grant is locked for a while before a benefeciary can withdraw 
/// @notice Owner of the grant have access to revert the grant before locked period elapsed
/// @notice Beneficiary can see the amount allocated before specifying amount to withdraw
/// @notice Owner can check the history of all grants
/// @notice Status of the grant is specified

contract Grant{

    //**********************************State Variables***********************************/

    address owner;
    // A unique id declaration for every contract created
    uint ticketNumber = 1;
    error UserError(string); // Custom error

    //* Events
    event _createGrant(address benefactor, uint256 allocatedTime, uint amountAllocated);
    event _withdraw(uint256 amountInGrant, uint256 amountToWithdraw);
    event _revert(uint256 revertTicket);
    


    //* Structs

    struct BeneficiaryProperties {
        address BeneficiaryAddress;
        uint AmountAllocated;
        uint timeAllocated;
        bool grantCreated;
        bool grantrevert;
    }
    uint[] allticketNumber; 
    BeneficiaryProperties[] _benefactor;

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
        require(_beneficiary != address(0)); // sanity check
        BeneficiaryProperties storage benefactor = beneficiaryProperties[ticketNumber];
        benefactor.BeneficiaryAddress = _beneficiary;
        benefactor.AmountAllocated =  msg.value;
        benefactor.timeAllocated = block.timestamp + (_time * 1 hours); 
        benefactor.grantCreated = true;
        allticketNumber.push(ticketNumber);

        emit _createGrant(_beneficiary, benefactor.timeAllocated, benefactor.AmountAllocated);

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
            revert UserError("You have no money in your grant");
        }
        if(_withdrawAmount > amount){
            revert UserError("Amount Specified is greater than amount in grant");
        }
        benefactor.AmountAllocated -= _withdrawAmount;

        payable(user).transfer(_withdrawAmount);

        emit _withdraw(amount, _withdrawAmount);

    }

//* Function for owner to revert grant before timeelapsed
    function revertGrant(uint _ticketNumber) external onlyOwner {
        BeneficiaryProperties storage benefactor = beneficiaryProperties[_ticketNumber];
        uint amount = benefactor.AmountAllocated;
        if(amount == 0){
            revert UserError("No money Allocated for this grant");
        }
        benefactor.AmountAllocated = 0;
        benefactor.grantrevert = true;
        payable(msg.sender).transfer(amount); // owner revert the total amount allocated for this grant;

        emit _revert(_ticketNumber);
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
    function checkAllBeneficiary() external view returns(BeneficiaryProperties[] memory benefactor){
        uint[] memory all = allticketNumber;
        benefactor = new BeneficiaryProperties[](all.length);

        for(uint256 i = 0; i < all.length; i++){
            benefactor[i] = beneficiaryProperties[all[i]];
        }
    }

}