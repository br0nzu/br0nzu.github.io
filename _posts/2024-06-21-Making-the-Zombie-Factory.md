---
title: Solidity - Making the Zombie Factory
date: 2024-06-21 22:00:00 +0900
categories: [0x2. Web3, 0x1. Crypto Zombie]
tags: [Solidity, Cryptozombie]
math: true
mermaid: true
---
**Crypto Zombie**의 **Solidity: Beginner to Intermediate Smart Contracts** 강의는 Solidity에 대한 기본 지식을 게임 미션을 달성하면서 익힐 수 있는 학습 사이트이다. 그 중에서 **Making the Zombie Factory** 강의는 Solidity의 기본적인 문법을 배울 수 있는 강의이다.

## Contract
**Contract**는 이더리움 어플리케이션의 기본적인 구성 요소로 모든 변수와 함수들이 Contract에 속해 있다. Contract는 **Solidity**언어로 구성된다.

모든 Solidity 소스 코드는 반드시 **version pragma**[^footnote]를 명시해야 한다. Solidity의 컴파일러 버전을 명시함으로써, 컴바일러 버전 별 발생하는 문제들을 사전에 예방할 수 있다. contract와 solidity 버전 명시는 다음과 같다.

```solidity
pragma solidity >=0.5.0 <0.6.0; // solidity version

// Create Contract
contract HelloWorld {

}
```

## State Variable
**State Variable(상태 변수)**는 contract에 영구적으로 저장되는 변수이다. 즉, 이더리움 블록체인에 영구적으로 기록된다. 상태 변수의 예시는 다음과 같다.

```solidity
pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {

    uint dnaDigits = 16;

}
```

위 코드에서 상태 변수는 `dnaDigits`이다.

## Operation
solidity에서 연산자는 다음과 같다.

* Addition: `x + y`
* Subtraction: `x - y`
* Multiplication: `x * y`
* Division: `x / y`
* Modulus / Remainder: `x % y` *(for example, `13 % 5` is `3`)*

사칙 연산도 가능하고, **지수 연산(exponential operator)**도 가능하다.

ex) `uint x = 5 ** 2; // equal to 5^2 = 25`

## Struct & Arrays
solidity는 **구조체(Struct)와 배열(Array)**을 사용할 수 있다. 배열은 정적 배열과 동적 배열을 사용할 수 있고, 구조체 배열도 사용할 수 있다. 상태 변수가 블록체인에 영원히 기록되기 때문에 동적 할당이 유용하다.

```solidity
// Create Struct
struct Person {
  uint age;
  string name;
}

// Array with a fixed length of 2 elements
uint[2] fixedArray;
// another fixed Array, can contain 5 strings
string[5] stringArray;
// a dynamic Array - has no fixed size, can keep growing
uint[] dynamicArray;

// dynamic Array, we can keep adding to it
Person[] people;
```

위 코드를 기반으로 새로운 구조체 인스턴스를 생성하고 배열에 추가하면 다음과 같이 나온다.

```solidity
// Create a New Person
Person satoshi = Person(20, "Satoshi");

// Add that person to the Array
people.push(satoshi);

// Combine
people.push(Person(20, "Satoshi"));
```

`array.push()`는 배열에 끝에 해당 원소를 추가할 수 있다.

## Function
**함수(Function)** 선언은 다음과 같이 할 수 있다.

```solidity
function eatHamburgers(string memory _name, uint _amount) public { }
```

위 코드를 보면 특징은 다음과 같다.

* **public/private** 사용 가능
    * 만약 private로 사용해야 한다면, 함수명 앞에 `_`(underscore)를 사용하는 것이 관례이다.
* **memory** 키워드: 함수가 호출될 때 변수의 값이 메모리에 일시적으로 저장되고 함수가 실행되는 동안만 유지되며, 함수가 종료되면 사라짐 → 함수 내부에서 안전하게 변수를 수정할 수 있음
* 함수 매개변수의 변수명에 `_`(underscore)로 시작하는 것은 전역 변수와 구별하기 위해 관례적으로 사용

### Function modifier
**함수 제어자(Function modifier)**는 함수의 실행을 제어하는 데 사용되는 특별한 종류의 함수이다. 

**view 함수**는 블록체인의 상태를 읽을 수 있지만, 상태를 변경하지 않는 함수이다.

```solidity
function getData() public view returns (uint256) {
    return data;
}
```

**pure 함수**는 블록체인의 상태를 전혀 읽지 않으며, 상태를 변경하지도 않는 함수이다. 함수의 반환값은 오직 함수의 매개변수에 의해 전달된다.

```solidity
function _multiply(uint a, uint b) private pure returns (uint) {
  return a * b;
}
```

> 컴파일러가 `pure`, `view` 등의 제어자를 사용한다면, 어떤 제어자를 써야하는지 알려줌
{: .prompt-info}

## Keccak256
solidity에서 **Keccak256**은 해시 함수를 제공하는 기본 함수이다. 이 함수는 입력값을 받아 그에 대한 Keccak-256 해시를 반환한다. 주로 의사 난수 생성[^fn-nth-2]하는데 사용된다.

```solidity
keccak256(abi.encodePacked(input));
```

## Typecastin
데이터 타입을 바꿔야 한다면 **Typecasting**을 하면 된다. 

```solidity
uint8 a = 5;
uint b = 6;
// throws an error because a * b returns a uint, not uint8
uint8 c = a * b;
// we have to typecast b as a uint8 to make it work
uint8 c = a * uint8(b);
```

## Events
**이벤트(Event)**는 contract에서 로그를 생성하는데 사용되는 기능이다. 이벤트는 트랜잭션 로그의 일부로 기록되며, 블록체인 외부의 애플리케이션에서 특정 조건이나 상태 변경을 추적할 수 있도록 도와준다.

```solidity
// Declare the event
event IntegersAdded(uint x, uint y, uint result);

function add(uint _x, uint _y) public returns (uint) {
  uint result = _x + _y;
  // Fire an event to let the app know the function was called
  emit IntegersAdded(_x, _y, result);
  return result;
}
```

이벤트는 contract와 상호작용하는 애플리케이션에서 유용하게 사용할 수 있다. 위 코드를 JavaScript에서는 아래 처럼 작동한다.

```js
YourContract.IntegersAdded(function(error, result) {
  // do something with result
})
```

## Web3.js
Solidity로 contract를 작성한 후, 이와 상호작용할 수 있는 애플리케이션을 만들기 위해 JavaScript 코드가 필요하다. 이더리움에서는 **Web3.js**라는 JavaScript 라이브러리를 제공한다. Web3.js를 사용하면 JavaScript 애플리케이션에서 contract와 상호작용하고, 이더리움 네트워크에 연결하며, 트랜잭션을 전송하고 데이터를 조회할 수 있다.

## Crypto Zombie Making the Zombie Factory Clear
![Zombie](/assets/img/Making the Zombie Factory/Zombie.png)

[Clear](https://share.cryptozombies.io/en/lesson/1/share/br0nzu?id=Y3p8NjIyMjI4)

## Ref
1. [Solidity: Beginner to Intermediate Smart Contracts](https://cryptozombies.io/en/solidity)

## Footnote
[^footnote]: **version pragma**: 해당 소스코드에 사용될 Solidity 컴파일러 버전

[^fn-nth-2]: **의사 난수 생성(pseudo-random number generation)**: 컴퓨터에서 난수를 알고리즘을 사용하여 생성하는 방법