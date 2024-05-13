---
title: Calling Convention x86
date: 2024-03-01 15:00:00 +0900
categories: [Computer Science, CS Theory]
tags: [Calling Convention]
math: true
mermaid: true
---
**함수 호출 규약(Calling Convention)**은 함수의 호출 및 반환(스택 포인터를 어떻게 정리하는지)에 대한 약속이다. 

함수 호출 규약을 적용하는 것은 일반적으로 컴파일러 몫이다. 그러나 컴파일러의 도움 없이 어셈블리 코드 작성하거나, 어셈블리 코드를 읽고자 한다면 함수 호출 규약을 알아야 한다. 

* Caller(호출자): 함수를 호출한 함수
* Callee(피호출자): 호출을 당한 함수

ex) main()에서 printf()를 호출한다면, Caller = main(), Callee = printf()

## x86
x86 아키텍처는 레지스터의 수가 적으므로, 스택으로 인자를 전달하는 규약을 사용한다.
### cdecl
cdecl은 **Caller**가 자신의 스택에 입력한 함수 피라미터를 직접 정리하는 방식이다. 스택을 통해 인자를 전달할 때는, **마지막 인자부터 첫 번째 인자까지 거꾸로 스택에 push**한다.
```c
// Name: cdecl.c
// Compile: gcc -fno-asynchronous-unwind-tables -nostdlib -masm=intel -fomit-frame-pointer -S cdecl.c -w -m32 -fno-pic -O0
#include <stdio.h>

void __attribute__((cdecl)) callee(int a1, int a2, int a3, int a4, int a5, int a6, int a7) { } // cdecl로 호출

void caller() {
   callee(1, 2, 3, 4, 5, 6, 7);
}
```

```s
callee:
    nop
    ret ; 스택을 정리하지 않고 리턴
    .size	callee, .-callee
    .globl	caller
    .type	caller, @function
caller:
    push 7 ; 7을 스택에 저장하여 callee의 인자로 전달
    push 6 ; 6을 스택에 저장하여 callee의 인자로 전달
    push 5 ; 5를 스택에 저장하여 callee의 인자로 전달
    push 4 ; 4를 스택에 저장하여 callee의 인자로 전달
    push 3 ; 3을 스택에 저장하여 callee의 인자로 전달
    push 2 ; 2를 스택에 저장하여 callee의 인자로 전달
    push 1 ; 1을 스택에 저장하여 callee의 인자로 전달
    call callee
    add	esp, 28 ; 스택을 정리(push를 7번하였기 때문에, 28byte만큼 esp가 증가)
    nop
    ret
    .size   caller, .-caller
    .ident  "GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
    .section    .note.GNU-stack,"",@progbits
```
cdecl은 printf()와 같이 **가변 인자**(매개 변수의 개수가 정해지지 않는 함수)가 사용 가능하다.

### stdcall
stdcall은 **Calle**에서 스택을 정리하는 방식이다. 스택을 통해 인자를 전달할 때는, **마지막 인자부터 첫 번째 인자까지 거꾸로 스택에 push**한다.
```c
// Name: stdcall.c
// Compile: gcc -fno-asynchronous-unwind-tables -nostdlib -masm=intel -fomit-frame-pointer -S stdcall.c -w -m32 -fno-pic -O0
#include <stdio.h>

void __attribute__((stdcall)) callee(int a1, int a2, int a3, int a4, int a5, int a6, int a7) { } // stdcall로 호출

void caller() {
   callee(1, 2, 3, 4, 5, 6, 7);
}
```

```s
callee:
    nop
    ret 28  ; 스택 정리(push를 7번하였기 때문에, 28byte만큼 esp가 증가)
    .size   callee, .-callee
    .globl  caller
    .type   caller, @function
caller:
    push 7 ; 7을 스택에 저장하여 callee의 인자로 전달
    push 6 ; 6을 스택에 저장하여 callee의 인자로 전달
    push 5 ; 5를 스택에 저장하여 callee의 인자로 전달
    push 4 ; 4를 스택에 저장하여 callee의 인자로 전달
    push 3 ; 3을 스택에 저장하여 callee의 인자로 전달
    push 2 ; 2를 스택에 저장하여 callee의 인자로 전달
    push 1 ; 1을 스택에 저장하여 callee의 인자로 전달
    call callee
    nop
    ret
    .size   caller, .-caller
    .ident  "GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
    .section    .note.GNU-stack,"",@progbits
```
스택프레임을 정리하면서 전달된 매개변수의 크기만큼 esp의 값을 더해야 하는데, callee는 전달된 매개변수의 크기를 알 수 없기 때문에 가변인자를 사용하는 것이 불가능하다. 또한 stdcall은 callee에서 스택을 정리하기 때문에 cdecl에 비해 코드 크기가 작다.

### fastcall
fastcall은 함수에 전달하는 인자 일부(2개 까지)를 스택이 아닌 레지스터(ecx, edx)를 이용하여 전달한다.
```c
// Name: fastcall.c
// Compile: gcc -fno-asynchronous-unwind-tables -nostdlib -masm=intel -fomit-frame-pointer -S fastcall.c -w -m32 -fno-pic -O0
#include <stdio.h>

void __attribute__((fastcall)) callee(int a1, int a2, int a3, int a4, int a5, int a6, int a7) { } // fastcall로 호출

void caller() {
   callee(1, 2, 3, 4, 5, 6, 7);
}
```

```s
callee:
    sub esp, 8
    mov DWORD PTR [esp+4], ecx
    mov DWORD PTR [esp], edx
    nop
    add esp, 8
    ret 20  ; 스택 정리(스택에 push를 5번하였기 때문에, 20byte만큼 esp가 증가)
    .size   callee, .-callee
    .globl  caller
    .type   caller, @function
caller:
    push 7 ; 7을 스택에 저장하여 callee의 인자로 전달
    push 6 ; 6을 스택에 저장하여 callee의 인자로 전달
    push 5 ; 5를 스택에 저장하여 callee의 인자로 전달
    push 4 ; 4를 스택에 저장하여 callee의 인자로 전달
    push 3 ; 3을 스택에 저장하여 callee의 인자로 전달
    mov edx, 2 ; 2를 edx에 저장하여 callee의 인자로 전달
    mov ecx, 1 ; 1을 ecx에 저장하여 callee의 인자로 전달
    call callee
    nop
    ret
    .size   caller, .-caller
    .ident  "GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
    .section    .note.GNU-stack,"",@progbits
```

## Ref
[1] [드림핵 시스템 해킹 강의 Stack Buffer Overflow](https://dreamhack.io/lecture/roadmaps/2)

[2] [C/C++ 함수의 호출 규약 with 어셈블리](https://over-stack.tistory.com/23)
