// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Libraries/SafeMath.sol";
import "../Libraries/Math.sol";

contract Share is Math {

    using SafeMath8 for uint8;

    using SafeMath for uint;

    struct Data {
        address owner;
        address mostValueAccount;
        address[] accounts;
        address[] partnerAccounts;
        uint8[] partnerPercents;
        uint8 mostValuePercent;
        uint lunchTime;
        uint chairPrice;
        uint tableCapacity;
        uint sharePrice;
        uint pickPrice;
        uint sitPrice;
        uint totalTx;
        uint totalVolume;
        uint totalSit;
        uint totalChair;
        uint totalAccount;
        uint tableCount;
        uint dappPrice;
        uint day;
    }

    struct AccountData {
        uint tx;
        uint volume;
        uint sit;
        uint chair;
        uint pick;
        bool isRegistered;
    }

    struct Table {
        address[] accounts;
        address picker;
        bool isShared;
    }

    struct Daily {
        uint tx;
        uint volume;
        uint sit;
        uint account;
    }

    address private _owner = msg.sender;

    uint private _lunchTime;

    uint8 private _mostValuePercent = 2;

    address private _mostValueAccount = msg.sender;

    uint8[] private _partnerPercents;

    address[] private _partnerAccounts;

    uint private _chairPrice = 0.6 ether;

    uint private constant _tableCapacity = 6;

    uint private constant _sharePrice = 6 ether;

    uint private constant _pickPrice = _tableCapacity * _sharePrice;

    uint private _sitPrice = _sharePrice + _chairPrice;

    address[] private _accounts;

    uint private _totalTx;

    uint private _totalVolume;

    uint private _totalSit;

    uint private _totalChair;

    uint private _totalAccount;

    mapping(uint => uint) private _dailyTx;

    mapping(uint => uint) private _dailyVolume;

    mapping(uint => uint) private _dailySit;

    mapping(uint => uint) private _dailyAccount;

    mapping(address => uint) private _accountTx;

    mapping(address => uint) private _accountVolume;

    mapping(address => uint) private _accountSit;

    mapping(address => uint) private _accountChair;

    mapping(address => uint) private _accountPick;

    mapping(address => bool) private _isRegistered;

    uint private _tableCount = 0;

    mapping(uint => bool) private _isShared;

    mapping(uint => address) private _tablePicker;

    mapping(uint => address[]) private _tables;

    uint private _dappPrice = 0;

    constructor() {
        _lunchTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "caller is not the owner");
        _;
    }

    modifier exceptOwner() {
        require(!isOwner(msg.sender), "caller is the owner");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return _owner == account;
    }

    function getData() public view returns (Data memory) {
        return Data(
            _owner,
            _mostValueAccount,
            _accounts,
            _partnerAccounts,
            _partnerPercents,
            _mostValuePercent,
            _lunchTime,
            _chairPrice,
            _tableCapacity,
            _sharePrice,
            _pickPrice,
            _sitPrice,
            _totalTx,
            _totalVolume,
            _totalSit,
            _totalChair,
            _totalAccount,
            _tableCount,
            _dappPrice,
            getDay()
        );
    }

    function getAccountData(address account) public view returns (AccountData memory) {
        return AccountData(_accountTx[account], _accountVolume[account], _accountSit[account], _accountChair[account], _accountPick[account], _isRegistered[account]);
    }

    function getTable(uint id) public view returns (Table memory) {
        return Table(_tables[id], _tablePicker[id], _isShared[id]);
    }

    function getDaily(uint day) public view returns (Daily memory) {
        return Daily(_dailyTx[day], _dailyVolume[day], _dailySit[day], _dailyAccount[day]);
    }

    function getDay() public view returns (uint) {
        uint during = block.timestamp - _lunchTime;
        uint remind = during % 1 days;
        uint time = block.timestamp - remind;
        return (time - _lunchTime) / 1 days;
    }

    function getDailyTx(uint day) public view returns (uint) {
        return _dailyTx[day];
    }

    function getDailyVolume(uint day) public view returns (uint) {
        return _dailyVolume[day];
    }

    function getDailySit(uint day) public view returns (uint) {
        return _dailySit[day];
    }

    function getDailyAccount(uint day) public view returns (uint) {
        return _dailyAccount[day];
    }

    function getAccountTx(address account) public view returns (uint) {
        return _accountTx[account];
    }

    function getAccountVolume(address account) public view returns (uint) {
        return _accountVolume[account];
    }

    function getAccountSit(address account) public view returns (uint) {
        return _accountSit[account];
    }

    function getAccountChair(address account) public view returns (uint) {
        return _accountChair[account];
    }

    function getAccountPick(address account) public view returns (uint) {
        return _accountPick[account];
    }

    function isRegistered(address account) public view returns (bool) {
        return _isRegistered[account];
    }

    function setMostValuePercent(uint8 percent) public onlyOwner {
        require(percent <= 3, "Percent most less than 3");
        _mostValuePercent = percent;
    }

    function setChairPrice(uint price) public onlyOwner {
        require(price > 0, "price must more than zero");
        require(price % 0.1 ether == 0, "price must be module of 0.1 matic");
        _chairPrice = price;
        _sitPrice = _chairPrice.add(_sharePrice);
    }

    function setPartners(address[] memory accounts, uint8[] memory percents) public onlyOwner {
        require(accounts.length > 0, "Accounts count must more than zero");
        delete _partnerPercents;
        delete _partnerAccounts;
        uint8 remindPercent = 100;
        for (uint i = 0; i < accounts.length; i++) {
            if (remindPercent == 0) return;
            if (percents[i] > 70) continue;
            uint8 percent = remindPercent < percents[i] ? remindPercent : percents[i];
            _partnerPercents.push(percent);
            _partnerAccounts.push(accounts[i]);
            remindPercent = remindPercent.sub(percent);
        }
    }

    function _inTable(uint index, address account) private view returns (bool) {
        for (uint i = 0; i < _tables[index].length; i = i.inc()) {
            if (_tables[index][i] == account) return true;
        }
        return false;
    }

    function _isFull(uint index) private view returns (bool) {
        return _tables[index].length == _tableCapacity;
    }

    function sit(uint count) public payable {
        require(count > 0, "You can not sit around 0 table");
        require(msg.value == count.mull(_sitPrice), "Send wrong value");
        uint day = getDay();
        uint income = count.mull(_chairPrice);
        if (!_isRegistered[msg.sender]) {
            _isRegistered[msg.sender] = true;
            _accounts.push(msg.sender);
            _dailyAccount[day] = _dailyAccount[day].inc();
            _totalAccount = _totalAccount.inc();
        }
        _totalTx = _totalTx.inc();
        _dailyTx[day] = _dailyTx[day].inc();
        _accountTx[msg.sender] = _accountTx[msg.sender].inc();
        _totalVolume = _totalVolume.add(msg.value);
        _dailyVolume[day] = _dailyVolume[day].add(msg.value);
        _accountVolume[msg.sender] = _accountVolume[msg.sender].add(msg.value);
        _totalSit = _totalSit.add(count);
        _dailySit[day] = _dailySit[day].add(count);
        _accountSit[msg.sender] = _accountSit[msg.sender].add(count);
        _totalChair = _totalChair.add(count);
        _accountChair[msg.sender] = _accountChair[msg.sender].add(count);
        if (_accountVolume[msg.sender] > _accountVolume[_mostValueAccount])
            _mostValueAccount = msg.sender;
        uint8 remindPercent = 100;
        payable(_mostValueAccount).transfer(income.percent(_mostValuePercent));
        remindPercent = remindPercent.sub(_mostValuePercent);
        for (uint i = 0; i < _partnerAccounts.length; i++) {
            payable(_partnerAccounts[i]).transfer(income.percent(_partnerPercents[i]));
            remindPercent = remindPercent.sub(_partnerPercents[i]);
        }
        payable(_owner).transfer(income.percent(remindPercent));
        for (uint i = 0; i < _tableCount; i = i.inc()) {
            if (!_inTable(i, msg.sender) && !_isFull(i)) {
                _tables[i].push(msg.sender);
                count = count.dec();
            }
            if (count == 0) return;
        }
        while (count > 0) {
            _tables[_tableCount].push(msg.sender);
            _tableCount = _tableCount.inc();
            count = count.dec();
        }
    }

    function share(uint nonce) public payable {
        uint day = getDay();
        uint8 counter = 0;
        _totalTx = _totalTx.inc();
        _dailyTx[day] = _dailyTx[day].inc();
        _accountTx[msg.sender] = _accountTx[msg.sender].inc();
        for (uint i = 0; i < _tableCount; i = i.inc()) {
            if(counter == 10) break;
            if (_isShared[i] || !_isFull(i)) continue;
            _totalChair = _totalChair.dec();
            for (uint j = 0; j < _tableCapacity; j = j.inc())
                _accountChair[_tables[i][j]] = _accountChair[_tables[i][j]].dec();
            uint pickerId = _random(++nonce) % _tableCapacity.dec();
            address piker = _tables[i][pickerId];
            payable(piker).transfer(_pickPrice);
            _totalVolume = _totalVolume.add(_pickPrice);
            _dailyVolume[day] = _dailyVolume[day].add(_pickPrice);
            _accountVolume[piker] = _accountVolume[piker].add(_pickPrice);
            _isShared[i] = true;
            _tablePicker[i] = piker;
            _accountPick[piker] = _accountPick[piker].inc();
            counter++;
        }
    }

    function activeTransfer(uint price) public onlyOwner {
        require(_dappPrice == 0, "Transfer is active");
        require(price % 500 ether == 0, "Price must be module of 500 matic");
        require(price >= 3000 ether, "Price must more than 3000 matic");
        uint day = getDay();
        _totalTx = _totalTx.inc();
        _dailyTx[day] = _dailyTx[day].inc();
        _accountTx[msg.sender] = _accountTx[msg.sender].inc();
        _dappPrice = price;
    }

    function transferDapp() public payable exceptOwner {
        require(_dappPrice > 0, "Sell is not active");
        require(msg.value == _dappPrice, "Send wrong value");
        uint day = getDay();
        _totalTx = _totalTx.inc();
        _dailyTx[day] = _dailyTx[day].inc();
        _accountTx[msg.sender] = _accountTx[msg.sender].inc();
        _totalVolume = _totalVolume.add(_dappPrice);
        _dailyVolume[day] = _dailyVolume[day].add(_dappPrice);
        _accountVolume[msg.sender] = _accountVolume[msg.sender].add(_dappPrice);
        payable(_owner).transfer(_dappPrice);
        _owner = msg.sender;
        _dappPrice = 0;
    }

}