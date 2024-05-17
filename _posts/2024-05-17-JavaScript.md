---
title: JavaScript 기본
date: 2024-05-16 22:45:00 +0900
categories: [0x7. Development, 한 입 크기로 잘라먹는 리액트]
tags: [Dev, Front, JS]
math: true
mermaid: true
---
**JavaScript**는 오늘날 가장 많이 사용되는 프로그래밍 언어이다. JavaScript는 웹 서버나 어플리케이션등을 개발하는데 많이 활용되고, HTML과 CSS와 함께 웹 페이지를 개발하기 위해 만들어진 언어이다. 간략하게 HTML, CSS, JavaScript의 역할을 설명하겠다.

* **HTML**
  * 요소들의 내용, 배치, 모양을 정하기 위해 사용하는 언어
  * 색상이나 디자인 등의 수정은 불가
* **CSS**: 요소들의 색상, 크기 등의 스타일을 설정할 수 있음
* **JavaScript**
  * 웹 내부에서 발생하는 다양한 기능을 만들 수 있는 언어
  * 웹을 움직이게 하는 "웹의 근육"이라고 표현할 수 있음

## 변수와 상수
JavaScript의 변수 선언은 `let`으로 할 수 있고, 상수 선언은 `const`로 할 수 있다.

```js
let var = 99;
const var2 = 99;
```

상수 선언할 때 주의할 점은 상수 선언시 초기화를 반드시 해야한다. 그리고 변수 이름을 작성할 때는 몇가지 규칙이 있다.

1. `$`, `_`을 제외한 기호는 사용할 수 없다.
2. 숫자로 시작할 수 없다.
3. 예약어를 사용할 수 없다.(ex. `let`)

## 자료형(Type)
![Data Type](/assets/img/240517/Data Type.png)

### 원시 타입
**원시 타입**이란 동시에 한 개의 값만 변수에 저장될 수 있는 자료형이다. 원시 타입에는 **Number, String, Boolean, Null, Undefined**가 있다.

* **Number**
  * 사칙연산 가능
  * 무한대 표현 가능
    * ex) `let inf = Infinity;`, `let minf = -Infinity;`
  * `let nan = NaN;` - 수치 연산을 실패 했을때 보통 결과값으로 사용
* **String**
  * 문자열을 사용할 때 큰 따옴표/작은 따옴표 사용해야 함
  * 덧셈 연산 가능
  * backtic을 사용하여 변수를 동적으로 문자열 포함 가능(템플릿 리터럴 문법)
    ```js
    let Text = `${var1} ${var2}`;
    ```
* **Boolean**
    * 보통 상태를 표현할 때 사용
    * `true`, `false`
* **Null**
  * 개발자가 명시적으로 없음을 표현
  * 주로 객체나 변수의 초기값으로 설정할 때 사용
* **Undefined** 
  * 변수가 선언되었지만 값이 할당되지 않은 상태
  * Null과 비슷

## 형 변환(Type Casting)
**형 변환**은 어떤 값의 타입을 다른 타입으로 변경하는 것이다. 형 변환에는 **묵시적 형 변환**과 **명시적 형 변환**이 있다.

### 묵시적 형 변환
묵시적 형 변환은 자바스크립트 엔진이 알아서 형 변환 하는 것이다.

```js
let num = 19;
let str = "99";

const result = num + str;
console.log(result);
```
위 코드의 결과를 보면 num 변수는 Number 타입이지만 결과를 보면 `1999`로 나온다. 즉 num변수가 묵시적 형 변환을 하여 String이 되었고, 문자열끼리 덧셈 연산으로 `1999`가 나온다.

### 명시적 형 변환
명시적 형 변환은 개발자가 내장함수 등을 이용해서 직접 형 변환을 하는 것이다.

```js
let Str = "19";
let StrToNum = Number(Str);
```
위 코드의 결과를 보면 문자열인 `19`가 숫자형인 19로 형 변환되었다는 것을 알 수 있다. 하지만 문자열 변수에 숫자만 있는 것이 아니라면 문자열에서 숫자형으로 형 변환할 때 오류가 날 수 있다. 그럴때는 `parseInt`를 사용하여 문자열에서 숫자형으로 형 변환을 하면 된다.

```js
let Str = "99개";
let StrToNum = parseInt(Str);
```

## 객체(Object)
**객체**는 여러가지 값을 동시에 저장할 수 있는 자료형이다. 객체를 이용하면 현실세계에 존재하는 어떤 사물이나 개념을 표현하기 용이하기 때문에 사용한다.

객체 생성은 두가지 방법이 있다.
* 객체 생성자: `let obj = new Object();`
* 객체 리터럴: `let obj = {};`

객체 리터럴이 비교적 간편하기 때문에 주로 사용한다. 객체를 선언하면 객체 속성들이 있다. `key : value`로 이루어지는데, `key`에는 문자열과 숫자형만 가능하다. 또한, `key`에 띄어쓰기를 사용하고 싶으면 큰 따옴표나 작은 따옴표를 써야한다.

```js
let person = {
  name: "DJ",
  age: 99,
  "Cr4ft Team": true,
};
```

### 객체 속성 다루기
위의 `person`객체를 기준으로 객체 속성을 설명하겠다.
#### 객체 속성 접근
* 점 표기법: `let nmae = person.name;`
* 괄호 표기법: `let name = person["name"];`

괄호 표기법을 사용할 때 주의할 점은 `key`에 접근할 때 반드시 큰 따옴표나 작은 따옴표를 써야한다. 

#### 객체 속성 추가
```js
person.job = "Student";
person["FavoriteFood"] = "Noodle";
```

#### 객체 속성 수정
```js
person.job = "Researcher";
person["FavoriteFood"] = "Pilaf";
```

#### 객체 속성 삭제
```js
delete person.job;
delete person["FavoriteFood"];
```
객체 속성 삭제는 `delete`를 사용하면 된다.

#### 객체 속성 존재 확인
```js
let check = "name" in person;
```
겍체 존재 유무를 확인하는 방법은 `in` 연산자를 사용하면 된다. 만약 객체가 있다면 `true`값이 반환되고, 없다면 `false`로 반환된다.

### 상수 객체
**상수 객체**는 말뜻 그대로 상수에 저장해 놓은 객체이다.

```js
const animal = {
  type: "human",
  name: "DJ",
};

animal.age = 99; // 추가
animal.name = "br0nzu"; // 수정
delete animal.type; // 삭제
```
위의 코드처럼 상수 객체는 객체 속성을 **추가, 수정, 삭제**를 할 수 있다. 왜냐하면 상수는 새로운 값을 할당하지 못하는 변수기 때문이다.

### 메서드(method)
**메서드**는 객체 속성 중 함수 형태로 정의된 속성을 메서드라고 한다. 메서드는 보통 객체의 동작을 정의하는데 주로 사용된다.

```js
const person = {
  name: "DJ",
  greet() {
    console.log("Hi");
  },
};

person.greet();
person["greet"]();
```

## 배열(Array)
**배열**은 여러개의 값을 **순차적**으로 담을 수 있는 자료 형이다. 배열의 선언은 다음과 같다.

* 배열 생성자: `let arr = new Array();`
* 배열 리터럴: `let arr = { };`
배열 리터럴이 간결해서 주로 사용한다. 배열 요소 접근은 다음과 같다.

```js
let arr = { 1, 2, 3, };

let one = arr[0];
arr[0] = 0;
```

## 연산자(Operator)
**연산자**는 프로그래밍에서 다양한 연산을 위한 **기호, 키워드**이다. 연산자에는 다음과 같은 연산자들이 있다.

* 사칙 연산자: `+`, `-`, `*`, `/`, `%`
* 대입 연산자: `=`
* 복합 대입 연산자 = 사칙 연산자 + 대입 연산자
  * ex) `+=`, `-=`,`*=`,`/=`,`%=`
* 증감 연산자
  * 전위 연산: `++num`, `--num`
  * 후위 연산: `num++`, `num--`
* 논리 연산자
  * and: `&&`
  * or: `||`
  * not: `!`
* 비교 연산자
  * 동등 연산자: `===`
  * 비동등 연산자: `!==`
  * 나머지: `<`, `>` , `<=`, `>=`

> 동등 연산자에서 `===`를 권장하는 이유는 `==`는 값 자체만 판단하기 때문에 자료형이 달라도 값만 같다면 `True`값이 나온다.
{: .prompt-tip }

* null 병합 연산자: `??`
  * null, undefined가 아닌 값을 찾아내는 연산자(존재하는 값을 추려내는 기능)
  ```js
  let var1;
  let var2 = 99;
  let var3 = var1 ?? var2;
  ```
  * `var3`값은 `var1`이 undefined값이기 때문에 `var2`값인 `99`가 된다.
* typeof: 값의 타입을 문자열로 반환
  ```js
  let var = "99";
  let var2 = typeof(var);
  ```
* 삼항 연산자
  * 항을 3개 사용하는 연산자
  * 조건식을 이용하여 참/거짓일 때의 값을 다르게 반환
  * `조건식 ? 참 : 거짓`
    * ex) `let var = var2 % 2 === 0 ? "odd" : "even";`

## 조건문(Conditional Statement)
**조건문**은 특정 조건을 만족했을 때만 실행되는 코드를 작성하기 위한 문법이다. 대표적으로 `if`, `switch` 조건문이 존재한다. **if**문은 `if`-`else if`-`else`로 사용할 수 있고, **switch문**은 if문과 기능 자체는 동일하지만 다수의 조건을 처리할 때는 if문보다 더 직관적이다.

```js
let var = "Happy"

switch (var) {
  case "Happy": {
    console.log("Good");
    break;
  }
  case "Sad": {
    console.log("Bad");
    break;
  }
  default: {
    console.log("I don't know");
  }
}
```

## 반복문(Loop, Iteration)
**반복문**은 어떠한 동작을 반복해서 수행할 수 있도록 만들어주는 문법이다. 반복문에는 `for` 반복문이 있다.

`for(초기값; 조건; 반복될 때마다 실행되는 코드) { 반복될 내용 }`

## 함수(Funtion)
코드를 작성하다 보면 중복으로 작성된 코드와 유사한 기능을 하는 코드들이 있다. 이는 코드 유지관리를 어렵게 할 뿐만 아니라 개발자의 작업량도 늘어난다. 그래서 함수를 사용하면 위 문제를 해결할 수 있다.

### 함수 표현 방식
#### 함수 선언문
함수의 선언은 다음과 같이 할 수 있다.

`function func(arg1, arg2) { 내용 }`

JavaScript 언어의 특징 중 하나는 **호이스팅(Hoisting)** 기능이 있다. 호이스팅이란 함수 안에 있는 선언들을 모두 끌어올려서 해당 함수 유효 범위의 최상단에 선언하는 것이다.

```js
let area1 = getArea(19, 99);
console.log(area1);

let area2 = getArea(8, 13);
console.log(area2)

function getArea(width, height) {
  let area = Width * height;
  return area;
}
```

위의 코드처럼 함수 정의하는 방법은 함수 선언문이 있고, 함수 선언문과 다르게 함수 정의하는 방법은 **함수 표현식**과 **화살표 함수**가 있다.

#### 함수 표현식
**함수 표현식**은 함수 선언과 달리 **변수에 함수를 할당**하는 방식이다.

```js
function funcA() { 내용 }
let varA = funA;
varA();
let varB = function () { 내용 };
varB();
```

여기서 중요한 점은 함수 표현식으로 만들어진 함수들은 호이스팅의 대상이 되지 않는다.

#### 화살표 함수
**화살표 함수**는 ES6에서 도입된 새로운 함수 표현식의 방법으로, 더 간결한 문법을 제공한다.

```js
let varA = () => { 내용 };
varA();
```

### 콜백 함수(Callback Function)
**콜백 함수**는 자신이 아닌 다른 함수에, 인수로써 전달된 함수이다. 콜백 함수를 사용하면 중복 코드를 제거하면서 굉장히 간결하게 코드를 작성할 수 있기 때문에 콜백 함수를 자주 사용한다.

```js
function main(value) {
  value();
}

main(() => {
  console.log("Sub");
});
```

## 스코프(Scope)
**스코프**는 변수나 함수에 접근하거나 호출할 수 있는 범위이다. 스코프는 **전역 스코프**와 **지역 스코프**가 있다.

* 전역 스코프: 전체 영역에서 접근 가능
* 지역 스코프: 특정 영역에서만 접근 가능

**함수 선언식**은 특이하게 블록 스코프를 갖지 않는다. 즉 조건문이나 반복문 내에 있어도 해당 블록 내에서만 제한되지 않고, 블록 외부에서도 접근할 수 있다.

## Ref
[1] [한입 크기로 잘라 먹는 리액트(React.js) : 기초부터 실전까지](https://www.inflearn.com/course/%ED%95%9C%EC%9E%85-%EB%A6%AC%EC%95%A1%ED%8A%B8)

[2] [[JavaScript] 호이스팅(Hoisting)이란](https://gmlwjd9405.github.io/2019/04/22/javascript-hoisting.html)