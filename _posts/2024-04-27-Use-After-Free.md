---
title: Use After Free
date: 2024-04-27 06:00:00 +0900
categories: [0x01. InfoSec, 0x00. Pwnable]
tags: [Pwnable, UAF]
math: true
mermaid: true
---
**Use After Free**는 <u>메모리 참조에 사용한 포인터를 메모리 해제 후 적절히 초기화하지 않아서</u>, 또는 <u>해제한 메모리를 초기화하지 않고 다음 청크에 재할당</u>해주면서 발생하는 취약점이다. 

**Dangling Pointer**는 유효하지 않은 메모리 영역을 가리키는 포인터이다. 동적할당(`malloc`) 후 해제(`free`)를 할 때, `free`는 청크를 할당자(ptmalloc2)에 반환하기만 하고 청크의 주소를 담고 있는 포인터를 초기화하지 않는다. 이때 해당 포인터를 초기화하지 않으면, 포인터는 해제된 청크를 가리키는 Dangling Pointer가 된다.

Dangling Pointer가 위험한 이유는 프로그램이 예상치 못한 동작을 할 가능성을 일으킬 수 있고, 공격 벡터가 될 수 있기 때문이다.

## Ref
[1] [드림핵 시스템 해킹 강의 Use After Free](https://dreamhack.io/lecture/roadmaps/2)