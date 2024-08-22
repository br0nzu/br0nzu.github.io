---
title: Basics of React.js
date: 2024-06-02 00:00:00 +0900
categories: [0x04. Development, 한 입 크기로 잘라먹는 리액트]
tags: [Dev, Front, React.js]
math: true
mermaid: true
---
이전 시간에는 [리액트 소개](/posts/Introduction-to-React)를 했다면, 이번 게시물은 리액트 입문을 설명할 것이다. 우선 리액트에서 **컴포넌트**는 HTML 코드를 반환하는 코드로 컴포넌트의 변수명 첫 글자는 반드시 **대문자**여야 한다.

## JSX - UI 표현
**JSX(JavaScript Extensions)**는 확장된 자바 스크립트 문법이다. JavaScript에서는 다음과 같은 코드를 문법적인 오류로 판단하지만, React.js에서는 JSX문법을 사용하므로 아래 코드를 적법하다고 판단한다.

```react
funtion Footer() {
  return (
    <footer>
      <h1>footer</h1>
    </footer>
  );
}
```

즉, React.js에서는 JavaScript 문법과 HTML 문법을 함께 사용할 수 있다. JSX 문법의 주의사항은 다음과 같다.

* 중괄호 내부에는 자바스크립트 표현식(값, 변수 이름, 연산식 등)만 넣을 수 있다.
* 숫자형, 문자열, 배열 값만 렌더링 된다. 즉, null, undefined, boolean 값들은 화면에 렌더링되지 않는다.
* 모든 태그는 닫혀 있어야 한다.
* 최상위 태그는 반드시 하나이다.

또한, React.js에서 CSS를 설정하는 방법은 크게 인라인 스타일 설정과 CSS 파일 import가 있다. **인라인 스타일 설정**은 컴포넌트 내에서 직접 스타일을 정의하는 방법이다. 각 스타일 속성을 camelCase로 지정한다.

```react
funtion Footer() {
  const footerStyle = {
    backgroundColor: "blue",
  }

  return (
    <footer style={footerStyle}>
      <h1>footer</h1>
    </footer>
  );
}
```

CSS 파일 import는 CSS 파일을 작성하여 React 컴포넌트에 CSS 파일을 import하면 된다.

아래는 JSX 문법의 예시이다.

```react
function App() {
  const number = 99;
  const string = "Hello, world!";
  const arr = ['DJ', 'Dongpago2', 'br0nzu'];
  const element = <h2>React</h2>;
  const nullValue = null;

  const styles = {
    numberStyle: {
      color: 'red',
      fontSize: '20px',
    };

  return (
    <div>
      <p style={styles.numberStyle}>{number}</p>  // 99 렌더링
      <p>{string}</p>  // "Hello, world!" 렌더링
      <ul>
        {array.map(item => <li key={item}>{item}</li>)}  // 각 배열 요소가 <li>로 렌더링
      </ul>
      <div>{element}</div>  // <h2>React</h2>가 렌더링
      <p>{nullValue}</p>  // 아무것도 렌더링되지 않음
    </div>
  );
}
```

## Props
**Props**는 부모 컴포넌트가 자식 컴포넌트에 데이터를 전달하기 위해 사용하는 객체이다. 아래는 props를 사용한 예제이다.

```react
function Hi(props) {
  return <h1>Hello, {props.name}!</h1>;
}

function App() {
  return (
    <div>
      <Hi name="DJ" />
      <Hi name="br0nzu" />
    </div>
  );
}

export default App;
```

부모 컴포넌트는 `APP`이고, 자식 컴포넌트는 `Hi`이다.

## 이벤트 핸들링(EventHandling)
**이벤트 핸들링(EventHandling)**은 이벤트가 발생했을 때 그것을 처리하는 동작이다. 예를 들어,버튼 클릭시 경고창이 나타나는 동작을 구현할 수 있다.

여러 가지 브라우저가 존재하며, 브라우저마다 이벤트 핸들링 방식이 다를 수 있다. 이러한 차이로 인해 다양한 브라우저에서 동일한 동작을 구현할 때 **크로스 브라우징 이슈(Cross Browsing Issue)**가 발생할 수 있다. 이는 브라우저마다 이벤트 객체의 스펙이 다르기 때문이다.

**합성 이벤트(Synthetic Event)**는 모든 웹 브라우저의 이벤트 객체를 하나로 통일한 형태이다. React는 합성 이벤트 시스템을 사용하여 브라우저 간의 차이를 추상화하고 일관된 API를 제공함으로써, 크로스 브라우징 이슈를 줄이고 개발자가 보다 쉽게 이벤트를 다룰 수 있게 한다.

## 상태 관리
리액트 컴포넌트는 State(상태) 값에 따라 렌더링 되는 UI가 결정된다. 기본 사용법은 `useState`을 사용하여 함수형 컴포넌트에서 상태를 선언하고, 그 상태를 업데이트할 수 있다.

```react
import React, { useState } from 'react';

function Counter() {
  // count라는 상태 변수와 이를 갱신할 setCount 함수를 선언
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

export default Counter;
```

여기서 상태나 props가 변경될 때, 해당 컴포넌트를 다시 그리는 과정을 **리렌더링**이라 한다.

## useRef
**`useRef`**는 새로운 Reference 객체를 생성하는 기능이다. `useRef`와 `useState`의 차이점은 다음과 같다.

![](/assets/img/240602/useRef useState.png)

`useRef` 주로 다음과 같은 경우에 사용된다.

* DOM 요소에 직접 접근: 포커스 설정, 스크롤 위치 조정, 특정 요소의 치수 읽기 등
* 리렌더링 간에 변하지 않는 값을 저장: 컴포넌트가 리렌더링되어도 참조 값은 유지
* 값 변경을 감지: 이전 값과 비교하여 변화가 발생했는지 확인

## React Hook
**React Hook**은 클래스 컴포넌트 기능을 함수 컴포넌트에서도 이용할 수 있도록 하는 것이다. React Hook의 대표적인 예시는 useState와 useRef이다. React Hook은 이름 앞에 동일한 접두사 **use**가 붙는다. 또한, 각각의 메서드는 Hook이라고 부른다.

React Hook과 관련된 주의사항은 다음과 같다.

* 함수 컴포넌트, 커스텀 훅 내부에서만 호출 가능 
* 조건부(조건문, 반복문 등)로 호출될 수 없음
* Custom Hook을 직접 만들 수 있음

Hook은 보통 hook 파일에 따로 저장해서 import 한다.

## 라이프사이클
라이프사이클은 생명주기이다. 리액트에서 라이프사이클은 총 세 단계로 나뉜다.

![Lifecycle](/assets/img/240602/Lifecycle.png)

* **Mount**: 컴포넌트가 탄생하는 순간으로, 화면에 처음 렌더링 되는 순간
* **Update**: 컴포넌트가 다시 렌더링 되는 순간
* **UnMount**: 컴포넌트가 사라지는 순간으로 렌더링에서 제외 되는 순간

## useEffect
**`useEffect`**는 리액트 컴포넌트의 사이드 이펙트[^footnote]를 제어하는 Hook이다. `useEffect`는 두 개의 매개변수를 받는다. 첫 번째 매개변수는 수행할 작업을 정의하는 함수를 사용한다. 두 번째 매개변수는 의존성 배열[^fn-nth-2]로, 이 배열에 포함된 값이 변경될 때만 첫 번째 매개변수로 전달된 함수가 실행된다.

**클린업 함수(정리 함수)**는 `useEffect` 내에서 반환되는 함수로, 주로 컴포넌트가 언마운트되기 전에 정리 작업을 수행하는 데 사용된다. 이는 주로 타이머를 제거하거나, 구독을 취소하거나, 기타 리소스를 정리하는 데 유용하게 사용된다.

다음은 `useEffect`를 사용한 예시이다.

```react
import React, { useState, useEffect } from 'react';

function ExampleComponent() {
  const [count, setCount] = useState(0);
  const [data, setData] = useState(null);

  // 마운트 - 데이터 가져오기
  useEffect(() => {
    console.log('Component did mount');

    // 타임아웃 데이터 가져오기
    const fetchData = async () => {
      const response = await fetch('https://jsonplaceholder.typicode.com/todos/1');
      const result = await response.json();
      setData(result);
    };

    fetchData();

    // 언마운트 - 타이머 정리
    return () => {
      console.log('Component will unmount');
    };
  }, []);

  // 업데이트 - 로그 출력
  useEffect(() => {
    console.log('Component did update');
  }, [count]);

  return (
    <div>
      <h1>useEffect Example</h1>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <div>
        <h2>Fetched Data:</h2>
        {data ? <pre>{JSON.stringify(data, null, 2)}</pre> : 'Loading...'}
      </div>
    </div>
  );
}

export default ExampleComponent;
```

## Ref
[1] [한입 크기로 잘라 먹는 리액트(React.js) : 기초부터 실전까지](https://www.inflearn.com/course/%ED%95%9C%EC%9E%85-%EB%A6%AC%EC%95%A1%ED%8A%B8)

## Footnote
[^footnote]: **사이드 이펙트**: 컴포넌트 동작에 따라 파생되는 여러 효과

[^fn-nth-2]: **의존성 배열**: dependency array라고 하며, 보통 deps로 많이 불린다.