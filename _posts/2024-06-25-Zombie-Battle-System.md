---
title: "[Cryptozombie] Solidity: Zombie Battle System"
date: 2024-06-25 22:20:00 +0900
categories: [0x01. InfoSec, 0x02. Web3]
tags: [Solidity, Cryptozombie]
math: true
mermaid: true
---
## Payable Modifier
Solidity에서 **`payable` 제어자**는 이더를 주고받을 수 있는 함수를 나타내는 데 사용한다.   

```solidity
contract OnlineStore {
  function buySomething() external payable {
    // Check to make sure 0.001 ether was sent to the function call:
    require(msg.value == 0.001 ether);
    // If so, some logic to transfer the digital item to the caller of the function:
    transferThing(msg.sender);
  }
}
```

위 예시 코드처럼 `msg.value`라는 Solidity에 내장된 전역 변수와 함께 사용 된다. 만약 이더를 주고 받는 함수에 `payable` 제어자가 없다면, 해당 함수는 transaction을 할 수 없다.

## Withdraws

```solidity
contract GetPaid is Ownable {
  function withdraw() external onlyOwner {
    address payable _owner = address(uint160(owner()));
    _owner.transfer(address(this).balance);
  }
}
```

이더를 전송하기 위한 주소의 형태는 **`address payable`**이다. **`transfer`**함수를 이용하여 해당 주소에 이더를 전송할 수 있고 `transfer`함수의 매개 변수인 `address(this).balance`에 해당 contract에 저장된 전체 금액을 반환한다.

## Random Numbers
Solidity에서 `keccak256` 해시 함수를 이용하여 **난수**를 생성하는 방법은 안전하지 않다.

**Proof of Work(PoW)**은 블록체인의 합 알고리즘 중 하나로, 네트워크 참여자가 **블록**을 생성하기 위해 계산이 매우 복잡한 연산 작업을 수행한다. 만약 노드가 해당 연산 작업을 완료하면 다른 노드들은 연산 과정을 멈추고 해당 블록이 유효한지 검증한다. 연산이 완료된 블록이 유효 하다면 블록체인에 해당 블록을 추가한다. 이러한 방식이 난수 생성을 취약하게 만든다. 

```solidity
uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
```

공격자는 원하는 난수 값이 나올 때까지 nonce 값을 조작하며 다양한 조합을 시도할 수 있고, 자신에게 유리한 난수를 생성하기 위해 블록 생성 시간을 의도적으로 지연시킬 수 있다. 물론 네트워크 상의 수많은 이더리움 노드들이 다음 블록을 추가하기 위해 경쟁하기 때문에, 많은 시간과 연산 자원을 필요로 한다. 하지만 보상이 시간과 연산 자원 보다 훨씬 크다면 공격자들은 해당 취약성을 노릴 것이다.

안전한 난수 생성방법을 알고 싶다면 **[Secure Random Number Generation](https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract)**이 글을 읽으면 된다.

## Zombie Battle System Clear

![Clear1](/assets/img/Zombie Battle System/Clear1.png)

![Clear2](/assets/img/Zombie Battle System/Clear2.png)

[Zombie Battle System Clear](https://share.cryptozombies.io/en/lesson/4/share/Dongpago2?id=WyJjenw2MjIyMjgiLDIsMTRd)

## Ref
1. [Solidity: Beginner to Intermediate Smart Contracts](https://cryptozombies.io/en/solidity)

2. [Secure Random Number Generation](https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract)