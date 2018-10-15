pragma solidity ^0.4.17;

contract funding{
    bool flag = false;

    // 众筹发起人地址(众筹发起人)
    address public manager;

    //项目名称
    string public projectName;

    //众筹参与人需要付的钱
    uint public supportMoney;

    //默认众筹结束的时间,为众筹发起后的一个月
    uint public endTime;

    //目标募集的资金(endTime后,达不到目标则众筹失败)
    uint public goalMoney;

    //众筹参与人的数组
    address[] public players;
    mapping(address=>bool) playersMap;

    //付款请求申请的数组(由众筹发起人申请)
    Request[] public requests;

    //付款请求结构体
    struct Request{
        //该付款请求详细说明
        string description;
        //付多少钱
        uint money;
        //支付商家的钱包地址
        address shopAddress;
        //付款是否完成
        bool complete;
        //已经投过票的人
        mapping(address=>bool) voteMap;
        //投票总数
        uint count;
    }

    // 构造函数
    function funding(string _projectName,uint _supportMoney,uint _goalMoney,address _address) public {
        manager = _address;
        projectName = _projectName;
        supportMoney = _supportMoney;
        goalMoney = _goalMoney;
        endTime = now + 4 weeks;
    }

    // 发起一份付款请求
    function createRequest(string _description,uint _money,address _shopAddress) public onlyManagerCanDo {
        Request memory request = Request({
            description:_description,
            money:_money,
            shopAddress:_shopAddress,
            complete:false,
            count:0
            });
        requests.push(request);
    }

    // 验证请求是否通过(其实就是众筹者投一票看是否允许该笔打款)
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        //1.检查该投票人是否在众筹人群里
        require(playersMap[msg.sender]);
        //2.检查该投票者是否投过票
        require(!request.voteMap[msg.sender]);
        request.count ++;
        request.voteMap[msg.sender] = true;
    }

    // 众筹发起人调用,可以调用完成付款
    function finilizeRequest(uint index) public onlyManagerCanDo{
        Request storage request = requests[index];
        // 该笔付款必须是为支付的
        require(!request.complete);
        // 一半以上的参与者要同意该笔付款
        require(request.count*2>players.length);
        // 转账付款, 转账前要验证所转的金额小于余额
        require(this.balance>request.money);
        request.shopAddress.transfer(request.money);
        // 将付款状态设置为true
        request.complete = true;
    }

    // 参与人支持众筹
    function support() public payable{
        require(msg.value == 79);
        players.push(msg.sender);
        // 设置集合, 把参与众筹的人设为true
        playersMap[msg.sender] = true;
    }

    // 获取有多少人参加众筹
    function getPlayersCount() public view returns(uint){
        return players.length;
    }

    // 获取参加众筹的人
    function getPlayers() public view returns(address[]){
        return players;
    }

    // 获取当前众筹地址金额
    function getTotalBalance() public view returns(uint){
        return this.balance;
    }

    // 获取众筹结束时间
    function getEndTimes() public view returns(uint){
        return endTime;
    }

    // 获取众筹结束时间
    function getRemainDays() public view returns(uint){
        return (endTime-now)/24/60/60;
    }

    // 检测是否可以结束众筹,只有结束了众筹才可以取出钱, 真实业务一定要有此方法, 我为了测试方便暂时注释
    /*    function checkStatus() public {
            require(!flag);
            require(now>endTime);
            require(this.balance>goalMoney);
            flag = true;
        }*/


    // 管理员权限校验
    modifier onlyManagerCanDo(){
        require(msg.sender == manager);
        _;
    }

}
