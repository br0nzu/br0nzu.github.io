---
title: PLT & GOT
date: 2024-03-27 19:00:00 +0900
categories: [0x00. Computer Science, 0x00. CS Theory]
tags: [PLT, GOT]
math: true
mermaid: true
---
[Library & Link](/posts/Library-and-Link)에 이어서 PLT와 GOT 설명을 하겠다.
## PLT & GOT
**PLT(Procedure Linkage Table)**는 동적 링커가 공유 라이브러리의 함수를 호출하기 위한 코드가 저장되어 있고, **GOT(Global Offset Table)**는 동적 링커에 의해 공유 라이브러리에서 호출할 함수의 주소가 저장되어 있다. 즉, **PLT**와 **GOT**는 라이브러리에서 동적 링크된 심볼의 주소를 찾을 때 사용하는 테이블이다.

동적 링킹된 바이너리는 함수의 주소를 라이브러리에서 찾아야 하는데, ASLR이 적용된 환경에서는 라이브러리가 임의의 주소에 매핑된다. 이 상태에서 라이브러리 함수를 호출하면, 함수의 이름을 바탕으로 라이브러리에서 심볼들을 탐색하고, 해당 함수의 정의를 발견하면 그 주소로 실행 흐름을 옮기게 된다. 이 과정을 통틀어 `runtime resolve`라고 한다.

이러한 과정이 반복되는 것은 비효율적이다. 그래서 ELF는 GOT라는 테이블을 두고, resolve된 함수의 주소를 해당 테이블에 저장한다. 그리고 나중에 다시 해당 함수를 호출하면 저장된 주소를 꺼내서 사용한다.

```c
// Name: test.c
// Compile: gcc -o test test.c -no-pie

#include <stdio.h>

int main() {
  puts("Resolving address of 'puts'.");
  puts("Get address from GOT");
}
```

위 코드를 컴파일하여 gdb로 확인해본다.

```bash
$ gdb ./test
pwndbg> p puts
$1 = {<text variable, no debug info>} 0x401040 <puts@plt>
pwndbg> r
...
pwndbg> p puts
$2 = {int (const char *)} 0x7ffff7c80e50 <__GI__IO_puts>
```
함수 호출 전(PLT)과 후(GOT)의 주소가 다르고, 두 번째 호출부터는 puts함수의 주소(`0x7ffff7c80e50`)를 가리키고 있는 것을 알 수 있다.

따라서 동적 링킹된 바이너리에서 함수를 호출할 때, PLT로 이동하여 GOT에 해당 함수가 계산된 주소가 있는지 확인한다. 만약 없다면 `_dl_runtime_resolve`로 함수 주소를 계산하여 GOT에 저장한다.

## 시스템 해킹의 관점에서 본 PLT와 GOT
시스템 해커의 관점에서 보면 PLT에서 GOT를 참조하여 실행 흐름을 옮길 때, **GOT의 값을 검증하지 않는다는 보안상의 약점**이 있다. 만약 위의 예시코드에서 puts의 GOT 엔트리에 저장된 값을 공격자가 임의로 변경할 수 있으면, puts가 호출될 때 공격자가 원하는 코드가 실행되게 할 수 있다.

```bash
$ gdb ./test
pwndbg> b *main+33
pwndbg> r
...
pwndbg> got
GOT protection: Partial RELRO | Found 1 GOT entries passing the filter
[0x404018] puts@GLIBC_2.2.5 -> 0x7ffff7c80e50 (puts) ◂— endbr64

pwndbg> set *(unsigned long long *)0x404018 = 0x4141414141414141

pwndbg> got
GOT protection: Partial RELRO | Found 1 GOT entries passing the filter
[0x404018] puts@GLIBC_2.2.5 -> 0x4141414141414141 ('AAAAAAAA')
...
pwndbg> c
Continuing.

Program received signal SIGSEGV, Segmentation fault.
0x0000000000401044 in puts@plt ()
```

위와 같이 GOT 엔트리에 임의의 값을 넣어서 실행흐름을 변조하는 공격 기법을 **GOT Overwrite**라고 한다. 

## Ref
[1] [드림핵 시스템 해킹 강의 Mitigation: NX & ASLR](https://dreamhack.io/lecture/roadmaps/2)