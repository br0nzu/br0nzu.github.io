---
title: Library & Link 
date: 2024-03-27 18:00:00 +0900
categories: [Computer Science, CS Theory]
tags: [Library, Link]
math: true
mermaid: true
---
## 라이브러리
**라이브러리**는 컴퓨터 시스템에서, 프로그램들이 함수나 변수를 공유하여 사용할 수 있게 한다.

라이브러리를 사용하면 다음과 같은 이점이 있다.(<U>C언어 기준</U>)
* 컴파일 시간 단축
* 다른 프로그래머의 소스 코드를 쉽게 사용할 수 있다.
* 소스코드를 보호 / 비공개할 수 있다.

## 링크
**링크**는 컴파일의 마지막 단계로, 호출된 함수와 실제 라이브러리의 함수가 연결되는 과정이다. 오브젝트 파일은 실행 가능한 형식을 갖추고 있지만, 라이브러리 함수들의 정의가 어디 있는지 알지 못하므로 실행이 불가능하다. 이러한 라이브러리 함수들의 정의를 찾아, 실행 파일에 기록하는 것이 링크 과정에서 하는 일 중 하나이다.

```c
// Name: test.c
// Compile: gcc -o test test.c

#include <stdio.h>

int main() {
  puts("Hello, world!");
  return 0;
}
```

먼저 오브젝트 파일로 컴파일(`gcc -c test.c -o test.o`) 해서 보면 다음과 같다.

```bash
$ readelf -s test.o | grep puts
    5: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND puts
```

이제 컴파일(`gcc -o test test.c`)하여 오브젝트 파일과 비교해본다.

```bash
$ readelf -s test | grep puts
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND puts@GLIBC_2.2.5 (3)
    21: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND puts@GLIBC_2.2.5
$ ldd test
    linux-vdso.so.1 (0x00007ffe5c3ad000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007e41a2400000)
    /lib64/ld-linux-x86-64.so.2 (0x00007e41a26df000)
```

링크를 거치고 나면 프로그램에서 `puts`를 호출할 때, `puts`의 정의가 있는 `libc`에서 `puts`의 코드를 찾고, 해당 코드를 실행한다.
>  `libc`를 같이 컴파일하지 않았음에도 `libc`에서 해당 심볼을 탐색한 것은, `libc`가 있는 `/lib/x86_64-linux-gnu/`가 표준 라이브러리 경로에 포함되어 있다. `gcc`는 소스 코드를 컴파일할 때 표준 라이브러리의 라이브러리 파일들을 모두 탐색한다.
{: .prompt-tip }

## 종류
라이브러리는 동적과 정적 라이브러리로 구분되며, 동적 라이브러리를 링크하는 것을 **동적 링크(Dynamic Link)**, 정적 라이브러리를 링크하는 것을 **정적 링크(Static Link)**라고 한다.

### 동적 링크
동적 링크는 동적 라이브러리가 프로세스의 메모리에 매핑된다. 그리고 실행 중에 라이브러리의 함수를 호출하면, 매핑된 라이브러리에서 호출할 함수의 주소를 찾고, 그 함수를 실행한다. 즉, 공유 라이브러리를 사용하여 실행 중에 매핑시키는 것이다.

### 정적 링크
정적 링크는 라이브러리를 참조하는 것이 아니라, 자신의 함수를 호출하는 것 처럼 호출한다. 즉, 파일 생성시 라이브러리 내용을 포함한 실행파일을 만드는 것이다. 또한, 여러 바이너리에서 라이브러리를 사용하면 그 라이브러리의 복제가 여러 번 이루어진다.

## 비교
동적 링크와 정적 링크를 비교하기 위해서 위의 예시 코드인 `test.c`를 각각 동적과 정적으로 컴파일 한다.

```bash
$ gcc -o dynamic test.c -no-pie
$ gcc -o static test.c -static
```

### 용량
```bash
$ ls -lh ./dynamic ./static
-rwxrwxr-x 1 br0nzu br0nzu  16K  3월 27 17:57 ./dynamic
-rwxrwxr-x 1 br0nzu br0nzu 880K  3월 27 17:57 ./static
```

각각의 용량을 비교하면 `static`이 `dynamic`보다 50배 가까이 더 많은 용량을 차지한다.

### 호출 방법
각각의 프로그램을 gdb해서 `disass main`하면 `puts`의 호출 방식을 볼 수 있다.
* static: `0x0000000000401787 <+18>:    call   0x40c180 <puts>`
* dynamic: `0x0000000000401148 <+18>:    call   0x401040 <puts@plt>`

`static`은 `puts`가 있는 `0x40c180`을 직접 호출하지만, `dynamic`은 `puts`의 plt 주소인 `0x401040`을 호출한다. 동적 링크된 바이너리는 함수의 주소를 라이브러리에서 <U>찾아야</U> 하기 때문이다.

## Ref
[1] [드림핵 시스템 해킹 강의 Mitigation: NX & ASLR](https://dreamhack.io/lecture/roadmaps/2)