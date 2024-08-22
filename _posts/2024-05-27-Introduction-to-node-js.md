---
title: Introduction to Node.js
date: 2024-05-27 01:00:00 +0900
categories: [0x04. Development, 한 입 크기로 잘라먹는 리액트]
tags: [Dev, Front, Node.js]
math: true
mermaid: true
---
## Node.js
`Node.js`를 배워야하는 이유는 `React.js`, `Next.js`, `Vue.js` 등의 기술들은 `Node.js`의 기반으로 동작하는 기술이다.

![Node.js](/assets/img/240527/Node-js.png)

`Node.js`는 웹 브라우저가 아닌 환경에서도 자바스크립트 코드를 실행시켜주는 **자바스크립트의 실행 환경**이다.

Node.js를 알기 위해서는 JavaScript를 알아야 하는데, **JavaScript**는 웹 페이지 내부에 필요한 아주 단순한 기능만을 개발하기 위해 만들어졌다. JavaScript는 유연하고 작성하기가 편리하다. 그래서 많은 사람들이 JavaScript로 웹 페이지 내부의 기능을 만드는 걸 넘어서 웹 브라우저 바깥에서도 자바스크립트를 이용해서 프로그램을 만들고 싶어했다. 따라서 JavaScript를 기반으로 만들어진 프로그램들이 많이 개발되었고, JavaScript는 어디서든 동작할 수 있는 범용적인 언어가 되었다.

## Node.js 설치
Node.js를 설치하기 위해서는 [Node.js 설치](https://nodejs.org/en)에 접속하여 LTS 버전을 다운받으면 된다.

Node.js확인은 터미널 창에 `node -v`쳐서 node.js 버전이 나오면 된다. 또한, NPM이 설치되어 있는지 확인해야한다. **NPM(Node Package Manager)**이란 자바스크립트 패키지를 설치, 공유 및 관리할 수 있게 해주는 도구이다. Node.js가 정상적으로 설치 되어있다면 NPM도 정상적으로 설치가 되어있어야 한다. 확인 방법은 `npm -v`이고, 나오지 않는다면 Node.js를 삭제하고 재설치해야 한다.

## Node.js 사용
Node.js가 설치가 되었다면 `npm init`으로 패키지를 설치하고 실행하고 싶은 JavaScript 파일을 `node filename.js`로 실행시키면 된다.
> Node.js에서 **패키지**는 Node.js에서 사용하는 프로그램의 단위이다.
{: .prompt-tip }

## Node.js 모듈 시스템
**모듈 시스템(Module System)**은 모듈을 생성하고 불러오고, 사용하는 등의 모듈을 다루는 다양한 기능을 제공하는 시스템이다. 모듈의 필요성은 유지보수가 용이하고 재사용성이 좋아 모듈을 사용하면 개발 효율이 높아진다. JavaScript에는 CJS, ESM, AMD, UMD 등의 모듈 시스템이 있고 모듈 시스템은 하나만 사용 가능하다.

### CommonJS(CJS)
CJS 모듈 문법은 다음과 같다.
* 모듈 내보내기: `module.exports` 또는 `exports`
* 모듈 가져오기: `require()`

```js
// math.js
// export function add()
function add(a, b) {
  return a + b;
}
// export function sub()
function sub(a, b) {
  return a - b;
}

module.exports = {
  add,
  sub
};
```

```js
// index.js
const math = require('./math.js'); // 파일 확장자 생략 가능

console.log(math.add(1, 2));      
console.log(math.sub(1, 2));
```

### ECMAScript Modules(ESM)
ESM은 JavaScript의 표준 모듈 시스템으로, 브라우저와 Node.js 모두에서 사용할 수 있다. ESM을 사용하기 위해서는 `package.json`파일에 `"type": "module"`을 설정해야 하고, ESM 모듈 문법은 다음과 같다.
* 모듈 내보내기: `export` 또는 `export default`
* 모듈 가져오기: `import`

```js
// math.js
export function add(a, b) {
  return a + b;
}

export function sub(a, b) {
  return a - b;
}

export default function multiply(a,b) {
    return a * b;
}
```

```js
// index.js
import mul, { add, sub } from './math.js'; // 파일 확장자 생략 불가

console.log(add(1, 2));       
console.log(sub(1, 2));
console.log(mul(1,2));
```

`export default`는 해당 모듈이 기본적으로 내보내는 값을 정의할 수 있다.

## Node.js 라이브러리
**라이브러리**는 프로그램을 개발할 때 필요한 다양한 기능들을 미리 만들어 모듈화 해 놓은 것이다. [npm 라이브러리](https://www.npmjs.com/)에서 라이브러리를 검색하여 설치할 수 있다. 설치가 되었다면 `node_modules` 폴더와 `package-lock.json` 파일이 생성된다. `node_modules`에는 설치한 라이브러리가 실제로 저장되는 곳이고, `package-lock.json`는 버전이나 정보를 `package.json`보다 더 정확하고 엄밀하게 저장하는 파일이다. 

라이브러리를 불러오고 싶으면 보통 `import 변수 from "module_name"`으로 불러올 수 있다. 라이브러리 값을 가져올 때는 경로를 명시하는 것이 아니라 from뒤에 라이브러리의 이름만 명시하면 된다.

마지막으로 `node_modules` 폴더와 `package-lock.json` 파일이 삭제되었다면, `npm install` 혹은 `npm i`입력하면 다시 설치가 된다. 이는 원래 파일인 `package.json`의 dependencies의 정보를 기준으로 모든 패키지와 라이브러리를 다시 설치한다. 

보통 GitHub 또는 누군가에게 공유할 때, `node_modules` 폴더를 포함하지 않는다. `package.json`만 정삭적으로 있다면 언제든 다시 설치할 수 있고, `node_modules` 폴더는 용량이 크기 때문이다.

## Ref
[1] [한입 크기로 잘라 먹는 리액트(React.js) : 기초부터 실전까지](https://www.inflearn.com/course/%ED%95%9C%EC%9E%85-%EB%A6%AC%EC%95%A1%ED%8A%B8)

[2] [Node.js 설치](https://nodejs.org/en)

[3] [npmjs](https://www.npmjs.com/)