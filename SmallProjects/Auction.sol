//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


contract AuctionCreator{  //Creator contract so we can have more auctions at once
    Auction[] public auctions;

    function createAuction() public{
        Auction newAuction = new Auction( msg.sender);
        auctions.push(newAuction);
    }
}
contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    enum State{Started, Running, Ended, Canceled}
     State public auctionState;

     uint public highestBindingBid;
     address payable public highestBidder;

     mapping(address => uint) public bids;
     uint bidIncrement;

    constructor(address eoa){
        owner = payable(eoa);
        auctionState = State.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320 ; // an auction last for a week because a block needs 15 sec and 15*40320 is a week
        ipfsHash = "";
        bidIncrement = 1000000 gwei;
    }

    modifier notOwner(){
        require(msg.sender != owner,"You are the owner, you cant participate...");
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock,"Block number is wrong");
        _;
    }
    modifier beforeEnd(){
        require(block.number <= endBlock,"The auction has ended!");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"You are not the owner!");
        _;
    }
    function min(uint a, uint b )  pure internal returns(uint){
        if(a <= b){
            return a;
        }
        else{
            return b;
        }
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd{
        require (auctionState == State.Running,"The auction is not running anymore");
        require(msg.value >= 100000 gwei, "The smallest amount to bid is 0.0001 eth"); /// >= 0.0001 eth
        
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid, "It already is a bigger bid than yours");

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement,bids[highestBidder]);
        }
        else{
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    } 

    function finalizeAuction () public{
        require(auctionState == State.Canceled || block.number > endBlock,"The auction has to be canceled or to be ended");
        
        require(msg.sender == owner || bids[msg.sender] > 0, "You didnt participate to the auction or you already  withdrawed ");

        address payable recipient;
        uint value;

        if(auctionState == State.Canceled){ // auction was canceled
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else{ //auction ended (not canceled)

            if(msg.sender == owner && auctionState != State.Ended){
                recipient = owner;
                value = highestBindingBid;
                auctionState = State.Ended; // we change this variable so the owner cant withdraw multiple times
            }else{
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                     
                }else{  //addresses which have put bids
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                     
                }
            }
        }
        //reseting the bids of the recipient to 0 so he cant take multiple times the eth
        bids[recipient] = 0;
         
        recipient.transfer(value);
    }
}