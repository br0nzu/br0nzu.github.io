---
title: PIE & RELRO
date: 2024-04-12 22:00:00 +0900
categories: [0x01. InfoSec, 0x00. Pwnable]
tags: [Pwnable, PIE, RELRO]
math: true
mermaid: true
---
## PIE
**PIE(Position Independent Executable)**는 무작위 주소에 매핑돼도 실행 가능한 실행 파일이다. PIE는 재배치가 가능하므로, ASLR이 적용된 환경에서는 실행 파일도 무작위 주소에 적재된다. 반대로, ASLR이 적용되지 않은 환경에서는 PIE가 적용된 바이너리더라도 무작위 주소에 적재되지 않는다.

```c
// Name: test.c
// Compile: gcc -o test test.c -ldl

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
PIE가 적용되었을 때와 적용되지 않을 때(`gcc test.c -o test -ldl -no-pie -fno-PIE`)를 비교하면 다음과 같다.

* PIE가 적용되지 않은 코드 영역의 주소는 고정된 주소값이다.
* PIE가 적용된 코드 영역의 주소는 **offset 값**이다.
* offset값은 할당받은 메모리 영역 + .text 영역의 main함수 코드의 offset 값

## PIE 우회
### 코드 베이스 구하기
라이브러리 베이스 주소를 구하는 과정과 비슷하게 코드 베이스 주소를 구하면 된다. 즉, 코드 영역의 임의 주소를 읽고, 그 주소에서 오프셋을 빼면 된다.

### Partial Overwrite
ASLR이 적용된 환경에서 코드 영역의 **하위 12비트** 주소 값은 항상 같다. 코드 베이스를 구하기 어렵다면 ASLR의 특성을 이용한, 반환 주소의 일부 바이트만 덮는 공격(**Partial Overwrite**)이 있다.  

## RELRO
ELF의 데이터 세그먼트에는 프로세스의 초기화 및 종료와 관련된 `.init_array`, `.fini_array`가 있다. 이 값을 공격자가 임의로 쓸 수 있다면, 프로세스의 실행 흐름이 조작 될 수 있다.

**RELRO(RELocation Read-Only)**는 쓰기 권한이 불필요한 데이터 세그먼트에 쓰기 권한을 제거하는 기법이다. RELRO는 부분적으로 적용하는 **Partial RELRO**와 가장 넓은 영역에 적용하는 **Full RELRO**가 있다.

Partial RELRO와 Full RELRO를 비교 분석하겠다.

### Partial RELRO
```c
// Name: relro.c
// Compile: gcc -o prelro relro.c -no-pie -fno-PIE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
int main() {
   FILE *fp;
   char ch;
   fp = fopen("/proc/self/maps", "r");
   while (1) {
      ch = fgetc(fp);
      if (ch == EOF) break;
      putchar(ch);
   }
   return 0;
}
```

RELRO의 확인은 `checksec`으로 가능하다.

```bash
$ checksec ./prelro
[*] '/home/prelro'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
```

`prelro`를 실행하면 `00404000-00405000` 주소에는 쓰기 권한이 있다. 

`objdump -h ./prelro`로 자세히 보면, 해당 영역은 `.got.plt` , `.data` , `.bss`가 있다. 반면, `.init_array`, `.fini_array`, `.got`는 다른 영역에 있다.
> `.got`는 동적 링킹에 필요한 데이터 주소를 저장한다. 전역 변수 중에서 실행되는 시점에 바인딩되는 변수는 `.got`에 위치한다. 바이너리가 실행될 때는 이미 바인딩이 완료되어있으므로 쓰기 권한을 부여하지 않는다.
{: .prompt-tip }

> `.got.plt`는 동적 링킹에 필요한 함수 호출 주소를 저장한다. 실행 중에 바인딩(lazy binding)되는 변수는 `.got.plt`에 위치한다. 실행 중에 값이 써져야 하므로 쓰기 권한이 부여된다. Partial RELRO가 적용된 바이너리에서 대부분 함수들의 GOT 엔트리는 `.got.plt`에 저장된다.
{: .prompt-tip }


### Full RELRO
`relro.c`를 컴파일 옵션 없이 컴파일(`gcc -o frelro relro.c`) 한다.

```bash
$ checksec ./frelro
[*] '/home/frelro'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      PIE enabled
```

`frelor`를 실행하면 `.data`와 `.bss`에만 쓰기 권한이 있다.

`.got`는 **Full RELRO**가 적용되어서 함수들의 주소가 바이너리의 로딩 시점에 모두 바인딩됨으로, 쓰기 권한이 부여되지 않는다.

## RELRO 우회
`Partial RELRO`의 경우 `.got.plt` 영역에 대한 쓰기 권한이 존재하므로 **GOT overwrite** 공격을 활용할 수 있다.

`Full RELRO`의 경우는 `.got`영역까지도 쓰기 권한이 제거 되었다. 그래서 덮어쓸 수 있는 함수 포인터인 라이브러리에 위치한 **hook**을 이용한 **Hook Overwrite**가 있다. Hook Overwrite는 libc가 매핑된 주소를 알 때, hook 변수를 조작하여 실행흐름을 조작할 수 있다.
> hook과 관련된 함수들은 `libc.so`의 `bss` 영역에 저장되어 있다. 
{: .prompt-tip }

### Hook Overwrite
`malloc`, `free`, `realloc` 에는 각각에 대응되는 훅 변수가 존재하며 `libc.so`의 `bss`영역에 위치하여 덮어 쓰는 것이 가능하다. 또한, 훅을 실행할 때는 기존 함수에 전달한 인자를 같이 전달해 주기 때문에 `system`함수의 주소로 덮고 쉘을 실행시킬 수 있다.
> 훅은 힙 청크 할당(malloc)과 해제(free)가 다발적으로 일어나는 환경에서 성능에 악영향을 주기 때문에 보안과 성능 향상을 이유로 Glibc 2.34 버전부터 제거되었다.
{: .prompt-info }

#### 방법
**Hook Overwrite**하는 방법은 다음과 같다.
* 라이브러리의 변수 및 함수의 주소 구하기
   * `hook`, `system`, `"/bin/sh"`는 libc에 정의되어 있으므로, libc에서 오프셋을 얻을 수 있다.
   * `readelf -s [libc 버전] | grep "[찾고자 하는 변수]"`
   * `strings -tx [libc 버전] | grep "/bin/sh"`
   * libc_base 주소 - main() 호출 원리 파악
      * 대부분의 ELF 프로그램은 `_start()` → `__libc_start_main()` → `main()` 순서로 실행
      * `__libc_start_main()`은 `main()` 호출하고 `main()의 ret`은 `__libc_start_main() + offset`
      * 따라서, `libc_base` = `main의 ret` - `offset`

만약 hook을 덮을 수 있다고 해도 `malloc`, `free`, `realloc`이 없으면 **<U>프로그램 실행 및 종료시 반드시 호출하는 부분</U>**을 덮으면 된다.
* `_start()` → `__libc_start_main()` → `exit()` → `__run_exit_handlers` → `_dl_fini` → `__rtld_lock_lock_recursive(GL(dl_load_lock))`
* `dl_load_lock`의 인자는 `_rtld_global`구조체
*  `_rtld_global`구조체는 동적 링커인 `ld.so`에서 사용하는 값을 갖고 있다.

[`__libc_start_main()` 자세한 정보](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/baselib---libc-start-main-.html)

### One_gadget
**One-gadget(magic_gadget)**은 실행하면 쉘이 획득되는 코드 뭉치이다. 원 가젯은 단일 가젯만으로도 쉘을 실행할 수 있는 가젯이다.

원 가젯은 libc의 버전마다 다르게 존재하며, 제약 조건도 모두 다르다. 또한, Glibc 버전이 높아질수록 제약 조건을 만족하기가 어렵다.

원 가젯은 함수에 인자를 전달하기 어려울 때 유용하게 사용할 수 있다.

## Ref
[1] [드림핵 시스템 해킹 강의 Mitigation: PIE & RELRO](https://dreamhack.io/lecture/roadmaps/2)

[2] [Lazencan Tech Note: PIE](https://www.lazenca.net/display/TEC/06.PIE)

[3] [Lazencan Tech Note: RELRO](https://www.lazenca.net/display/TEC/04.RELRO)