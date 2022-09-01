// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;
import "./LibCast.sol";


contract Cast{

  Workers public aw;
using Arithmetic for uint;
using Arithmetic for Workers;

uint tem;

mapping(uint=>Workers) workers;



mapping(uint=>mapping(uint=>mapping(string=>bytes32))) Wahala;
function checkAdd(uint256 b) public view returns(uint256){

    return tem.add(b);
}

function setStruct(uint8 _c,string memory _n,uint256 id) public {
  //make this work
  
  
  aw.constructStruct(_c,_n,id,workers);

}

function see(uint id) public view returns(Workers memory){
return workers[id];
}
}