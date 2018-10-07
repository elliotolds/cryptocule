pragma solidity ^0.4.0;

contract Partnership{
  // A simplified partnership contract where we assume that
  // payments are always made every 4 weeks.
  // Contract is initiated when both people submit the first payment.

  uint public constant GRACE_PERIOD_DAYS = 7;
  uint public constant PAYMENT_PERIOD_DAYS = 28;

  bytes32 public agreementHash; 

  address public partyA;
  address public partyB;
  address public arbitrator;

  uint public amountPaidA;
  uint public amountPaidB;

  uint public monthlyPaymentA;
  uint public monthlyPaymentB;

  uint public effectiveTime;
  uint public lateFeePercentage;

  uint public nextPaymentDue;

  bool public nextPaymentPaidA;
  bool public nextPaymentPaidB;

  uint public currentFeeA;
  uint public currentFeeB;

  bool public breachClaimed;
  bool public dissolved; // Has the partnership been disolved? 

  uint public proposedOutcomeA;
  uint public proposedOutcomeB;


  constructor(
      bytes32 _agreementHash,
      address _partyA, 
      address _partyB, 
      address _arbitrator,
      uint _monthlyPaymentA,
      uint _monthlyPaymentB,
      uint _lateFeePercentage) public {
    agreementHash = _agreementHash;  
    partyA = _partyA;
    partyB = _partyB;
    arbitrator = _arbitrator;
    monthlyPaymentA = _monthlyPaymentA;
    monthlyPaymentB = _monthlyPaymentB;
    lateFeePercentage = _lateFeePercentage;
  }

  function deposit() public payable{
    require(!breachClaimed && !dissolved);
    if(msg.sender == partyA){
      require(msg.value == monthlyPaymentA + currentFeeA && !nextPaymentPaidA);
      amountPaidA += monthlyPaymentA;
      if(currentFeeA > 0){
        partyB.transfer(currentFeeA);
      }
      currentFeeA = 0;
      nextPaymentPaidA = true;
    } else if(msg.sender == partyB){
      require(msg.value == monthlyPaymentB + currentFeeB && !nextPaymentPaidB);
      amountPaidB += monthlyPaymentB;
      if(currentFeeB > 0){
        partyA.transfer(currentFeeB);
      }
      currentFeeB = 0;
      nextPaymentPaidB = true;
    } 

    if(nextPaymentPaidA && nextPaymentPaidB){
      nextPaymentPaidA = false;
      nextPaymentPaidB = false;
      if(effectiveTime > 0){
        nextPaymentDue = nextPaymentDue + PAYMENT_PERIOD_DAYS;
      } else{
        effectiveTime = now;
        nextPaymentDue = effectiveTime + PAYMENT_PERIOD_DAYS;  
      }
    }
  }

  function assessFees() public {
    require(!breachClaimed && !dissolved);
    if(now > nextPaymentDue){
      if(!nextPaymentPaidA){
        currentFeeA = (monthlyPaymentA * lateFeePercentage) / 100;
      }
      if(!nextPaymentPaidB){
        currentFeeB = (monthlyPaymentB * lateFeePercentage) / 100;
      }
    }
  }

  function claimBreach() public {
    require(effectiveTime > 0 && !dissolved);
    require(msg.sender == partyA || msg.sender == partyB);

    breachClaimed = true;
  }

  function rule(uint ruling) public{
    require(breachClaimed && !dissolved && msg.sender == arbitrator);
    internalRule(ruling);
  }

  function internalRule(uint ruling) internal{
    if(ruling == 1){
      partyA.transfer(address(this).balance);
    } else if(ruling == 2){
      partyB.transfer(address(this).balance);
    } else if(ruling == 3){
      partyA.transfer(amountPaidA);
      partyB.transfer(amountPaidB);
    } else{
      assert(false);
    }
    dissolved = true;
  }


  function proposeDissolution(uint outcome) public{
    require(!breachClaimed && !dissolved);
    if(msg.sender == partyA){
      proposedOutcomeA = outcome;
      if(proposedOutcomeA == proposedOutcomeB){
        internalRule(proposedOutcomeA);
      }
    } else if(msg.sender == partyB){
      proposedOutcomeB = outcome;
      if(proposedOutcomeA == proposedOutcomeB){
        internalRule(proposedOutcomeA);
      }
    }
  }
}
