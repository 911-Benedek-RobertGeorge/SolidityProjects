//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0; // handles the overflow 
 

 
interface  IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract BenBurgerToken is IERC20 {
 
    uint public supply;
    address payable public  founder;
    uint tokenPrice = 0.001 ether; 
    uint public hardCap = 300 ether;
    uint public raisedAmount = 0;



    mapping (address => uint) public balances;

    mapping (address => mapping(address => uint)) allowed;

    //  0x111... (owner) allows 0x222... (the spender) --- 100 tokens;
    // allowed[0x111...][0x222...] = 100;

    constructor()  {    
        supply = 1000000;
        founder = payable(msg.sender);
        balances[founder] = supply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }
     function decimals() public view virtual returns (uint8){
         return 10;

     }
    function symbol() public view virtual returns (string memory) {
        return "BBT";
    }
    function name() public view virtual returns (string memory) {
        return "BenBurgerToken";
    }
    function totalSupply() public view virtual override returns (uint256) {
            return supply;
        }
    function transfer(address to, uint tokens) public virtual override returns (bool success){
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;

        emit Transfer(msg.sender,to,tokens);
        
        return true;
    }

    function allowance(address tokenOwner, address spender) view public override returns (uint){
        return allowed[tokenOwner][spender];
    }


    function approve(address spender, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;      
    }


    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){

        require(allowed[from][to] >= tokens, "You cant take the tokens form another wallet if not allowed.");
        require(balances[from] >= tokens, "Not enough balance");
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    event Invest(address investor, uint value, uint tokens);

    function invest(uint value) payable public returns(bool){
        
        //require(msg.value >= minInvestment && msg.value <= maxInvestment , "Investement not in range");
        raisedAmount += value;
        require(raisedAmount <= hardCap);
      
        uint tokens = value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        founder.transfer(value);

        emit Invest(msg.sender, value, tokens);

        return true;
    }

    receive() payable external{
        invest(msg.value);
    }
}
 