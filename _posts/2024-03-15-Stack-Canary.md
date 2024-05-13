---
title: Stack Canary
date: 2024-03-15 18:00:00 +0900
categories: [Pwnable, Pwn Theory]
tags: [Pwnable, Stack Canary]
math: true
mermaid: true
---
**스택 카나리(Stack Canary)**는 함수의 프롤로그에서 스택 버퍼와 반환 주소 사이에 임의의 값을 삽입하고, 함수의 에필로그에서 해당 값의 변조를 확인하는 보호 기법이다. 카나리 값이 변조가 되면 프로세스는 강제 종료된다.

## 카나리 분석
아래 코드를 기반으로 카나리를 분석한다.

```c
#include <unistd.h>

int main() {
  char buf[8];
  read(0, buf, 32);
  return 0;
}
```

### 카나리 비활성화
카나리를 비활성화로 컴파일 하고 싶으면 다음과 같은 옵션을 추가하여 컴파일 하면 된다. 

`-fno-stack-protector`

```bash
$ gcc -o no_canary canary.c -fno-stack-protector
$ ./no_canary
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Segmentation fault (core dumped)
```
위와 같이 오류 메세지는 **Segmentation fault (core dumped)**라고 나타난다.

#### 정적 분석
`no_canary`를 디스어셈블 하여 분석한다.

```bash
Dump of assembler code for function main:
   0x0000000000001149 <+0>:     endbr64 
   0x000000000000114d <+4>:     push   rbp
   0x000000000000114e <+5>:     mov    rbp,rsp
   0x0000000000001151 <+8>:     sub    rsp,0x10
   0x0000000000001155 <+12>:    lea    rax,[rbp-0x8]
   0x0000000000001159 <+16>:    mov    edx,0x20
   0x000000000000115e <+21>:    mov    rsi,rax
   0x0000000000001161 <+24>:    mov    edi,0x0
   0x0000000000001166 <+29>:    call   0x1050 <read@plt>
   0x000000000000116b <+34>:    mov    eax,0x0
   0x0000000000001170 <+39>:    leave  
   0x0000000000001171 <+40>:    ret    
End of assembler dump.
```

### 카나리 활성화
카나리를 적용하여 컴파일하면 아래와 같이 나온다.

```bash
$ gcc -o canary canary.c
$ ./canary
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
*** stack smashing detected ***: terminated
Aborted (core dumped)
```
오류 메세지는 ***** stack smashing detected *****: terminated Aborted (core dumped)라고 나온다.

#### 정적 분석
`canary`를 디스어셈블하여 `no_canary`와 비교한다.

```bash
Dump of assembler code for function main:
   0x0000555555555169 <+0>:     endbr64 
   0x000055555555516d <+4>:     push   rbp
   0x000055555555516e <+5>:     mov    rbp,rsp
   0x0000555555555171 <+8>:     sub    rsp,0x10
   0x0000555555555175 <+12>:    mov    rax,QWORD PTR fs:0x28
   0x000055555555517e <+21>:    mov    QWORD PTR [rbp-0x8],rax
   0x0000555555555182 <+25>:    xor    eax,eax
   0x0000555555555184 <+27>:    lea    rax,[rbp-0x10]
   0x0000555555555188 <+31>:    mov    edx,0x20
   0x000055555555518d <+36>:    mov    rsi,rax
   0x0000555555555190 <+39>:    mov    edi,0x0
   0x0000555555555195 <+44>:    call   0x555555555070 <read@plt>
   0x000055555555519a <+49>:    mov    eax,0x0
   0x000055555555519f <+54>:    mov    rdx,QWORD PTR [rbp-0x8]
   0x00005555555551a3 <+58>:    sub    rdx,QWORD PTR fs:0x28
   0x00005555555551ac <+67>:    je     0x5555555551b3 <main+74>
   0x00005555555551ae <+69>:    call   0x555555555060 <__stack_chk_fail@plt>
   0x00005555555551b3 <+74>:    leave  
   0x00005555555551b4 <+75>:    ret    
End of assembler dump.
```
`no_canary` 프롤로그는 `lea    rax,[rbp-0x8]`만 있는 것에 비해, `canary`의 **프롤로그**는 아래 코드가 추가된 것을 볼 수 있다.

```bash
   0x0000555555555175 <+12>:    mov    rax,QWORD PTR fs:0x28
   0x000055555555517e <+21>:    mov    QWORD PTR [rbp-0x8],rax
   0x0000555555555182 <+25>:    xor    eax,eax
   0x0000555555555184 <+27>:    lea    rax,[rbp-0x10]
```
> `fs`와 `gs`는 목적이 정해지지 않아 운영체제가 임의로 사용할 수 있는 레지스터이다. 리눅스는 `fs`를 **Thread Local Storage(TLS)**를 가리키는 포인터로 사용한다. 여기서  TLS에 카나리를 비롯하여 프로세스 실행에 필요한 여러 데이터가 저장된다.
{: .prompt-tip }
또한 **에필로그**에는 아래 코드가 추가 되었다.

```bash
   0x000055555555519f <+54>:    mov    rdx,QWORD PTR [rbp-0x8]
   0x00005555555551a3 <+58>:    sub    rdx,QWORD PTR fs:0x28
   0x00005555555551ac <+67>:    je     0x5555555551b3 <main+74>
   0x00005555555551ae <+69>:    call   0x555555555060 <__stack_chk_fail@plt>
```

#### 동적 분석
`canary`에 추가적으로 있는 코드를 분석해본다.

```bash
$ gdb ./canary
pwndbg> break *main+12
Breakpoint 1 at 0x1175
pwndbg> run
► 0x555555555175 <main+12>    mov    rax, qword ptr fs:[0x28]
  0x55555555517e <main+21>    mov    qword ptr [rbp - 8], rax
pwndbg> ni
 ► 0x55555555517e <main+21>    mov    qword ptr [rbp - 8], rax
   0x555555555182 <main+25>    xor    eax, eax
```
`rax`값을 확인해보면 첫 바이트가 널 바이트인 8바이트 데이터가 저장되어 있다.

`*RAX`  0x887586903b3ff400

```bash
pwndbg> break *main+54
pwndbg> continue
AAAAAAAAAAAAAAAA
 ► 0x55555555519f <main+54>    mov    rdx, qword ptr [rbp - 8]
   0x5555555551a3 <main+58>    sub    rdx, qword ptr fs:[0x28]
pwndbg> ni
 ► 0x5555555551a3 <main+58>    sub    rdx, qword ptr fs:[0x28]
   0x5555555551ac <main+67>    je     main+74        <main+74>
```
`rbp-0x8`에 저장된 카나리 값이 오버플로우로 인해 `0x4141414141414141`가 된 것을 볼 수 있다.

`main+58`의 연산 결과가 0이 아니므로 `main+67`에서 `main+74`로 분기하지 않고 `main+69`의 `__stack_chk_fail`을 실행한다. `__stack_chk_fail`가 실행하게 되면 아래와 같은 메세지가 출력되며 프로세스가 강제로 종료 된다.

```bash
*** stack smashing detected ***: terminated

Program received signal SIGABRT, Aborted.
```

## 카나리 생성 과정
카나리 값은 프로세스가 시작될 때, TLS에 전역 변수로 저장되고, 각 함수마다 프롤로그와 에필로그에서 이 값을 참조한다. 카나리 값이 어떻게 생성되는지 알기 위해, TLS에 카나리 값이 저장되는 과정을 자세히 분석한다.

### TLS 주소 파악
`fs`는 TLS를 가리키므로 `fs`의 값을 알면 TLS의 주소를 알 수 있다. 그러나 리눅스에서 `fs`의 값은 특정 시스템 콜을 사용해야만 조회하거나 설정할 수 있다.

`fs`의 값을 설정할 때 호출되는 `arch_prctl(int code, unsigned long addr)` 시스템 콜에 중단점을 설정하여 확인할 수 있다. `arch_prctl(ARCH_SET_FS, addr)`의 형태로 호출하면 `fs`의 값은 addr로 설정된다.

```bash
$ gdb ./canary
pwndbg> catch syscall arch_prctl
pwndbg> r
...
pwndbg> c
...
pwndbg> c
────────────[ REGISTERS / show-flags off / show-compact-regs off ]────────────
*RAX  0xffffffffffffffda
*RBX  0x7fffffffdb60 ◂— 0x1
*RCX  0x7ffff7fe3dff (init_tls+239) ◂— test eax, eax
*RDX  0xffff800008057eb0
*RDI  0x1002
*RSI  0x7ffff7fa7740 ◂— 0x7ffff7fa7740
```
`init_tls()` 안에서 catchpoint에 도달할 때까지 `continue` 명령어를 실행한다. catchpoint에 도달했을 때, `rdi`의 값이 `0x1002`인데 이 값은 `ARCH_SET_FS`의 상숫값이다. `rsi`의 값이 `0x7ffff7fa7740`이므로 이 프로세스는 TLS를 `0x7ffff7fa7740`에 저장할 것이며, `fs`는 이를 가리키게 될 것이다.

카나리가 저장될 `fs+0x28`을 보면 아직 어떠한 값도 설정되지 않은 것을 볼 수 있다.

```bash
pwndbg> x/gx 0x7ffff7fa7740 + 0x28
0x7ffff7fa7768: 0x0000000000000000
```
### 카나리 값 설정
gdb의 `watch` 명령어로 TLS+0x28에 값을 쓸 때 프로세스를 중단한다.
> `watch`는 특정 주소에 저장된 값이 변경되면 프로세스를 중단시키는 명령어
{: .prompt-tip }

```bash
pwndbg> watch *(0x7ffff7fa7740 + 0x28)
Hardware watchpoint 2: *(0x7ffff7fa7740 + 0x28)
...
pwndbg> c
Continuing.

Hardware watchpoint 2: *(0x7ffff7fa7740 + 0x28)

Old value = 0
New value = -241955328
security_init () at ./elf/rtld.c:870
870     in ./elf/rtld.c
```
TLS+0x28의 값을 조회하면 카나리 값이 변경된 것을 볼 수 있다.

```bash
pwndbg> x/gx 0x7ffff7fa7740 + 0x28
0x7ffff7fa7768: 0x283f9be2d6c75000
```
실제로 카나리 값이 `0x283f9be2d6c75000`인지 확인하기위해 `main`함수에 중단점을 설정하고 진행한다.

```bash
pwndbg> b *main+21
pwndbg> c
────────────[ REGISTERS / show-flags off / show-compact-regs off ]────────────
*RAX  0x283f9be2d6c75000
─────────────────────[ DISASM / x86-64 / set emulate on ]────────────
   0x555555555175 <main+12>    mov    rax, qword ptr fs:[0x28]
 ► 0x55555555517e <main+21>    mov    qword ptr [rbp - 8], rax
```
확인해본 결과 카나리 값이 `0x283f9be2d6c75000`인 것을 볼 수 있다.

## 카나리 우회
### Brute Force
x64 아키텍처에서는 8바이트의 카나리가 생성되며, x86 아키텍처에서는 4바이트의 카나리가 생성된다. 각각의 카나리에는 NULL 바이트가 포함되어 있으므로, 실제로는 7바이트와 3바이트의 랜덤한 값이 포함이 된다.

즉, x64아키텍처는 최대 256^7번, x86 에서는 최대 256^3 번의 연산이 필요하다.

하지만 연산량이 많기 때문에 실제 서버를 대상으로 무차별 대입을 시도하는 것은 거의 불가능하다.

### TLS 접근
카나리는 TLS에 전역변수로 저장되며, 매 함수마다 이를 참조해서 사용한다. TLS의 주소는 매 실행마다 바뀌지만 만약 실행중에 TLS의 주소를 알 수 있고, 임의 주소에 대한 읽기 또는 쓰기가 가능하다면 TLS에 설정된 카나리 값을 읽거나, 이를 임의의 값으로 조작할 수 있다.

스택 버퍼 오버플로우를 수행할 때 알아낸 카나리 값 또는 조작한 카나리 값으로 스택 카나리를 덮으면 함수의 에필로그에 있는 카나리 검사를 우회할 수 있다.

### 스택 카나리 릭
스택 카나리를 읽을 수 있는 취약점이 있으면, 이를 이용하여 카나리 검사를 우회할 수 있다.

## 정리
**스택 카나리**는 스택 버퍼 오버플로우로부터 반환주소를 보호하는 기법이며, 스택 카나리가 있는지 확인하는 방법은 `gdb`로 확인하거나 `checksec`으로 확인할 수 있다.

**x64 환경**에서는 스택 카나리가 `fs+0x28`에 저장되어 있고, 카나리값은 첫 바이트가 널 바이트인 8바이트 데이터로 저장되어 있다.
(자세한 내용은 본문 참고)

**x86 환경**에서는 스택 카나리가 `gs+0x14`에 저장되어 있고, 카나리 값은 첫 바이트가 널 바이트인 4바이트 데이터로 저장되어 있다.(본문에서 자세히 다루지 못했지만, `gcc -o canary canary.c -m32`를 이용하여 x64실습과정을 따라가면 된다.)

이러한 스택 카나리를 우회하는 방법으로 `무차별 대입`, `TLS 접근`, `스택 카나리 릭` 방법 등이 있다.

## Ref
[1] [드림핵 시스템 해킹 강의 Mitigation: Stack Canary](https://dreamhack.io/lecture/roadmaps/2)