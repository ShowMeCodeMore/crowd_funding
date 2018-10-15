pragma solidity ^0.4.17;

contract fundingFactory{
    // 存储所有已经部署的智能合约的地址
    address[] public fundings;

    function deploy(string _projectName,uint _supportMoney,uint _goalMoney,address _address) public{
        address Funding = new funding(_projectName,_supportMoney,_goalMoney,_address);
        fundings.push(Funding);
    }

}