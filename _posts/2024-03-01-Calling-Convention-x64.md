---
title: Calling Convention x64
date: 2024-03-01 15:45:00 +0900
categories: [Computer Science, CS Theory]
tags: [Calling Convention]
math: true
mermaid: true
---
[Calling Convention x86](/posts/Calling-Convention-x86) 설명에 이어서 Calling Convention x64를 설명하겠다.
## x64
## SYSV
리눅스는 SYSTEM V(SYSV) Application Binary Interface(ABI)를 기반으로 만들어졌다. SYSV ABI는 ELF 포맷, 링킹 방법, 함수 호출 규약 등의 내용을 담고 있다. SYSV에서 정의한 함수 호출 규약은 다음의 특징을 갖는다.

### 특징
1. 6개의 인자를 **RDI, RSI, RDX, RCX, R8, R9**에 순서대로 저장하여 전달한다. 더 많은 인자를 사용해야 할 때는 스택을 추가로 이용한다.
2. Caller에서 인자 전달에 사용된 스택을 정리
3. 함수의 반환 값은 RAX로 전달

```c
// Name: sysv.c
// Compile: gcc -fno-asynchronous-unwind-tables  -masm=intel -fno-omit-frame-pointer -S sysv.c -fno-pic -O0
#include <stdio.h>
#define ull unsigned long long

ull callee(ull a1, int a2, int a3, int a4, int a5, int a6, int a7) {
  ull ret = a1 + a2 + a3 + a4 + a5 + a6 + a7;
  return ret;
}
void caller() { callee(123456789123456789, 2, 3, 4, 5, 6, 7); }

int main() { caller(); }
```

```s
callee:
        endbr64
        push    rbp
        mov     rbp, rsp
        mov     QWORD PTR [rbp-24], rdi ; 첫번째 인자 저장
        mov     DWORD PTR [rbp-28], esi ; 두번째 인자 저장
        mov     DWORD PTR [rbp-32], edx ; 세번째 인자 저장
        mov     DWORD PTR [rbp-36], ecx ; 네번째 인자 저장
        mov     DWORD PTR [rbp-40], r8d ; 다섯번째 인자 저장
        mov     DWORD PTR [rbp-44], r9d ; 여섯번째 인자 저장
        ; 연산 과정 ~
        mov     eax, DWORD PTR [rbp-28]
        movsx   rdx, eax
        mov     rax, QWORD PTR [rbp-24]
        add     rdx, rax
        mov     eax, DWORD PTR [rbp-32]
        cdqe
        add     rdx, rax
        mov     eax, DWORD PTR [rbp-36]
        cdqe
        add     rdx, rax
        mov     eax, DWORD PTR [rbp-40]
        cdqe
        add     rdx, rax
        mov     eax, DWORD PTR [rbp-44]
        cdqe
        add     rdx, rax
        mov     eax, DWORD PTR [rbp+16]
        cdqe
        add     rax, rdx                
        ; ~ 연산 과정
        mov     QWORD PTR [rbp-8], rax  ; 최종 결과 값을 스택에 저장
        mov     rax, QWORD PTR [rbp-8]
        pop     rbp
        ret
        .size   callee, .-callee
        .globl  caller
        .type   caller, @function
caller:
        endbr64
        push    rbp
        mov     rbp, rsp
        push    7       ; 7을 스택에 저장하여 callee의 인자로 전달
        mov     r9d, 6  ; 6을 r9에 저장하여 callee의 인자로 전달
        mov     r8d, 5  ; 5를 r8에 저장하여 callee의 인자로 전달
        mov     ecx, 4  ; 4를 ecx(rcx)에 저장하여 callee의 인자로 전달
        mov     edx, 3  ; 3을 edx(rdx)에 저장하여 callee의 인자로 전달
        mov     esi, 2  ; 2를 esi(rdi)에 저장하여 callee의 인자로 전달
        movabs  rax, 123456789123456789
        mov     rdi, rax ; 123456789123456789를 rdi에 저장하여 callee의 인자로 전달
        call    callee
        add     rsp, 8  ; 스택 정리(push를 1번하였기 때문에, 8byte만큼 rsp가 증가)
        nop
        leave
        ret
        .size   caller, .-caller
        .globl  main
        .type   main, @function
main:
        endbr64
        push    rbp
        mov     rbp, rsp
        mov     eax, 0
        call    caller
        mov     eax, 0
        pop     rbp
        ret
        .size   main, .-main
        .ident  "GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
        .section        .note.GNU-stack,"",@progbits
        .section        .note.gnu.property,"a"
```

## 분석
`sysv.c`를 `gcc -fno-asynchronous-unwind-tables -masm=intel -fno-omit-frame-pointer -o sysv sysv.c -fno-pic -O0`로 컴파일 해서 gdb를 이용하여 분석한다.
```bash
gdb ./sysv

pwndbg> b *caller
Breakpoint 1 at 0x1185
pwndbg> r
Starting program: /home/br0nzu/Desktop/sysv
...
pwndbg> disass caller
Dump of assembler code for function caller:
=> 0x0000555555555185 <+0>:     endbr64 
   0x0000555555555189 <+4>:     push   rbp
   0x000055555555518a <+5>:     mov    rbp,rsp
   0x000055555555518d <+8>:     push   0x7
   0x000055555555518f <+10>:    mov    r9d,0x6
   0x0000555555555195 <+16>:    mov    r8d,0x5
   0x000055555555519b <+22>:    mov    ecx,0x4
   0x00005555555551a0 <+27>:    mov    edx,0x3
   0x00005555555551a5 <+32>:    mov    esi,0x2
   0x00005555555551aa <+37>:    movabs rax,0x1b69b4bacd05f15
   0x00005555555551b4 <+47>:    mov    rdi,rax
   0x00005555555551b7 <+50>:    call   0x555555555129 <callee>
   0x00005555555551bc <+55>:    add    rsp,0x8
   0x00005555555551c0 <+59>:    nop
   0x00005555555551c1 <+60>:    leave  
   0x00005555555551c2 <+61>:    ret
...
pwndbg> b *caller+50
Breakpoint 2 at 0x5555555551b7
pwndbg> c
Continuing.
```
`caller+50`에 `callee()`가 있기 때문에 `callee()`에 bp를 걸어서 함수 호출 규약이 어떻게 적용되고 있는지 확인한다.

```bash
Breakpoint 2, 0x00005555555551b7 in caller ()
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
───────────[ REGISTERS / show-flags off / show-compact-regs off ]───────────
*RAX  0x1b69b4bacd05f15
 RBX  0x0
*RCX  0x4
*RDX  0x3
*RDI  0x1b69b4bacd05f15
*RSI  0x2
*R8   0x5
*R9   0x6
...
*RSP  0x7fffffffdeb8 ◂— 0x7  
```
caller가 callee에게 넘겨줄 때 레지스터를 보면, `callee(123456789123456789, 2, 3, 4, 5, 6, 7)`에서 인자들이 순서대로 `rdi, rsi, rdx, rcx, r8, r9` 그리고 `rsp`에 저장되어 있는 모습을 볼 수 있다.

```bash
pwndbg> b *callee+79
Breakpoint 3 at 0x555555555178
pwndbg> c
Continuing.

Breakpoint 3, 0x0000555555555178 in callee ()
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
───────────[ REGISTERS / show-flags off / show-compact-regs off ]───────────
*RAX  0x7
 RBX  0x0
 RCX  0x4
*RDX  0x1b69b4bacd05f29
...

pwndbg> b *callee+91
Breakpoint 4 at 0x0000555555555184
pwndbg> c
Continuing.

Breakpoint 4, 0x0000555555555184 in callee ()
LEGEND: STACK | HEAP | CODE | DATA | RWX | RODATA
────────────[ REGISTERS / show-flags off / show-compact-regs off ]─────────────
 RAX  0x1b69b4bacd05f30
...
```
`si`하고 `callee()` 내부를 살펴보면, 마지막 반환 부분(`ret`)에서 함수의 반환 값은 `RAX`로 전달되는 것을 볼 수 있다.

## Ref
[1] [드림핵 시스템 해킹 강의 Stack Buffer Overflow](https://dreamhack.io/lecture/roadmaps/2)
