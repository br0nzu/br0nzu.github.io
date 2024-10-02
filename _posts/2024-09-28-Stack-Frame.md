---
title: Stack Frame
date: 2024-09-28 07:00:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [Stack Frame, Function Prologue, Function Epilogue, BackTrace]
math: true
mermaid: true
---
Pwnable 문제를 잘 풀려면 기본적으로 Stack Frame 이해가 필수적이다. 학습은 했지만 정리는 하지 않아, 이번 기회에 제대로 정리해보려고 한다.

## Stack Frame
**Stack Frame**은 <u>함수 자신만의 공간</u> 이다. 구체적으로 **스택**은 함수별로 자신의 지역변수 또는 연산과정에서 부차적으로 생겨나는 임시 값들을 저장하는 영역이다. 만약 같은 스택 영역에서 A함수가 B함수를 호출하면, B에서 A의 지역변수를 모두 오염시킬 수 있다. 따라서 함수별로 서로가 사용하는 스택의 영역을 명확히 구분하기 위해 Stack Frame을 사용한다.

## Stack Frame 분석

```c
// frame.c
// gcc -m32 -g -no-pie -mpreferred-stack-boundary=2 -o frame frame.c
#include <stdio.h>

void func2()
{
    int i = 7;
    int j = 8;
    int k = 9;
    
    printf("func2 has called\n");
}

void func1()
{
    int i = 4;
    int j = 5;
    int k = 6;
    
    printf("func1 has called\n");

    func2();
}

void main()
{
    int i = 1;
    int j = 2;
    int k = 3;
    
    printf("main has called\n");

    func1();
}
```

위 코드의 실행결과는 다음과 같다.

```sh
main has called
func1 has called
func2 has called
```

`main()` → `func1()` → `func2()` 이렇게 실행되었다. 이제 디버깅으로 분석해보자.

`gdb ./frame` 으로 디버거를 실행한 다음, `disass main` 명령어로 main 함수를 분석하면 다음과 같다.

```sh
pwndbg> disass main
Dump of assembler code for function main:
   0x080491f5 <+0>:     push   ebp
   0x080491f6 <+1>:     mov    ebp,esp
   0x080491f8 <+3>:     push   ebx
   0x080491f9 <+4>:     sub    esp,0xc
   0x080491fc <+7>:     call   0x804923b <__x86.get_pc_thunk.ax>
   0x08049201 <+12>:    add    eax,0x2dff
   0x08049206 <+17>:    mov    DWORD PTR [ebp-0x10],0x1
   0x0804920d <+24>:    mov    DWORD PTR [ebp-0xc],0x2
   0x08049214 <+31>:    mov    DWORD PTR [ebp-0x8],0x3
   0x0804921b <+38>:    lea    edx,[eax-0x1fd6]
   0x08049221 <+44>:    push   edx
   0x08049222 <+45>:    mov    ebx,eax
   0x08049224 <+47>:    call   0x8049050 <puts@plt>
   0x08049229 <+52>:    add    esp,0x4
   0x0804922c <+55>:    call   0x80491b3 <func1>
   0x08049231 <+60>:    mov    eax,0x0
   0x08049236 <+65>:    mov    ebx,DWORD PTR [ebp-0x4]
   0x08049239 <+68>:    leave  
   0x0804923a <+69>:    ret    
End of assembler dump.
```

스택은 기존 주소보다 낮은 주소로 확장되는 특성이 있다. 이는 '아래로 자란다'라는 표현을 사용하는데 'ebp에서 시작해서 esp에서 끝난다'라고 생각해도 된다. 

`ebp`는 **Base Pointer**를 의미하며, 스택 프레임의 시작 공간을 가리킨다.

`esp`는 **Stack Pointer**를 의미하며, 현재 스택의 최상단을 가리킨다. 스택은 높은 주소에서 낮은 주소로 데이터가 쌓이기 때문에 esp는 데이터의 추가 및 제거에 따라 값이 감소하거나 증가한다. 즉 push는 데이터가 쌓이기 때문에 esp가 데이터 크기만큼 감소하고, pop은 스택에서 데이터를 제거하기 때문에 esp가 데이터 크기만큼 증가한다. 이로 인해 스택의 크기는 동적으로 변하며, esp가 스택의 크기 변화를 추적하게 된다.

![func](/assets/img/Stack Frame/func.png)

위 코드를 보면 `main()` → `func1()` → `func2()` 이렇게 실행되는 것을 알 수 있는데, 스택을 보면 위 사진처럼 쌓인다.

### Function Prologue
**함수 프롤로그(Function Prologue)**는 함수가 호출될 때 새로운 스택 프레임을 설정하여 함수 실행에 필요한 환경을 준비하는 과정이다. 위 디스어셈블 코드에서 함수 프롤로그 부분은 다음과 같다.

```sh
   0x080491f5 <+0>:     push   ebp
   0x080491f6 <+1>:     mov    ebp,esp
```

`push ebp`는 이전 함수의 `ebp` 주소이다. 즉 되돌아갈 함수의 `ebp`주소를 스택에 저장한다.

`mov ebp, esp`는 현재 함수의 Stack Base를 설정한다.

그리고 변수가 들어온다면 `esp`값이 바뀌어 스택의 크기가 늘어난다.

따라서 위 과정들이 함수가 호출될 때 해당 함수의 스택 프레임을 설정하여 함수 실행에 필요한 환경을 준비하는 과정이다.

### Function Epilogue
**함수 에필로그(Function Epilogue)**는 함수가 종료될 때 실행되어 스택 프레임을 해제하고 함수 호출 전에 저장된 레지스터와 포인터들을 복원하는 과정이다. 위 디스어셈블 코드에서 함수 에필로그 부분은 다음과 같다.

```sh
   0x08049239 <+68>:    leave  
   0x0804923a <+69>:    ret   
```

함수 에필로그의 명령을 보면 `leave`와 `ret`으로 구성되어 있다.

#### leave

```nasm
mov esp, ebp
pop ebp
```

`mov esp, ebp`는 함수에서 지역 변수를 위해 할당했던 스택 공간을 해제하는 역할을 한다.함수 실행 중에 감소시켰던 `esp`를 `ebp`의 값으로 복원하여, 함수 시작 시점의 스택 상태로 되돌린다.

`pop ebp`은 함수 시작 시 스택에 저장했던 이전 함수의 베이스 포인터(`ebp`) 값을 복원하는 과정이다. 이를 통해 이전 스택 프레임의 기준으로 돌아간다. 여기서 중요한 점은 `pop ebp`의 동작 과정이다. `pop ebp`는 현재의 `esp`가 있는 곳에서 4byte를 복사하여 `ebp`에 저장한다. 여기서 현재의 `esp`는 되돌아갈 함수의 `ebp`주소 값이고, 이는 **SFP(Stack Frame Pointer)**라고 한다. 그리고 pop과정을 했기 때문에 `esp`의 값은 4바이트가 증가된다.

#### ret

```nasm
pop eip
jmp eip
```

`pop eip`를 수행하게 된다면 `esp`가 있는 곳에서 4byte를 복사하는데, 이는 호출된 `call` 명령 다음에 실행할 부분의 주소이다.

`jmp eip` 이전 동작에서 `eip`는 호출된 `call` 명령 다음에 실행할 부분의 주소기 때문에 해당 주소로 이동한다.

`leave`와 `ret`을 통해 함수가 종료되고, 스택 프레임이 해제된다.

### Backtrace
**Backtrace**는 프로그램의 실행 중 특정 시점에서 호출된 함수들의 호출 순서를 역순으로 나열한 것이다. `frame`의 호출 순서를 보면 `main()` → `func1()` → `func2()` 이렇게 실행된 것을 알 수 있다.

![bt](/assets/img/Stack Frame/backtrace.png)

그렇다면 왜 `main+60`, `func1+60` 이렇게 나타났을까?

위 물음에 대한 대답은 `call` 명령어의 특성 때문이다. `call`을 할 때는 다음에 실행할 명령의 주소를 스택에 `push`하고 이동한다.

```sh
   0x0804922c <+55>:    call   0x80491b3 <func1>
   0x08049231 <+60>:    nop
```

그래서 위 코드를 보면 `main+55`는 `func1`을 `call`하는 부분이고 `main+60`은 `call`명령어의 다음 실행할 명령어의 주소이다.

따라서 Backtrace에서 `main+60`, `func1+60`이렇게 나오는 이유는 `call` 명령어의 특성 때문이다.

## Ref
[1] [드림핵 시스템 해킹 강의 Background: Computer Science](https://dreamhack.io/lecture/roadmaps/2)

[2] [스택 프레임](https://www.tcpschool.com/c/c_memory_stackframe)