pragma solidity ^0.4.0;

contract Partnership{
  // A simplified partnership contract where we assume that
  // payments are always made monthly.
  // Contract is initiated when both people submit the first payment.

  public constant uint GRACE_PERIOD_DAYS = 7;

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
      amountPaidA += msg.value;
    } else if( msg.sender == partyB){
      amountPaidB += msg.value;
    } 
    if(effectiveTime == 0 && amountPaidA >= monthlyPaymentA && amountPaidB >= monthlyPaymentB){
      effectiveTime = now;
    }
  }

}