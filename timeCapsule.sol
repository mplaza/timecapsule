pragma solidity ^0.4.18;

// This is an Ethereum time capsule.
// You can stash tokens in here. Also, use this contract to record life events, thoughts at a moment in time, or anything you might want to provably leave on the blockchain.
// Your grandkids can look through the blockchain one day and find your history in it.
// This contract and contents are meant to be publicly viewed. Keep that in mind when you're adding to it!

// Made by DJ and MP.

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract timeCapsule  {

    // Contract events:
    event AddedThought(string thought);
    event SetName(string name);
    event CreatedStash(uint256 index);
	event OpenedStash(uint256 index);

    Thought[] public thoughts;
    mapping (address => string) public names;
    TokenStash[] public stashes;

    // Statuses of TokenStashes
    uint256 ACTIVE_STATUS;
    uint256 COMPLETED_STATUS;

    struct Thought	{
    	address thinker;
    	string thought;
    }

    // Information about a token stash.
    struct TokenStash	{
    	uint256 amount;
    	uint256 status;
    	uint256 duration;
    	uint256 startTime;
    	address tokenAddress;
    	address owner;
    	string message;
    }

    function timeCapsule()  {
        // Set statuses to be unique
        ACTIVE_STATUS=1;
    	COMPLETED_STATUS=2;
    }

    // Any time you want to add a thought, upload it here!
    function holdThatThought(string thoughtToKeep)    {
       	Thought memory newThought=Thought(msg.sender,thoughtToKeep);
        AddedThought(thoughtToKeep);
        thoughts.push(newThought);
    }

    // Add your name if you want!
    function setName(string name)    {
        names[msg.sender]=name;
        SetName(name);
    }

    // Let's put some tokens in the time capsule! Maybe stash something for your grandkids?
    // Make sure you use the ERC20 standard Approve(...) function to approve the transferFrom(...) in this function!
    function stashForLater(uint256 amount,uint256 duration,address tokenAddress,string message) public   {
        address owner=msg.sender;
        // Create a new TokenStash
        TokenStash memory newStash=TokenStash(amount,ACTIVE_STATUS,duration,block.number,tokenAddress,owner,message);
        stashes.push(newStash);
        uint256 index=stashes.length-1;
        // Log the event
		CreatedStash(index);
        // Verify that this contract was able to move amount from tokenAddress.
        if (!token(stashes[index].tokenAddress).transferFrom(msg.sender,address(this),amount)) revert(); // Transfer the investment to this contract; revert if there's failure.
    }

    // When the wait is over, take them out of the time capsule!
    function openSesame(uint256 index) public {
        require(stashes[index].status==ACTIVE_STATUS);
        require(block.number>=SafeMath.add(stashes[index].startTime,stashes[index].duration));
		require(stashes[index].owner==msg.sender);
        // Change the status to completed.
        stashes[index].status=COMPLETED_STATUS;
        // Log the event.
        OpenedStash(index);
        // Transfer the contents of the stash back to the original owner
        uint256 transferAmount=stashes[index].amount;
        if (!token(stashes[index].tokenAddress).transfer(msg.sender,transferAmount)) revert();
    }

}

// Interface with standard ERC tokens.
contract token	{
	function transfer(address _to, uint256 _amount) returns (bool success);
	function transferFrom(address _from,address _to,uint256 _amount) returns (bool success);
}
