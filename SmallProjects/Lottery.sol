//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address  payable public manager; 

    constructor(){
        manager = payable( msg.sender);
        players.push(manager);
    }
    receive () external payable{
        require(msg.sender != manager,"You are the maneger, you cant participate!");
        require(msg.value == 0.1 ether,"You have to send exactly 0.1 eth to participate to the lottery");
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(manager == msg.sender, "You are not the manager, so you cant see the balance");
        return address(this).balance;
    }

     function random() public view returns(uint){
         return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
     }
    
    function pickWinner () public  {

        require(msg.sender == manager || players.length >= 10);
        require(players.length >= 3);
        uint r = random();
        address payable winner;
        uint index = r % players.length;
        winner = players[index];
        uint procentage = uint(getBalance() / 10);
        uint toBePaid = getBalance() - procentage;
        winner.transfer(toBePaid);
        manager.transfer(procentage);
        players = new address payable[](0);
        players.push(manager);
        }
  
}