---
title: Solidity - Zombies Attack Their Victims
date: 2024-06-22 16:50:00 +0900
categories: [0x2. Web3, 0x0. Crypto Zombie]
tags: [Solidity, Cryptozombie]
math: true
mermaid: true
---
## Address
이더리움 블록체인은 은행 계좌와 같은 **계정**들로 구성되어 있다. 계정은 **이더**[^footnote]의 잔액을 갖고 있고 다른 계정들과 해당 이더를 주고 받을 수 있다. 이때 각 계정은 **주소(Address)**를 갖고 있는데, 주소는 특정 사용자가 소유하고 있다.

## Mapping
**매핑(Mapping)**은 solidity에서 구조화된 데이터를 저장하는 또 다른 방법이다. 기본적으로 **key-value**의 저장소로 데이터를 저장하고 검색하는데 사용된다.

```solidity
// For a financial app, storing a uint that holds the user's account balance
mapping (address => uint) public accountBalance;  
// Or could be used to store / lookup usernames based on userId
mapping (uint => string) userIdToName;  
```

먼저 첫번째 예시 코드를 보면 key는 `address`이고, value는 `uint`이다. 해당 코드는 특정 주소를 반환하면 해당 주소의 잔액을 반환한다.

두 번째 예시 코드의 key는 `uint`이고, value는 `string`이다. 이 코드는 특정 사용자 ID를 조회하면 해당 ID의 사용자 이름을 반환한다.

## Msg.sender
solidity에서 모든 함수에 사용 가능한 특정한 전역변수들이 있다. 그 중 하나가 현재 함수를 호출한 사람의 주소를 가리키는 `msg.sender`이다. 

> solidity에서 함수 실행은 항상 외부 호출자가 시작하기 때문에, contract는 해당 contract의 함수를 호출하기 전까지 블록체인에서 아무것도 하지 않는다. 그래서 항상 `msg.sender`가 있다.
{: .prompt-info }

```solidity
mapping (address => uint) favoriteNumber;

function setMyNumber(uint _myNumber) public {
  // Update our `favoriteNumber` mapping to store `_myNumber` under `msg.sender`
  favoriteNumber[msg.sender] = _myNumber;
  // ^ The syntax for storing data in a mapping is just like with arrays
}

function whatIsMyNumber() public view returns (uint) {
  // Retrieve the value stored in the sender's address
  // Will be `0` if the sender hasn't called `setMyNumber` yet
  return favoriteNumber[msg.sender];
}
```

위 예제에서 누구나 `setMyNumber`함수를 호출할 수 있고 본인의 주소와 연결된 contract 내에 `_myNumber`(uint)를 저장할 수 있다. 

`whatIsMyNumber`는 자신의 주소에 저장된 숫자를 조회할 수 있다. 만약 사용자가 아직 `setMyNumber` 함수를 호출하지 않았다면, 기본값인 0을 반환한다.

## require
**`require`**는 특정 조건이 참이 아닐 경우 함수가 에러 메세지를 보내고 실행을 멈춘다. 이는 함수를 실행하기 전에 참이어야 하는 특정 조건을 확인하는데 유용하다.

```solidity
function sayHiToVitalik(string memory _name) public returns (string memory) {
  // Compares if _name equals "Vitalik". Throws an error and exits if not true.
  require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("Vitalik")));
  // If it's true, proceed with the function
  return "Hi!";
}
```

solidity는 문자열을 비교하는 기능이 없기 때문에 `keccak256`를 사용하여 비교한다.

## Inheritance
**상속(Inheritance)**은 contract가 다른 contract의 속성과 메소드를 상속받아 사용하는 개념이다. 이는 코드 재사용성을 높이고, 복잡한 contract를 더 쉽게 관리할 수 있게 한다.

```solidity
contract Doge {
  function catchphrase() public returns (string memory) {
    return "So Wow CryptoDoge";
  }
}

contract BabyDoge is Doge {
  function anotherCatchphrase() public returns (string memory) {
    return "Such Moon BabyDoge";
  }
}
```

위 예제를 보면 BabyDoge는 Doge로부터 상속을 받아서, BabyDoge는 `catchphrase()`와 `anotherCatchphrase()`에 접근할 수 있다.

## Import
**`import`**는 외부 파일 또는 라이브러리를 현재 contract 파일로 가져와서 사용할 수 있게 하는 지시어이다. 이를 통해 코드의 재사용성을 높이고, contract를 모듈화 하여 관리할 수 있다.

```solidity
import "./someothercontract.sol";

contract newContract is SomeOtherContract {

}
```

## Storage vs Memory
Solidity에서 변수를 저장할 수 있는 공간으로 `storage`와 `memory`가 있다.

`storage`는 변수를 블록체인에 영원히 저장한다. `memory`는 임시적으로 저장되는 변수로, contract 함수에 대한 외부 호출들이 일어나는 사이에 해당 변수가 지워진다. 컴퓨터 부품에서의 Hard Disk와 RAM을 생각하면 된다.

solidity에서 이러한 키워드를 기본적으로 처리하기 때문에 해당 키워드를 잘 사용하지 않는다. **상태 변수(함수 외부에 선언된 변수)**는 초기 설정상 **storage**로 선언되어 블록체인에 영구적으로 저장되는 반면, **함수 내에 선언된 변수**는 **memory**로 자동 선언되어서 함수 호출이 종료되면 사라진다. 하지만 이러한 키워드를 함수 안에서 구조체와 배열을 처리할 때 사용한다.

```solidity
contract SandwichFactory {
  struct Sandwich {
    string name;
    string status;
  }

  Sandwich[] sandwiches;

  function eatSandwich(uint _index) public {
    // Sandwich mySandwich = sandwiches[_index];

    // ^ Seems pretty straightforward, but solidity will give you a warning
    // telling you that you should explicitly declare `storage` or `memory` here.

    // So instead, you should declare with the `storage` keyword, like:
    Sandwich storage mySandwich = sandwiches[_index];
    // ...in which case `mySandwich` is a pointer to `sandwiches[_index]`
    // in storage, and...
    mySandwich.status = "Eaten!";
    // ...this will permanently change `sandwiches[_index]` on the blockchain.

    // If you just want a copy, you can use `memory`:
    Sandwich memory anotherSandwich = sandwiches[_index + 1];
    // ...in which case `anotherSandwich` will simply be a copy of the
    // data in memory, and...
    anotherSandwich.status = "Eaten!";
    // ...will just modify the temporary variable and have no effect
    // on `sandwiches[_index + 1]`. But you can do this:
    sandwiches[_index + 1] = anotherSandwich;
    // ...if you want to copy the changes back into blockchain storage.
  }
}
```

solidity 컴파일러가 경고 메세지를 통해 어떤 키워드를 사용해야할 지 알려주기 때문에 `storage`와 `memory`의 차이점만 알고 있으면 된다.

## Internal & External
`public`과 `private`이외에도 solidity에서는 `internal`과 `external`이 있다.

**`internal`**은 함수가 정의된 contract를 상속하는 contract에서도 접근이 가능하다 점을 제외하면 private과 동일하다. **`external`**은 오직 함수가 contract 바깥에서만 호출될 수 있고, contract 내의 다른 함수에 의해 호출될 수 없다는 점을 제외하면 public과 동일하다. 

```solidity
contract Sandwich {
  uint private sandwichesEaten = 0;

  function eat() internal {
    sandwichesEaten++;
  }
}

contract BLT is Sandwich {
  uint private baconSandwichesEaten = 0;

  function eatWithBacon() public returns (string memory) {
    baconSandwichesEaten++;
    // We can call this here because it's internal
    eat();
  }
}
```

## Interface
소유하고 있지 않은 contract와 상호작용하려면 **Interface**를 정의해야 한다. 

```solidity
contract LuckyNumber {
  mapping(address => uint) numbers;

  function setNum(uint _num) public {
    numbers[msg.sender] = _num;
  }

  function getNum(address _myAddress) public view returns (uint) {
    return numbers[_myAddress];
  }
}
```

`getNum`함수를 이용하여 이 contract에 있는 데이터를 읽고자 하는 external 함수가 있다고 가정하면, `LuckyNumber` contract에 인터페이스 정의를 할 필요가 있다.

```solidity
contract NumberInterface {
  function getNum(address _myAddress) public view returns (uint);
}
```

위 코드 처럼 인터페이스를 정의하는 것은 약간 다르지만 contract를 정의하는 것과 유사하다. 먼저 다른 contract와 상호작용하고자 하는 함수만을 선언하고, 다른 함수나 상태 변수에 대해서는 언급하지 않는다. 다음으로, 함수 몸통을 선언하지 않는다. 중괄호(`{ }`) 대신 세미콜론(`;`)으로 함수 선언한다. 

DApp 코드에 이러한 인터페이스를 포함하면 다른 컨트랙트에 정의된 함수의 특성, 호출 방법, 예상되는 응답 내용에 대해 알 수 있게 된다.

## Handling Multiple Return Values

```solidity
function multipleReturns() internal returns(uint a, uint b, uint c) {
  return (1, 2, 3);
}

function processMultipleReturns() external {
  uint a;
  uint b;
  uint c;
  // This is how you do multiple assignment:
  (a, b, c) = multipleReturns();
}

// Or if we only cared about one of the values:
function getLastReturnValue() external {
  uint c;
  // We can just leave the other fields blank:
  (,,c) = multipleReturns();
}
```

반환값이 여러개일 때 특정 반환값만 이용하고 싶거나 전체 반환값을 가독성 좋게 보이기 위해 할 수 있다.

## If statements
Solidity에서의 if문은 JavaScript와 동일하다.

```solidity
function eatBLT(string memory sandwich) public {
  // Remember with strings, we have to compare their keccak256 hashes
  // to check equality
  if (keccak256(abi.encodePacked(sandwich)) == keccak256(abi.encodePacked("BLT"))) {
    eat();
  }
}
```

## Clear
![Clear](/assets/img/Zombies Attack Their Victims/Clear.png)

[Clear](https://share.cryptozombies.io/en/lesson/2/share/br0nzu?id=Y3p8NjIyMjI4)

## Ref
1. [Solidity: Beginner to Intermediate Smart Contracts](https://cryptozombies.io/en/solidity)

## Footnote
[^footnote]: **이더**: 이더리움 블록체인 상의 통화