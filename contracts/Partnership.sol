pragma solidity ^0.4.0;

contract Partnership{
  // A simplified partnership contract where we assume that
  // payments are always made every 4 weeks.
  // Contract is initiated when both people submit the first payment.

  public constant uint GRACE_PERIOD_DAYS = 7;
  public constant uint PAYMENT_PERIOD_DAYS = 28;

  public bytes32 agreementHash; 

  public address partyA;
  public address partyB;
  public address arbitrator;

  public uint amountPaidA;
  public uint amountPaidB;

  public uint monthlyPaymentA;
  public uint monthlyPaymentB;

  public uint numPaymentsA;
  public uint numPaymentsB;

  public uint effectiveTime;
  public uint lateFeePercentage;

  public uint nextPaymentDue;

  public bool nextPaymentPaidA;
  public bool nextPaymentPaidB;

  public bool currentFeeA;
  public bool currentFeeB;


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
    if(msg.sender == partyA){
      require(msg.value == monthlyPaymentA + currentFeeA && !nextPaymentPaidA);
      amountPaidA += msg.value;
      if(currentFeeA > 0){
        partyB.transfer(currentFeeA);
      }
      currentFeeA = 0;
      nextPaymentPaidA = true;
    } else if( msg.sender == partyB){
      require(msg.value == monthlyPaymentB + currentFeeB && !nextPaymentPaidB);
      amountPaidB += msg.value;
      if(currentFeeB > 0){
        partyA.transfer(currentFeeB);
      }
      currentFeeB = 0;
      nextPaymentPaidB = true;
    } 
    if(effectiveTime == 0 && nextPaymentPaidA && nextPaymentPaidB){
      effectiveTime = now;
      nextPaymentDue = effectiveTime + PAYMENT_PERIOD_DAYS;
      nextPaymentPaidA = false;
      nextPaymentPaidB = false;
    } else if( nextPaymentPaidA && nextPaymentPaidB ){
      nextPaymentDue = nextPaymentDue + PAYMENT_PERIOD_DAYS;
      nextPaymentPaidA = false;
      nextPaymentPaidB = false;
    }
  }
}