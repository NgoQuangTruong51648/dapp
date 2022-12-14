pragma solidity ^0.5.13;

contract MappingStruct{

    struct Payment{
        uint amount;
        uint timestamps;
    }

    struct balance{
        uint totalBalance;
        uint numPayment;
        mapping(uint => Payment) payments;
    }  


    mapping(address => balance) public balanceReceived;

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function sendMoney()public payable{
        balanceReceived[msg.sender].totalBalance +=msg.value;

        Payment memory payments = Payment(msg.value, now);
        balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayment] = payments;
        balanceReceived[msg.sender].numPayment++;
    }

    function withdrawMoney(address payable _to, uint _amount) public{
        require(balanceReceived[msg.sender].totalBalance >= _amount, "Số dư không đủ");
        balanceReceived[msg.sender].totalBalance -= _amount;
        _to.transfer(_amount);
    }

    function withdrawAllMoney(address payable _to)public{
        uint balanceToSend = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance=0;
        _to.transfer(balanceToSend);
    }
}