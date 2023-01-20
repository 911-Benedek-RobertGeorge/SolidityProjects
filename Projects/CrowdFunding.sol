//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

/* 
    Dont get caught in a crowd funding scam!!! 

    This smart contract has the role of stopping the administrator of a crowd funding 
    to run with your money or to use them in their personal advantage.

    The person who deploys the contract can choose the goal it want to obtain and a deadline,
    but he is not going to be able to withdraw the money because they are kept in the smart contract
    until the contributos have decided where their money would help the most.

    It has a few steps : 
        - after deploying the administrator make a request of a crowd funding where he has to 
        provide a description of how those money are going to be used, the address where the 
        money are going to be sent to and the amount that will be allocated to that cause.
        -the contributor can now send money to the smart contract and the ether is going to be
        stored in the smart contract until something has been decided
        - the contributor have the option to vote for some of the request  and only the requests
        voted by more than 50% of contributors are going to be proccessed and the money send to 
        the recipient address only if the goal has been achived
        - if the deadline passed and the goal was not achived , everybody can request their money back

*/


contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public nrOfContributors;
    uint public minimumContribution;
    uint public deadline;  // timestamp
    uint public goal;
    uint public raisedAmount;

    /// a request for a funding 
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint nrOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests; // we only can use mappings to store something like an array of structs
    uint public numRequests;

     modifier onlyAdmin(){
        require(msg.sender == admin,"Only admin is allowed do this!");
        _;
    }

    // events for future development of frontend
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymenEvent(address _recipient, uint _value);

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 1000000 gwei ; // 0.001 eth
        admin = msg.sender;
    }

    receive() payable external{
        contribute();
    }

    function contribute() public payable{
        require(block.timestamp < deadline, "Deadline has passed!");
        require(msg.value >= minimumContribution, "Minimum Contribution not met!");
        
        if(contributors[msg.sender] == 0){ // we only want the different address contributors
            nrOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit ContributeEvent(msg.sender, msg.value);
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public {
        //require(block.timestamp > deadline,"You cant get a refund until the deadline has passed!");
        //require(raisedAmount < goal ,"Fotunatelly the goal has been reached. Thank you for doing good!");
        //require(value > 0,"You dont have anything to withdraw!");

        uint value = contributors[msg.sender];
        if(block.timestamp < deadline || raisedAmount >= goal || value < 0){
            revert("Not eligible for a refund!");
        }

        payable(msg.sender).transfer(value);
        contributors[msg.sender] = 0;

    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.nrOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient,_value);
    }

    function voteRequest(uint _requestNo) public {
        assert(contributors[msg.sender] > 0 );
        Request storage thisRequest = requests[_requestNo];
        require (thisRequest.voters[msg.sender] == false,"You have already voted!");
        thisRequest.voters[msg.sender] = true;
        thisRequest.nrOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyAdmin{
        //require(raisedAmount >= goal,"Goal not met yet!");
        //require(thisRequest.completed == false,"The request has been completed!");
        if(raisedAmount >= goal && requests[_requestNo].completed == false){
            Request storage thisRequest = requests[_requestNo];
            require(thisRequest.nrOfVoters > nrOfContributors / 2); // > 50% of contributors

            thisRequest.recipient.transfer(thisRequest.value);
            thisRequest.completed = true;

        emit MakePaymenEvent(thisRequest.recipient,thisRequest.value);  
        }else{
            revert();
        }
        
    }
}