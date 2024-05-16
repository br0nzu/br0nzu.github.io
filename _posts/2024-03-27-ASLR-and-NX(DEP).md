---
title: ASLR & NX(DEP)
date: 2024-03-27 15:00:00 +0900
categories: [0x1. Pwnable, 0x0. Pwn Theory]
tags: [Pwnable, ASLR, NX(DEP)]
math: true
mermaid: true
---
## ASLR
**ASLR(Address Space Layout Randomization)**은 바이너리가 실행될 때마다 *스택, 힙, 공유 라이브러리* 등을 임의의 주소에 할당(주소 + @)하는 보호기법이다.

ASLR은 커널에서 보호하는 기법이며 다음 명령어로 키고 끌 수 있다.
* On
   * Conservative Randomization + bp:
   
   `echo 2 | sudo tee /proc/sys/kernel/randomize_va_space`
   * Conservative Randomization: `echo 1 | sudo tee /proc/sys/kernel/randomize_va_space`
* Off: `echo 0 | sudo tee /proc/sys/kernel/randomize_va_space`
* 확인: `cat /proc/sys/kernel/randomize_va_space`

### 특징
```c
// Name: test.c
// Compile: gcc test.c -o test -ldl -no-pie -fno-PIE

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
   char buf_stack[0x10];                  
   char *buf_heap = (char *)malloc(0x10);  
   // 스택 주소
   printf("buf_stack addr: %p\n", buf_stack);
   // 힙 주소
   printf("buf_heap addr: %p\n", buf_heap);
   // 라이브러리 주소
   printf("libc_base addr: %p\n", *(void **)dlopen("libc.so.6", RTLD_LAZY));
   // 라이브러리 함수의 주소
   printf("printf addr: %p\n", dlsym(dlopen("libc.so.6", RTLD_LAZY), "printf"));
   // 코드 영역의 함수 주소
   printf("main addr: %p\n", main);
}
```
위 예시 코드를 기반으로 컴파일 하고 결과를 보면 다음과 같은 특징이 있다.

* 코드 영역의 **main함수**를 제외한 다른 영역의 주소들은 실행할 때마다 변경된다. 즉, 프로그램이 실행 될 때 마다 각 주소들이 바뀌기 때문에 실행하기 전에 해당 영역들의 주소를 예측할 수 없다.
* 라이브러리 주소(`libc_base`)와 라이브러리 함수의 주소(`printf`)의 주소 차이는 항상 같습니다. ASLR은 라이브러리 파일을 그대로 매핑하는 것이므로, 매핑된 주소로부터 라이브러리의 다른 심볼들 까지의 거리(Offset)는 항상 같다.

## NX(DEP)
**NX(No-eXcute)**는 코드 영역을 제외한 다른 메모리 영역에서 실행권한을 없애는 CPU의 기술이다. NX가 지정된 메모리는 실행권한이 없어 공격자가 쉘코드를 실행시켜도 실행되지 않는다. NX를 확인하고 싶으면, `checksec`을 이용하여 NX 보호기법을 확인할 수 있다.

## 우회 기법
### Return To Library(RTL)
NX가 설정되면 코드 영역을 제외한 다른 메모리에서는 실행권한이 없어진다. 그래서 공격자들은 실행 권한이 남아 있는 코드 영역으로 반환 주소를 덮는 공격 기법을 고안한다.

프로세스에 실행 권한이 있는 메모리 영역은 일반적으로 <U>바이너리의 코드 영역</U>과 바이너리가 참조하는 <U>라이브러리 코드 영역</U>이다.

리눅스에서 C언어로 작성된 프로그램이 참조하는 libc에는 `system`, `execve`등 프로세스의 실행과 관련된 함수들이 구현되어 있는거 처럼, 공격자들은 libc의 함수들로 NX를 우회하고 셸을 획득하는 공격 기법(**Return To Library**)을 개발하였다.

### Return Oriented Programming(ROP)
**ROP**는 리턴 가젯을 사용히여 복잡한 실행 흐름을 구현하는 기법이다. ROP 페이로드는 리턴 가젯으로 구성되는데, `ret` 단위로 여러 코드가 연쇄적으로 실행되는 모습에서 ROP chain이라고도 한다. 

#### x86 Gadgets
* 호출 하는 함수의 인자가 3개 일 경우 : `"pop; pop; pop; ret"`
* 호출 하는 함수의 인자가 2개 일 경우 : `"pop; pop; ret"`
* 호출 하는 함수의 인자가 1개 일 경우 : `"pop; ret"`
* 호출 하는 함수의 인자가 없을 경우 : `"ret"`

해당 Gadgets들의 역할은 **ESP 레지스터의 값을 증가**시키는 것이다. 즉, RTL에 의해 호출되는 함수에 전달되는 인자 값이 저장된 영역을 지나 다음 함수가 호출될 수 있도록 한다.

#### x64 Gadgets
* 호출할 함수의 첫번째 인자 값을 저장 : `"pop rdi; ret"`
* 호출할 함수의 두번째 인자 값을 저장 : `"pop rsi; ret"`
* 호출할 함수의 첫번째, 세번째 인자 값을 저장: `"pop rdi; pop rdx; ret"`

## Ref
[1] [드림핵 시스템 해킹 강의 Mitigation: NX & ASLR](https://dreamhack.io/lecture/roadmaps/2)

[2] [Lazencan Tech Note: ROP](https://www.lazenca.net/pages/viewpage.action?pageId=16810141)