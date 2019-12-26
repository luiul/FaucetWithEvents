pragma solidity ^0.5.10;

// parent contract that assigns contract creator as owner and defines the modifier onlyOwner for functions that are meant only for the owner of the contract
contract ContractWithOwner {
  address payable owner;

  constructor() public { owner = msg.sender; }

  modifier onlyOwner {
    require(msg.sender == owner,'Only contract owner can call this function');
    _;
  }
}

// destructible contract inherents from contract with owner and define a self-destruct function
contract DestructibleContract is ContractWithOwner {
  function destruct() public onlyOwner {
    selfdestruct(owner);
  }
}

// owned, destructible contract that transfer a maximal amounf of one Ether when withdraw function is called and accepts incoming funds if no function is called
contract ImprovedFacet is DestructibleContract {
  // events to log deposits to and withdrawal from the contract
  event Deposit(address indexed fromAccount, uint depositAmount);
  event Withdrawal(address indexed toAccount, uint withdrawalAmount);

  function withdraw(uint requestedAmount) public {
    require(requestedAmount <= 1 ether, 'The requested amount exceeds 1 Ether');

    // return an error message in case the balance is insufficient; remove this statement for a more gas-efficient contract
    require(address(this).balance>=requestedAmount, 'Insufficent balance for requested withdrawal');

    msg.sender.transfer(requestedAmount);
    emit Withdrawal(msg.sender, requestedAmount);
  }

  function () external payable {
    emit Deposit(msg.sender, msg.value);
  }
}