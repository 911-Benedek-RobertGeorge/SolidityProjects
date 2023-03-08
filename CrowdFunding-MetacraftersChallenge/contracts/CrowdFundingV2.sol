//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 < 0.9.0; /// greater than 0.8.0 to avoid overflows
import './BenBurgerToken.sol';
 
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
 
contract CrowdFundingV2 is Initializable {
    mapping(address => uint) public contributors;
    address public admin;
    uint public nrOfContributors;
    uint public minimumContribution;
    uint public deadline;  // timestamp
    uint public goal;
    uint public raisedAmount;

    IERC20 public token;
   
    

    /// a request for a funding 
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint nrOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests; // we can only use mappings to store something like an array of structs
    
    uint public numRequests;

    modifier onlyAdmin(){
        require(msg.sender == admin,"Only admin is allowed to do this!");
        _;
    }

    // events for future development of frontend
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymenEvent(address _recipient, uint _value);

    function initialize(uint _goal, uint _deadline,uint _minimumContribution, address payable _token ) public initializer {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = _minimumContribution ;
        admin = msg.sender;
        token = BenBurgerToken(_token) ;
   } 

    //V2 function
    function changeMinimumContribution(uint _minimumContribution) public onlyAdmin{
      minimumContribution = _minimumContribution;
    }

    receive() payable external{
       contribute(msg.value);
    }

    function contribute(uint _amount) public {
        require(block.timestamp < deadline, "Deadline has passed!");
        require(_amount >= minimumContribution, "Minimum Contribution not met!");
        require(token.allowance(msg.sender,address(this)) >= _amount,  "the contract is not allowed to get this amount from the user");
       
        require(token.transferFrom(msg.sender,address(this),_amount), "The transfer did not succeded."); // sending the tokens to the admin address 

        if(contributors[msg.sender] == 0){ // we only want the different address contributors
            nrOfContributors++;
        }

        contributors[msg.sender] += _amount;
        raisedAmount += _amount;
        
        
        emit ContributeEvent(msg.sender, _amount);
    }
    
    /// Get the custom token balance of the contract
    function getBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }

    function getRefund() public {
        //require(block.timestamp > deadline,"You cant get a refund until the deadline has passed!");
        //require(raisedAmount < goal ,"Fotunatelly the goal has been reached. Thank you for doing good!");
        //require(value > 0,"You dont have anything to withdraw!");

        uint value = contributors[msg.sender];
        if(block.timestamp < deadline || raisedAmount >= goal || value < 0){
            revert("Not eligible for a refund!");
        }   
        token.transfer(payable(msg.sender),value);
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
            
            token.transfer( thisRequest.recipient, thisRequest.value);
            thisRequest.completed = true;

        emit MakePaymenEvent(thisRequest.recipient,thisRequest.value);  
        }else{
            revert("The payment failed!");
        }
        
    }
}
 