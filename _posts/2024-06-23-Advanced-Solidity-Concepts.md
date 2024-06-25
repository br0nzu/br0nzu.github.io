---
title: Solidity - Advanced Solidity Concepts
date: 2024-06-23 22:50:00 +0900
categories: [0x2. Web3, 0x0. Crypto Zombie]
tags: [Solidity, Cryptozombie]
math: true
mermaid: true
---
이더리움에서 contract를 배포하면 수정하거나 다시 갱신할 수 없다. Contract를 배포한 초기 코드는 블록체인에서 영원히 저장된다. 그래서 Solidity에서 보안이 가장 큰 관심사인 이유이다.

보안성을 위해 코드를 하드 코딩하는 것보다 중요한 일부를 수정할 수 있도록 하는 것이 더 합리적으로 보인다.

이번 **Advanced Solidity Concepts**에서는 DApp의 중요한 일부를 수정할 수 있도록 하는 함수 만들기에 대해 학습할 예정이다.

## Ownable Contracts
**`Ownable`**은 Contract를 대상으로 특별한 권리를 가지는 소유자가 있음을 의미한다. 아래 나와 있는 Ownable은 OpenZepplin Solidity 라이브러리에서 나왔다. **OpenZepplin**은 당신이 소유한 DApp에서 사용할 수 있는 안전하고 커뮤니티에서 검증받은 smart contract 라이브러리이다.

```solidity
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
```

위 코드는 많은 것들이 보이지만 대표적인 두가지를 소개하겠다.

* **`Constructors()`**는 특별한 함수인 **생성자**이다. Contract가 처음 만들어질 때 한 번만 실행되는 특징이 있다.
* **`modifier onlyOwner()`**는 보통 실행 전 요구사항을 확인하기 위해 사용되는 유사 함수이다. 여기서는 `onlyOwner`가 접근 제한을 위해 사용되어서, 유일한 Contract의 주인이 이 함수를 실행시킬 수 있다.

## Function Modifiers
**함수 제어자(function modifier)**는 함수처럼 생겼지만 키워드 `function` 대신 `modifier`을 사용하여 나타낸다. 함수 제어자는 함수와 달리 직접 호출할 수 없고, 함수 정의부 끝에 해당 함수의 작동 방식을 바꾸도록 제어자의 이름을 붙인다.

```solidity
...
  modifier onlyOwner() {
    require(isOwner());
    _;
  }
...
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
...
```

위와 같은 예시로 onlyOwner라는 함수 제어자를 사용하고, `renounceOwnership()` 함수 정의부 끝에 제어자의 이름을 붙여 해당 함수의 작동 방식을 조작하였다.

또한, 함수 제어자에 인자를 넣어줄 수 있다.

```solidity
// A mapping to store a user's age:
mapping (uint => uint) public age;

// Modifier that requires this user to be older than a certain age:
modifier olderThan(uint _age, uint _userId) {
  require(age[_userId] >= _age);
  _;
}

// Must be older than 16 to drive a car (in the US, at least).
// We can call the `olderThan` modifier with arguments like so:
function driveCar(uint _userId) public olderThan(16, _userId) {
  // Some function logic
}
```

## Gas
Solidity에서 사용자가 DApp에 있는 함수를 실행할 때마다 매번 **가스(Gas)**를 지불해야 한다. 가스는 **이더(ETH)**를 지불하여 구매할 수 있다. 즉, DApp에서 함수를 실행시키기 위해서는 이더를 지불해야한다.

함수를 실행할 때마다 필요한 가스의 양은 함수의 구조에 따라 달라진다. 함수에서 각 연산들은 가스 비용을 갖고 있고, 그 연산을 수행하는 데 소모되는 컴퓨팅 자원의 양이 가스 비용을 결정한다. 따라서 함수를 실행하는 것은 실제 돈을 지불해야하기 때문에 이더리움에서 **코드 최적화**는 중요하다.

가스가 필요한 이유는 이더리움의 제작자들이 누군가 무한 반복문을 사용하여 네트워크를 방해하거나, 자원 소모가 큰 연산을 사용하여 네트워크 자원을 모두 사용하지 못하도록 만들기 원했기 때문이다. 그래서 제작자들은 연산 비용(가스)를 만들었고, 저장 공간 뿐만 아니라 연산 사용 시간에 따라 비용을 지불해야 한다.

가스 비용을 줄일 수 있는 방법 중 하나는 **구조체에서 자료형의 크기를 최적화** 하는 것이다.

```solidity
struct NormalStruct {
  uint a;
  uint b;
  uint c;
}

struct MiniMe {
  uint32 a;
  uint32 b;
  uint c;
}

// `mini` will cost less gas than `normal` because of struct packing
NormalStruct normal = NormalStruct(10, 20, 30);
MiniMe mini = MiniMe(10, 20, 30); 
```

위의 예시에서 `MiniMe`구조체가 `NormalStruct`보다 구조체 멤버 자료형의 크기가 더 작기 때문에 가스 비용이 덜 나간다. 또한, `MiniMe` 구조체에서도 가스 비용을 더 줄일 수 있는 방법이 있다. 바로 같은 유형끼리 인접하게 선언하면 사용하는 저장 공간을 최소화 할 수 있다.

```solidity
struct MiniMe1 {
  uint32 a;
  uint32 b;
  uint c;
}

struct MiniMe2 {
  uint32 a;
  uint c;
  uint32 b;
}
```

`MiniMe1`은 `MiniMe2`보다 같은 유형 끼리 인접하게 선언하여 저장 공간을 최소화 했기 때문에 비용이 덜 든다.

### View Function
`view` 함수를 사용자가 외부에서 호출할 때 가스가 들지 않는다. 왜냐하면 해당 함수는 블록체인에서 데이터만 읽을 뿐, 어떠한 값도 바꾸지 않기 때문이다. 만약 view 함수가 동일 Contract 내에 있는 view 함수가 아닌 다른 함수에서 내부적으로 호출될 경우는 여전히 가스가 발생한다. 왜냐하면 다른 함수의 호출에 의해 transaction이 발생하고, 이는 모든 개별 노드에서 검증되어야 하기 때문에 가스가 발생한다.

### Storage is Expensive
Solidity에서 가장 비싼 연산은 **storage에 쓰는 것**이다. 왜냐하면 storage에 쓸 때마다 데이터의 조각들을 바꾸고 블록체인에 영원히 기록되기 때문이다. 또한, 수천 개의 노드들이 해당 하드 드라이브에 데이터를 저장해야 하고, 블록체인이 커져가면서 이 데이터의 양 또한 같이 커져가기 때문이다. 따라서 가스 비용을 낮추기 위해서는 진짜 필요한 경우가 아니면 storage에 쓰는 연산을 사용 안하는 것이 좋다. 이를 위해 **메모리 배열**이 있다.

**메모리 배열**은 함수가 끝날때까지 해당 배열이 존재하다가 사라지고, 이는 storage에서 배열을 직접 업데이트하는 것보다 가스 소모 측면에서 훨씬 저렴하다. 메모리 배열은 반드시 크기를 정해야 한다.

```solidity
function getArray() external pure returns(uint[] memory) {
  // Instantiate a new array in memory with a length of 3
  uint[] memory values = new uint[](3);

  // Put some values to it
  values[0] = 1;
  values[1] = 2;
  values[2] = 3;

  return values;
}
```

## Time Units
Solidity에서는 시간을 다룰 수 있는 단위계를 기본적으로 제공한다. `now`변수는 현재의 유닉스 타임스탬프(1970년 1월 1일부터 지금까지의 초 단위 합) 값을 얻을 수 있다. `now` 변수 이외에도 `seconds`, `minutes`, `hours`, `days`, `weeks`, `years`변수들이 있다. 

```solidity
uint lastUpdated;

// Set `lastUpdated` to `now`
function updateTimestamp() public {
  lastUpdated = now;
}

// Will return `true` if 5 minutes have passed since `updateTimestamp` was 
// called, `false` if 5 minutes have not passed
function fiveMinutesHavePassed() public view returns (bool) {
  return (now >= (lastUpdated + 5 minutes));
}
```

위의 예시처럼 시간 변수들을 사용할 수 있다.

## Storage Reference
Solidity에서 `storage` 참조는 영구 저장소에 있는 데이터를 참조하는 키워드 이다. 해당 기능은 private과 internal 함수에서 사용할 수 있으며, 함수들 간에 구조체를 주고 받을 때 유용하다.

`function _doStuff(Zombie storage _zombie) internal { }`

이러한 방식으로 사용할 수 있다.

## For Loops
Solidity의 `for` 반복문은 JavaScript와 같은 방식으로 사용하면 된다.

```solidity
function getEvens() pure external returns(uint[] memory) {
  uint[] memory evens = new uint[](5);
  // Keep track of the index in the new array:
  uint counter = 0;
  // Iterate 1 through 10 with a for loop:
  for (uint i = 1; i <= 10; i++) {
    // If `i` is even...
    if (i % 2 == 0) {
      // Add it to our array
      evens[counter] = i;
      // Increment counter to the next empty index in `evens`:
      counter++;
    }
  }
  return evens;
}
```

## Misc
* **Security**: Solidity 코드에서 보안성 검사할 때 유심히 봐야할 부분은 `public`과 `external` 함수가 악용되는지 안되는지 유심히 보면 된다.
* `calldata`: memory와 유사하지만, external 함수에서만 사용 가능

## Advanced Solidity Concepts Clear

![Clear1](/assets/img/Advanced Solidity Concepts/Clear1.png)

![Clear2](/assets/img/Advanced Solidity Concepts/Clear2.png)

[Advanced Solidity Concepts Clear](https://share.cryptozombies.io/en/lesson/3/share/br0nzu?id=Y3p8NjIyMjI4)

## Ref
1. [Solidity: Beginner to Intermediate Smart Contracts](https://cryptozombies.io/en/solidity)