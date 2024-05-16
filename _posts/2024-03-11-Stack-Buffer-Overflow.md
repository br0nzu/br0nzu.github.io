---
title: Stack Buffer Overflow
date: 2024-03-11 20:50:00 +0900
categories: [0x1. Pwnable, 0x0. Pwn Theory]
tags: [Pwnable, Stack Buffer Overflow]
math: true
mermaid: true
---
**스택 버퍼 오버플로우**란 스택의 버퍼에서 발생하는 오버플로우다.

스택 버퍼 오버플로우가 발생하면 **<U>중요 데이터 변조, 데이터 유출, 실행 흐름 조작</U>** 등의 문제점들이 발생할 수 있다.
* **중요 데이터 변조**: 버퍼 오버플로우가 발생하는 버퍼 뒤에 중요한 데이터가 있다면, 해당 데이터가 변조
* **데이터 유출**: 다른 버퍼와의 사이에 있는 널바이트를 모두 제거하면, 해당 버퍼를 출력시켜서 다른 버퍼의 데이터를 읽을 수 있음
* **실행 흐름 조작**: 함수를 호출할 때 반환 주소를 스택에 쌓고, 함수에서 반환될 때 이를 꺼내어 원래의 실행 흐름으로 돌아갈 때 반환 주소를 조작하면 프로세스의 실행 흐름을 바꿀 수 있음

## Ref
[1] [드림핵 시스템 해킹 강의 Stack Buffer Overflow](https://dreamhack.io/lecture/roadmaps/2)