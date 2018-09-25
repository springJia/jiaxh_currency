//新增投票账户提现功能

pragma solidity ^0.4.22;

//枚举常量：默认值0，1，2
//Register: 服务已创建，所有者现在可以添加选民。
//Vote: 所有选民投票。
//Disperse: 投票付款被分给大多数参与者
//用户体现
contract TruthVote {
    enum States {
        REGISTER,
        VOTE,
        DISPERSE,
        WITHDRAW
    }
  address public owner = msg.sender;
  address[] true_votes;
  address[] false_votes;
  mapping (address => bool) voters;
  mapping (address => bool) hasVoted;
  address[] winningGroup;
  uint winningCompensation;
  uint VOTE_COST = 100;

  States _state;

  event hasVotedRecord(address indexed from,bool flag);
 event hastates(States _state);
  modifier onlyOwner() {
      require(msg.sender == owner);
       _;
    }

  modifier onlyVoter() {
      require(voters[msg.sender] != false);
       _;
   }

   modifier hasNotVoted() {
      require(hasVoted[msg.sender] == false);
        _;
   }

     modifier isCurrentState(States _stage) {
      require(_state==_stage);
       _;
   }

   function startVote() public onlyOwner() isCurrentState(States.REGISTER){
        goToNextState();
    }

    function goToNextState() internal {
        _state = States(uint(_state) + 1);
    }

    modifier pretransition() {
        goToNextState();
        _;
    }

    modifier posttransition() {
        _;
        goToNextState();
    }

   function addVoter(address voterAddress) public onlyOwner(){
       emit hastates(_state);
       voters[voterAddress]=true;
   }

   //payable 可以调用此方法发送发送发送e t h
   function vote(bool val) public payable isCurrentState(States.VOTE) onlyVoter() hasNotVoted(){
       if(msg.value>=VOTE_COST){
           if (val) {
                true_votes.push(msg.sender);
            } else {
                false_votes.push(msg.sender);
            }
       hasVoted[msg.sender]=true;
       emit hasVotedRecord(msg.sender,true);
       }
   }

   function disperse() public onlyOwner() isCurrentState(States.VOTE) pretransition() posttransition() {
       if (true_votes.length > false_votes.length) {
           winningGroup=true_votes;
           winningCompensation = VOTE_COST+(VOTE_COST*false_votes.length) / true_votes.length;
       }else if (true_votes.length < false_votes.length) {
           winningGroup=false_votes;
           winningCompensation = VOTE_COST+(VOTE_COST*true_votes.length) / false_votes.length;
       }else{
           winningGroup = true_votes;
           winningCompensation = VOTE_COST;
       }
    }
    function withdraw() public onlyVoter() isCurrentState(States.WITHDRAW) {
       if (hasVoted[msg.sender]==true) {
           for (uint i=0;i<winningGroup.length;i++) {
               if(winningGroup[i]==msg.sender){
              msg.sender.transfer(winningCompensation);
               }
          }
      }
    }
}