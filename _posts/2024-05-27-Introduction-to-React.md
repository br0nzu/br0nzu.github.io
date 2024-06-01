---
title: Introduction to React.js
date: 2024-05-27 01:30:00 +0900
categories: [0x6. Development, 한 입 크기로 잘라먹는 리액트]
tags: [Dev, Front, React.js]
math: true
mermaid: true
---
## React.js
**React.js**는 Meta가 개발한 오픈소스 JavaScript 라이브러리이다. React.js는 대규모 웹 서비스의 **UI**를 더 편하게 개발하기 위해 만들어진 기술이다. React.js로 만들어진 서비스는 넷플릭스, 페이스북, 인스타그램, 노션 등이 있다.

## React.js 기술적인 특징
React.js의 기술적인 특징은 다음과 같다.
* 컴포넌트 기반으로 UI를 표현
* 화면 업데이트 구현이 쉬움
* 화면 업데이트가 빠르게 처리됨

### 컴포넌트 기반으로 UI를 표현
![Component](/assets/img/240527/Component.png)

**컴포넌트(Component)**는 구성요소라는 뜻으로 React.js에서는 화면을 구성하는 요소, UI를 구송하는 요소라고 한다. 컴포넌트를 기반으로 UI를 표현하면 중복 코드를 줄일 수 있어 유지보수에 용이하다.

### 화면 업데이트 구현이 쉬움
**업데이트(Update)**는 사용자의 행동(클릭, 드래그 등)에 따라 웹 페이지가 스스로 모습을 바꿔 상호작용하는 것이다. React.js는 **선언형 프로그래밍**이기 때문에 화면 업데이트를 구현하기가 쉽다.

![Programming](/assets/img/240527/Programming.png)

**선언형 프로그래밍**이란 과정은 생략하고 목적만 간결히 명시하는 방법이다. 이와 반대로 명령형 프로그래밍이 있다. **명령형 프로그래밍**은 목적을 이루기 위한 일련의 과정을 설명하는 방식이다. 즉, 모든 과정을 하나 하나 다 설명하는 것이다.

![State](/assets/img/240527/State.png)

**선언형 프로그래밍**의 특징은 업데이트를 위한 복잡한 동작을 직접 정의할 필요 없이 특정 변수의 값을 바꾸는 것만으로도 화면을 업데이트 시킬 수 있다.

### 화면 업데이트가 빠르게 처리됨
React.js는 화면 업데이트를 쉽게 구현할 수 있으면서 동시에 빠르게 처리한다. 이를 이해하기 위해서는 브라우저 동작과 HTML, CSS로 만든 페이지의 렌더링 과정, 화면 업데이트 처리를 알아야 한다.

![Critical Rendering Path](/assets/img/240527/Critical Rendering Path.png)

위 사진은 브라우저 렌더링 과정이다. 웹 페이지를 렌더링 하기 위해 꼭 거쳐야만 하는 중요한 경로라서 Critical Rendering Path라고 불린다.

먼저 첫 단계에서는 HTML과 CSS를 각각 DOM이라는 것과 CSS Object Model이라는 것으로 변환을 하게 된다.

![DOM](/assets/img/240527/DOM.png)

`DOM`은 HTML의 코드를 브라우저가 더 이해하기 쉬운 방식으로 변환하는 객체를 말한다. CSSOM도 비슷한 역할을 한다. 이렇게 DOM과 CSSOM을 합쳐서 `Render Tree`를 만든다.

![Render Tree](/assets/img/240527/Render Tree.png)

DOM과 CSSOM을 합쳐서 만든 것이 `Render Tree`기 때문에, `Render Tree`는 웹 페이지의 청사진의 역할을 한다. 이렇게 Render Tree가 만들어지면 Layout 작업을 수행한다. `Layout`은 요소들을 배치하는 과정이다. 마지막으로 `Painting`은 요소를 실제 화면에 나타내는 과정이다. 이러한 과정들이 브라우저를 렌더링하는 과정이다.

이제 업데이트 과정을 살펴보자

![Update](/assets/img/240527/Update.png)

**화면의 업데이트는 JavaScript가 DOM을 수정하면 발생한다.** DOM이 수정되면 Critical Rendering Path의 전체 단계를 다시 진행한다. 여기서 Layout과 Painting과정이 오래 걸린다. 그렇기 때문에 Layout을 다시 하는 것을 **Reflow**라고 하고, Painting을 다시 하는 것을 **Repaint**라 한다. 위 사진처럼 3000번의 수정이 있다면 렌더링 과정이 매우 악화되고 심하면 브라우저에서 응답없음 페이지가 나타난다.

![React Update](/assets/img/240527/React Update.png)

React.js가 화면의 업데이트가 빠르게 처리되는 이유는 **Virtual DOM**이라는 가상의 DOM을 이용하여 업데이트가 발생하면 실제 DOM을 바로 수정하는 것이 아니라 Virtual DOM을 이용하여 먼저 수정하고, 업데이트 요소들이 다 모이면 한번에 DOM을 수정하기 때문이다.
>  **Virtual DOM**은 DOM을 JavaScript 객체로 흉내낸 것으로 일종의 복제판이다.
{: .prompt-info }

## React App 생성
React.js로 만든 웹 서비스들은 보통 React App이라고 불린다. 그 이유는 React.js로 만들어진 대다수의 웹 서비스들은 단순한 웹 페이지의 기능을 넘어서 어플리케이션과 같은 기능을 제공하기 때문이다.

React Aoo을 생성하기 위해서는 다음과 같은 과정이 필요하다.
* Node.js 패키기 생성
* React 라이브러리 설치
* 기타 도구 설치 및 설정

이 모든 과정을 해주는 **Vite**라는 차세대 프론트엔드 개발 도구가 있다. Vite의 설치는 `npm create vite@lateset`를 하면 된다. `package.json`을 보면 필요한 라이브러리들이 어떤 것들이 있는지 확인할 수 있고, 패키지와 모듈이 설치가 되어 있지 않아 `npm i`로 설치하면 된다. 수많은 파일들이 생성되었는데 각 파일이 어떤 역할을 하는지 알아보자

* `public`: 이미지 파일들을 보관하거나 정적인 파일들(폰트, 동영상 등)을 보관하는 저장소이다.
* `src`: 소스의 약자로 리액트나 자바스크립트 코드들을 보관하는 폴더이다.
  * .jsx: 리액트에서 사용되는 특수한 확장자
* `.eslintrc`: 개발자들 사이에 코드 스타일을 통일하는 데에 도움을 주는 도구
* `.gitignore`: GitHub 같은 곳에 업로드할 때 올리면 안되는 파일들을 명시하는 곳
* `index.html`: 리액트 앱의 기본 틀 역할
* `vite.config.js`: Vite 도구의 옵션을 설정하는 파일

이러한 폴더와 파일 이외에도 여러가지 폴더와 파일들이 있다.

## Ref
[1] [한입 크기로 잘라 먹는 리액트(React.js) : 기초부터 실전까지](https://www.inflearn.com/course/%ED%95%9C%EC%9E%85-%EB%A6%AC%EC%95%A1%ED%8A%B8)