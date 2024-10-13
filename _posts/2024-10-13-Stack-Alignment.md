---
title: "[Linux] Stack Alignment"
date: 2024-10-13 15:00:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [Linux]
math: true
mermaid: true
---
문제를 풀다가 `system("/bin/sh")`을 잘 호출했는데 익스가 안되는 경우가 있다.

```sh
<do_system+115>    movaps xmmword ptr [rsp], xmm1
```

여기서 익스가 안되어서 원인을 찾다보니 **Stack Alignment** 문제라는 것을 알게 되었다. 이미 [[Research] x64 stack alignment](https://hackyboiz.github.io/2020/12/06/fabu1ous/x64-stack-alignment/#MOVAPS) 여기서 언급한거 처럼 Ubuntu 18.04부터 `do_system()`에 `movaps`인스트럭션이 추가되어서 Stack Alignment를 지켜주지않으면 코드가 실행되지 않는다.

## Stack Alignment
**Stack Alignment**은 `rsp`의 메모리 주소가 16배수로 유지된 상태이고, `rsp`의 위치가 정해지는 규칙(프로그램의 흐름이 함수의 Entry로 옮겨지는 시점에선 `rsp`+8이 항상 16의 배수 등)을 지켜야 한다.

간단히 정리하면 다음과 같다.

- `call` 실행 직전 `rsp`는 16의 배수 (Stack Alignment O)
- 함수의 Entry Point에선 `rsp`+8이 16의 배수 (Stack Alignment X)
- 함수의 프롤로그 실행 후 `rsp`는 16의 배수 (Stack Alignment O)
- **`rbp`는 항상 16의 배수 (Stack Alignment O)**

여기서 생각해야할 것은 '왜 함수 Entry Point에서는 `rsp`+8이 16의 배수가 되어야 하는지'이다. 이를 위해서는 `call` 명령어를 알아야 한다.

`call` 명령어는 두 가지 동작을 수행한다. 먼저, 돌아올 주소를 저장하기 위해 현재 명령어의 다음 주소를 스택에 `push`한다. 그리고 `jmp` 명령어를 통해 해당 함수의 주소로 이동하여 함수를 호출한다. 이렇게 되면 `rsp`는 8만큼 감소하기 때문에 함수의 Entry Point에선 `rsp`+8이 16의 배수가 되어야 한다.

그 다음, 함수 프롤로그로 인해 `rsp`는 8이 증가하고 `rsp`는 16의 배수가 된다. 또한 함수 프롤로그에서 `rbp`는 `rsp`의 값을 들고오기 때문에 `rbp`는 항상 16의 배수가 된다.

마지막으로 에필로그에서는 `leave`와 `ret`동작을 하게 된다. `leave`로 인해 `rsp`는 8이 증가하고, `ret`으로 인해 다시 8이 증가한다. 하지만 보통 익스플로잇 코드를 작성하게 되면 `ret`을 덮는 경우가 대부분이고, `ret`으로 변조된 함수를 호출하기 때문에 Stack Alignment가 깨진다. 그래서 `do_system()`에서 `movaps`명령어를 만나면 **segmentation fault**가 나타나고 익스플로잇을 하지 못한다.

Stack Alignment의 개념과 Stack Alignment가 깨지는 경우에 대해 설명했다. 이제 Stack Alignment를 맞춰주기 위해서는 익스플로잇 코드에 **`ret` 가젯**을 하나 더 추가해서 `rsp`를 조정해주면 된다.

```py
...
payload = ...
payload += b"B" * 0x8
payload += p64(ret)         # Stack Alignment
payload += p64(get_flag)
...
```

## Etc..
Stack Alignment가 필요한 주요 이유는 메모리의 Access Cycle을 최소한으로 줄여 Performance를 높이기 위함이다. 

Stack Alignment가 필요한 명령어는 주로 **SSE(Single Instruction, Multiple Data)**와 **AVX(Advanced Vector Extensions)** 명령어이다.

- SSE 명령어: `movaps`, `movapd`, `movdqa`등
- AVX 명령어: `vmovaps`, `vmovapd`, `vmovdqa`등

## Ref
[1] [[Research] x64 stack alignment](https://hackyboiz.github.io/2020/12/06/fabu1ous/x64-stack-alignment/#MOVAPS)

[2] [Stack Alignment](https://ir0nstone.gitbook.io/notes/binexp/stack/return-oriented-programming/stack-alignment)

[3] [Stack Alignmnet in x86-64](https://velog.io/@c4fiber/Stack-Alignmnet-in-x86-64)

[4] [Intel Documentation Library](https://www.intel.com/content/www/us/en/developer/tools/documentation.html)