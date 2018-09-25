pragma solidity ^0.4.22;

contract test{
    uint a=100;
    function getMessage() public view returns(uint data){
        return a;
    }

    function getMessage1() public pure returns(uint data){
        return data=0;
    }
}