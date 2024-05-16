---
title: Format String Bug
date: 2024-04-14 06:30:00 +0900
categories: [0x1. Pwnable, 0x0. Pwn Theory]
tags: [Pwnable, FSB]
math: true
mermaid: true
---
## Format String Bug
**Format String Bug(FSB)**는 포맷 스트링이 필요로 하는 인자의 개수와 함수에 전달된 인자의 개수를 비교하는 루틴점을 악용하여 발생하는 버그이다. 이를 악용하면 해당 프로그램의 레지스터와 스택을 읽을 수 있고, 임의 주소 읽기 및 쓰기를 할 수 있다.

> 포맷 스트링 버그는 포맷 스트링을 사용하는 모든 함수(ex. `printf`)에서 발생할 수 있다.
{: .prompt-tip }

## Ref
[1] [드림핵 시스템 해킹 강의 Format String Bug](https://dreamhack.io/lecture/roadmaps/2)
