---
title: Advanced JavaScript
date: 2024-05-26 18:30:00 +0900
categories: [0x6. Development, 한 입 크기로 잘라먹는 리액트]
tags: [Dev, Front, JS]
math: true
mermaid: true
---
저번시간에([Basics of JavaScript](/posts/Basics-of-JavaScript/)) 이어서 이번엔 JavaScript의 심화 부분을 설명하겠다. 

## Truthy & Falsy
JavaScript에서는 참(True), 거짓(False)이 아닌 값도 참, 거짓으로 평가할 수 있다.

### Falsy한 값
```js
let f1 = undefined;
let f2 = null;
let f3 = 0;
let f4 = -0;
let f5 = NaN;
let f6 = ""; // 빈 문자열 
let f7 = 0n; // BigInt
```

### Truthy 한 값
7가지 Falsy 한 값들 제외한 나머지 모든 값이다.

## 단락 평가(Shory-circuit Evaluation)
**단락 평가**란 2개 이상 피연산자가 있는 **논라 연산자**에서 앞에 있는 피연산자의 값만으로 논리 연산의 결과를 확정지을 수 있으면 나머지 피연산자에는 접근하지 않는 것이다.

## 구조 분해 할당
**구조 분해 할당**은 배열이나 객체에 저장된 여러 개의 값들을 분해하여 각각 다른 변수에 할당하는 것이다.

```js
let arr = [1, 2, 3];
let [one, two, three, four = 4] = arr;
```

위 코드처럼 배열에서 구조 분해 할당을 할 때, 새로운 변수를 할당 및 초기화 할 수 있다.

```js
let = {
  age:myAge,
  name,
  major,
} = person;
```

`age:myAge`는 `age` 대신 `myAge`를 변수로 한다는 것이다.

## Spread 연산자와 Rest 매개변수
**Spread 연산자**는 객체나 배열에 저장된 여러개의 값을 개별로 흩뿌려주는 역할을 한다.

```js
let arr1 = [1, 2, 3];
let arr2 = [4, ...arr1, 5, 6];

let obj1 = {
  a: 1,
  b: 2,
};
let obj2 = {
  ...obj1,
  c: 3,
  d: 4,
};

function func(p1, p2, p3) {
  console.log(p1, p2, p3);
}

func(...arr1);
```

**Rest 매개변수**는 JavaScript에서 함수의 인수 목록에서 나머지 인수를 하나의 배열로 모아주는 문법이다.

```js
let arr = [1, 2, 3, 4, 5, 6];

function func(one, two, ...rs) {
  console.log(rs);
}

func(...arr);
```

Rest 매개변수 선언은 `...문자`로 선언할 수 있고, 사용시 주의점은 Rest 매개변수는 나머지를 다 선언했기 때문에 Rest 매개변수 뒤에 추가 변수 선언을 할 수 없다.

## 원시타입 VS 객체타입
**원시 타입**이란 동시에 한 개의 값만 변수에 저장될 수 있는 자료형이고, **객체 타입**은 여러가지 값을 동시에 저장할 수 있는 자료형이다. 두 타입은 값이 저장되거나 복사되는 과정이 서로 다르기 때문에 구분된다.

### 원시 타입
![원시 타입](/assets/img/240526/Primitive Data Type.png)
원시 타입은 값 자체로써 변수에 저장되고 저장된다. 즉, 메모리 값 수정이 불가능하다.

### 객체 타입
![객체 타입](/assets/img/240526/Obj Data Type_1.png)
![객체 타입](/assets/img/240526/Obj Data Type_2.png)
객체 타입은 참조값을 통해 변수에 저장되고 복사된다. 그래서, 메모리 값 수정이 가능하다.

#### 주의사항
객체 타입 주의사항은 다음과 같다.
* **의도치 않게 값이 수정될 수 있다.**
* **객체간의 비교는 참조값을 기준으로 한다.**
* 배열과 함수도 객체이다.

![비교](/assets/img/240526/Compare.png)
객체의 참조 값을 그대로 대입 연산자를 통해 복사(얕은 복사)하면 의도치 않게 값이 수정될 수 있으니, 객체 생성과 속성만 따로 복사(깊은 복사)하는 것이 좋다. 또한, 객체간 비교는 참조값을 기준으로 하기 때문에 `JSON.stringify()`와 같은 내장 함수를 이용하여 객체를 문자열로 비교해야한다.

## 반복문으로 배열 객체 순회하기
**순회(Iteration)**는 배열, 객체에 저장된 여러개의 값을 **순서대로** 하나씩 접근하는 것을 뜻한다.

배열을 순횐하기 위해서는 `for`문이나, `for A of B` 반복문을 사용하면 된다.
```js
let arr = [1, 2, 3]
// for문
for (let i = 0; i < arr.length; i++) {
  console.log(arr[i]);
}
// for A of B
for (let item of arr) {
  console.log(item);
}
```

객체를 순회하기 위해서는 `Object.keys`, `Object.values`, `for A in B`가 있다.
```js
let keys = Object.keys(person); // Object.keys
let values = Object.values(person); // Object.values
// for A in B
for (let key in person) {
  console.log(key);
}
```
여기서 주의할점은 객체 순회 문법은 `for A of B`가 아닌 `for A in B`이다.

## 배열 메서드
### 요소 조작
배열의 요소를 조작하는 메서드는 **<U>push, pop, shift, unshift, slice, concat</U>**이 있다.
* **push**: 배열의 맨 뒤에서 새로운 요소를 추가

```js
let arr = [1, 2, 3];
const newLength = arr.push(4, 5, 6, 7);
```

* **pop**: 배열의 맨 뒤에 있는 요소를 제거

```js
let arr = [1, 2, 3];
const poppedItem = arr.pop();
```

* **shift**: 배열의 맨 앞에 있는 요소를 제거

```js
let arr = [1, 2, 3];
const shiftedItem = arr.shift();
```

* **unshift**: 배열의 맨 앞에 있는 요소를 추가

```js
let arr = [1, 2, 3];
const newLength2 = arr.unshift(0);
```

* **slice**: 배열의 특정 범위를 잘라내서 새로운 배열로 반환, 원본 배열의 값 변경 X

```js
let arr = [1, 2, 3, 4, 5];
let sliced = arr.slice(2, 5); // (시작범위, 끝 범위 - 1)
let sliced2 = arr.slice(2); // 시작 범위 ~ 끝 범위
let sliced3 = arr.slice(-3); // 끝 범위에서 -3
```

* **concat**: 두개의 서로 다른 배열을 이어 붙여서 새로운 배열을 반환

```js
let arr1 = [1, 2];
let arr2 = [3, 4];

let concatedArr = arr1.concat(arr2);
```

> `shift`와 `unshift`는 `push`와 `pop`보다 늦게 동작한다.
{: .prompt-tip }

### 순회와 탐색
배열의 요소 **순회** 메서드는 `forEach`가 있다.
* **forEach**: 모든 요소를 순회하면서, 각각의 요소에 특정 동작을 수행시키는 메서드

```js
let arr = [1, 2, 3];

arr.forEach(function (item, idx, arr) {
  console.log(idx, item * 2);
});

let doubledArr = [];

arr.forEach((item) => {
  doubledArr.push(item * 2);
});
```

배열의 요소를 **탐색**하는 메서드는 `includes`, `indexof`, `findIndex`, `find`가 있다.
* **includes**
  * 배열에 특정 요소가 있는지 확인
  * 반환값은 요소가 있으면 True, 없으면 False를 반환

```js
let arr = [1, 2, 3]
let isInclude = arr.includes(4)
```

* **indexof**
  * 특정 요소의 인덱스(위치)를 찾아서 반환
  * 원시 타입이 아닌 객체 타입의 저장된 배열에서는 특정 요소가 중복된다면 정학한 요소의 위치를 찾아낼 수 없음(얕은 비교)

```js
let arr = [1, 2, 3];
let index = arr.indexOf(2);
```

* **findIndex**
  * 모든 요소를 순회하면서, 콜백함수를 만족하는 특정 요소의 인덱스(위치)를 반환
  * `indexof` 문제점 해결

```js
let arr = [1, 2, 3];
const findedIndex = arr.findIndex(
  (item) => item === 2
);
```

* **find**: 모든 요소를 순회하면서 콜백함수를 만족하는 요소를 찾는데, 요소를 그대로 반환

```js
let arr = [
  { name: "br0nzu" },
  { name: "dongpago2" },
];

const finded = arr.find(
  (item) => item.name === "br0nzu"
);
```

### 변형
* **filter**
  * 기존 배열에서 조건을 만족하는 요소들만 필터링하여 새로운 배열로 반환
  * 웹 서비스 개발할 때 특정 조건 검색 기능 또는 카테고리별 필터 기능을 만드는데 거의 필수적으로 사용

```js
let arr2 = [
  { name: "br0nzu", hobby: "pwn" },
  { name: "dongpago2", hobby: "dev" },
];

const pwnisPeople = arr.filter(
  (item) => item.hobby === "pwn"
);
```

* **map**: 배열의 모든 요소를 순회하면서, 각각 콜백함수를 실행하고 그 결과값들을 모아서 새로운 배열로 반환

```js
let arr = [1, 2, 3];
const mapResult = arr.map((item, idx, arr) => {
  return item * 2;
});

let arr2 = [
  { name: "br0nzu", hobby: "pwn" },
  { name: "dongpago2", hobby: "dev" },
];

let names = arr2.map((item) => item.name);
```

* **sort** 
  * 배열을 사전순으로 정렬하는 메서드
  * 문자열은 잘 작동하지만, 숫자형인 경우는 **비교 기준**을 설정해야한다.

```js
let arr3 = [10, 3, 5];
arr3.sort((a, b) => {
  if (a > b) {
    return -1;  // a가 b의 앞으로 반환
  } 
  else if (a < b) {
    return 1; // b가 a의 앞으로 반환
  } 
  else {  
    return 0; // 두 값의 자료 교체 X
  }
});
```

* **toSorted**: 정렬된 새로운 배열을 반환하는 메서드

```js
let arr = ["c", "a", "b"];
const sorted = arr.toSorted();
```

* **join**: 배열의 모든 요소를 하나의 문자열로 합쳐서 반환

```js
let arr = ["pwn", "rev", "crypto"];
const joined = arr.join(" "); // 요소들 사이에 들어갈 값
```

## Date 객체와 날짜
**Date 객체 생성**는 방법은 `let date = new Date()`이다. Date 객체를 생성하는 생성자를 사용하면 Date객체를 만들 수 있다. `Date()`에 아무 값이 없다면 현재 시간을 기준으로 하고, Date객체에 값을 넣는다면 날짜와 시간을 설정할 수 있다. ex) Date(2024, 5, 26, 4, 00, 00)

**타임 스탬프**는 특정 시간이 UTC(1970.01.01 00시 00분 00초)로 부터 몇 ms가 지났는지를 의미하는 숫자값이다. 타임 스탬프는 복잡한 형태를 가지고 있는 시간 정보를 간단한 숫자로 표현할 수 있기 때문에 개발할 때 주로 사용한다. 사용 예시방법은 `getTime()`을 하면 된다. ex) `let ts = date.getTime()`

시간의 요소들을 추출하는 방법은 다음과 같다.

```js
let year = date.getFullYear();
let month = date.getMonth() + 1;
let date = date.getDate();

let hour = date.getHours();
let minute = date.getMinutes();
let seconds = date.getSeconds();
```

여기서 month + 1을 하는 이유는 JavaScript는 달을 0부터 시작한다.

시간을 수정하고 싶다면 다음과 같이 하면 된다.

```js
date.setFullYear(2024);
date.setMonth(5);
date.setDate(27);
date.setHours(4);
date.setMinutes(00);
date.setSeconds(00);
```

이렇게 Date 객체와 요소들을 추출하고 수정해보았다. 이제 시간을 여러 포맷으로 출력해보겠다.

```js
console.log(date.toDateString());  // 날짜만 출력
console.log(date.toLocaleString());  // 현지화된 포멧으로 출력
```

## 동기와 비동기
### 동기(Synchronous)
![동기](/assets/img/240526/Synchronous.png)

**동기(Synchronous)**는 여러 개의 작업이 있을 때 이 작업들을 순서대로 한 번에 하나씩만 처리한다. 하지만 동기의 큰 문제점이 있다.

![Thread](/assets/img/240526/Thread.png)

위 사진처럼 작업이 오래 걸리는 경우 그 다음의 작업은 작동하지 않고 계속 기다리게 된다. 이를 보완하는 방법으로는 멀티 쓰레드가 있지만, JavaScript는 쓰레드가 1개 밖에 없어 비동기적으로 작업을 처리해야한다.

### 비동기(Asynchronous)
![비동기1](/assets/img/240526/Asynchronous_1.png)
![비동기2](/assets/img/240526/Asynchronous_2.png)

**비동기(Asynchronous)**는 작업을 순서대로 처리하지 않는다. 그래서 Task B처럼 오래 걸리는 작업은 다른 작업의 진행을 방해하지 않는다. 동기 방식에서는 Task B가 완료될 때까지 Task C가 시작되지 않지만, 비동기 방식에서는 Task B가 진행되는 동안에도 Task C를 포함한 다른 작업들이 계속해서 진행될 수 있다.

![비동기3](/assets/img/240526/Asynchronous_3.png)

비동기 작업을 할 수 있는 이유는 자바스크립트 엔진이 아닌 **Web APIs**에서 비동기 작업이 처리되기 때문이다.

비동기 작업을 하고 싶으면 `setTimeout()`을 활용하면 된다.

```js
console.log(1);

setTimeout(() => {
  console.log(2);
}, 3000);

console.log(3);
```

이렇게 보통 비동기 작업을 처리할 때는 **콜백 함수**를 많이 사용한다. 하지만 콜백 함수를 중첩하여 많이 사용하면 코드가 복잡해지는 문제가 있기 때문에 **Promise 객체**로 비동기 작업을 처리할 수 있다.

#### Promise 객체
![Promise Obj](/assets/img/240526/Promise Obj.png)

**Promise 객체**는 비동기 작업을 효율적으로 처리할 수 있도록 도와주는 자바스크립트의 내장 객체이다. Promise는 3가지 상태로 나눌 수 있다.

![Promise State](/assets/img/240526/Promise State.png)

이렇게 대기 상태가 성공 상태로 바뀐다면 **해결(resolve)**되었다는 뜻이고, 만약 실패 상태로 바뀐다면 **거부(reject)**되었다는 뜻이다.

Promise 객체를 사용하는 방법으로는 다음과 같이 사용할 수 있다.

```js
function add(num) {
  const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
      if (typeof num === "number") {
        resolve(num + 10);
      } else {
        reject("num이 숫자가 아닙니다");
      }
    }, 2000);
  });

  return promise;
}

add(0)
  .then((result) => {
    console.log(result);
    return add(result);
  })
  .then((result) => {
    console.log(result);
    return add(undefined);
  })
  .then((result) => {
    console.log(result);
  })
  .catch((error) => {
    console.log(error);
  });
```

위 예시 코드는 **Promise 객체**를 사용하여 비동기 작업을 나타내는 코드이다. Promise 객체와 함께 사용하는 `then`과 `catch` 메서드가 있다.

`then`메서드는 **reslove**된 상태를 `catch`는 **reject**된 상태를 나타낸다.

**Promise 객체**이외에도 어던 함수를 비동기 함수로 만들어주는 키워드가 있다.

`async`는 어떤 함수를 비동기 함수로 만들어주고, 함수가 Promise를 반환하도록 변환해준다. 사용 예시는 다음과 같다.

```js
async function getData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve({
        name: "DJ",
        id: "br0nzu",
      });
    }, 1500);
  });
}
```

`async`와 함께 쓰일 수 있는 키워드인 `await`이 있다. `await`은 `async`함수 내부에서만 사용이 가능하고, 비동기 함수가 다 처리되기를 기다리는 역할을 한다.

```js
async function printData() {
  const data = await getData();
  console.log(data);
}

printData();
```

이제 **Promise 객체**와 함께 사용하는 `then`과 `catch` 메서드뿐만 아니라, `async`와 `await` 키워드를 통해 비동기 작업을 더 직관적이고 간편하게 처리할 수 있게 되었다. 이 방법들을 활용하면 비동기 코드를 더욱 효율적이고 가독성 있게 작성할 수 있다.

## Ref
[1] [한입 크기로 잘라 먹는 리액트(React.js) : 기초부터 실전까지](https://www.inflearn.com/course/%ED%95%9C%EC%9E%85-%EB%A6%AC%EC%95%A1%ED%8A%B8)

[2] [sort 추가 자료](https://reactjs.winterlood.com/fc0a951e-41cd-4cc5-8f47-7507965bbe41#8f2d70d5e8334377bb56f0a3f9101de2)