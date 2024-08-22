---
title: Use After Free
date: 2024-04-27 06:00:00 +0900
categories: [0x01. InfoSec, 0x00. Pwnable]
tags: [Pwnable, UAF]
math: true
mermaid: true
---
**Use After Free**는 메모리 참조에 사용한 포인터를 메모리 해제 후 적절히 초기화하지 않아서, 또는 해제한 메모리를 초기화하지 않고 다음 청크에 재할당해주면서 발생하는 취약점이다. 이때 초기화하지 않은 포인터를 **Dangling Pointer**라고 한다. Dangling Pointer는 프로그램이 예상치 못한 동작을 할 가능성이 있기 때문에 유의해야 한다.

> `malloc`과 `free`는 할당 또는 해제할 메모리의 데이터를 초기화하지 않는다.
{: .prompt-info }

## Ref
[1] [드림핵 시스템 해킹 강의 Use After Free](https://dreamhack.io/lecture/roadmaps/2)