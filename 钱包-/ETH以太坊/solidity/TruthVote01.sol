pragma solidity ^0.4.22;

//枚举常量：默认值0，1，2
//Register: 服务已创建，所有者现在可以添加选民。
//Vote: 所有选民投票。
//Disperse: 投票付款被分给大多数参与者
contract TruthVote {
    enum States {
        REGISTER,
        VOTE,
        DISPERSE
    }
  address public owner = msg.sender;
  address[] true_votes;
  address[] false_votes;
  mapping (address => bool) voters;
  mapping (address => bool) hasVoted;

  uint VOTE_COST = 100;

  States _state;

  event hasVotedRecord(address indexed from,bool flag);

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

   function addVoter(address voterAddress) public onlyOwner(){
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

   //在*disperse*中*addr.send()调用的接收地址可以是一个合约，具有一个会失败的fallback函数，会打断*disperse。
   这有效地阻止了更多的参与者接收他们的收入。 一个更好的解决方案是提供一个用户可以调用来收取收入的提款功能。

   function disperse(bool val) public onlyOwner() isCurrentState(States.VOTE) pretransition(){
       address[] memory winningGroup;   //var winningGroup
       uint winningCompensation;
       if (true_votes.length > false_votes.length) {
           winningGroup=true_votes;
           winningCompensation = VOTE_COST+(VOTE_COST*false_votes.length) / true_votes.length;
       }else if (true_votes.length < false_votes.length) {
           winningGroup=false_votes;
           winningCompensation = VOTE_COST+(VOTE_COST*true_votes.length) / false_votes.length;
       }else{
           winningGroup = true_votes;
            winningCompensation = VOTE_COST;
            for (uint i = 0; i < false_votes.length; i++) {
                false_votes[i].transfer(winningCompensation);
            }
       }
       for (uint j = 0; j < winningGroup.length; j++) {
            winningGroup[j].transfer(winningCompensation);
        }
    }
}
