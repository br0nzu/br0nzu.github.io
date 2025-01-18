---
title: "[Heap] tcache 정리"
date: 2025-01-16 17:40:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [heap, tcache]
math: true
mermaid: true
---
glibc 2.26 이후 `tcache`라는 기능이 추가되었다.

## tcache
**tcache(Tread local Caching)**은 멀티 스레드 환경에서 메모리 할당 속도를 높이기 위해 만들어진 기술이다. 

즉, tcache는 작은 단위의 메모리 할당이 필요할 경우 Arena를 참조하지 않고 바로 메모리를 할당할 수 있도록 **각 스레드 당 thread cache라는 영역을 제공**함으로써 메모리 할당 속도를 높일 수 있는 기술이다.

## tcache structure

![tcache_perthread_struct](/assets/img/Heap tcache/tcache_perthread_struct.png)

이 사진은 tcache의 전체적인 구조이다. 

### tcache_entry

```c
// glibc 2.26 malloc.c line 2925

/* We overlay this structure on the user-data portion of a chunk when
   the chunk is stored in the per-thread cache.  */
typedef struct tcache_entry
{
  struct tcache_entry *next;
} tcache_entry;
```

`tcache_entry` 구조체는 동일한 크기의 free 청크를 관리하는 구조체이다.
- `next`: tcache list 관리

### tcache_perthread_struct
tcache는 `tcache_perthread_struct`에 존재한다.

```c
// glibc 2.26 malloc.c line 2932

/* There is one of these for each thread, which contains the
   per-thread cache (hence "tcache_perthread_struct").  Keeping
   overall size low is mildly important.  Note that COUNTS and ENTRIES
   are redundant (we could have just counted the linked list each
   time), this is for performance reasons.  */
typedef struct tcache_perthread_struct
{
  char counts[TCACHE_MAX_BINS];             // TCACHE_MAX_BINS = 64
  tcache_entry *entries[TCACHE_MAX_BINS];   // TCACHE_MAX_BINS = 64
} tcache_perthread_struct;
```

- `counts[TCACHE_MAX_BINS]`: `entries[TCACHE_MAX_BINS]`에 연결되어 있는 청크의 개수
- `entries[TCACHE_MAX_BINS]`: 기존 bin의 역할과 동일
    - 단일 연결리스트로, LIFO 방식 사용
    - 동일한 크기의 free 청크들로 연결

```c
// heap.c
// gcc -g -fno-stack-protector -z execstack -z norelro -no-pie -o heap heap.c -lpthread

#include <stdio.h>
#include <stdlib.h>

void main(){
    char *heap1 = malloc(0x10);
    char *heap2 = malloc(0x10);
    char *heap3 = malloc(0x20);
    char *heap4 = malloc(0x20);
    char *heap5 = malloc(0x30);
    char *heap6 = malloc(0x30);

    free(heap1);
    free(heap2);
    free(heap3);
    free(heap4);
    free(heap5);
    free(heap6);
}
```

`free(heap6)`이후 결과이다.

![tcache debugging code](/assets/img/Heap tcache/tcache debugging code.png)

tcache는 LIFO 방식의 단일 연결리스트 구조로 각자의 크기의 맞게 들어가 있으며, count 되어 있는 모습을 볼 수 있다.

![tcache debugging code2](/assets/img/Heap tcache/tcache debugging code2.png)

이는 `tcache_perthread_struct` 부분인데, `counts`(0x601010 ~ 0x601048)와 `entries`(0x601050 ~ 0x601248) 부분이 설정 되어 있는 모습을 볼 수 있다.

또한, glibc 2.26부터 heapbase에 tcache_perthread_struct 구조체 내용이 제일 먼저 할당된다. 따라서 tcache_perthread_struct에 할당되는 청크의 크기는 count(64) + entry(8 * 64 = 512) + header(16)값인 592(0x250)바이트가 된다.

## tcahce 특징
tcahce의 주요 특징은 다음과 같다.

- LIFO 방식의 단일 연결리스트
- 하나의 tcache는 같은 크기의 청크들만 보관
- tcache에서 bin의 개수는 일반적으로 64개이며, 각각 서로 다른 크기의 청크들을 bin에 저장하는데 최대 7개의 청크까지 저장할 수 있음
  - 7개 이후의 청크들은 각자 자신의 크기에 맞는 bin(fast, small, large)에 들어감
- tcache에 들어갈 수 있는 크기는 32(0x20)바이트 ~ 1040(0x410)이하의 크기를 갖는다.
  - tcahce에 들어갈 수 있는 크기의 청크가 free되면 **tcahce에 가장 먼저 할당**

## Ref
[1] [heap - tcache](https://rninche01.tistory.com/entry/heap5-tcacheThread-local-Caching)

[2] [Heap 기초4](https://jeongzero.oopy.io/2c5b7648-5f96-42c4-8366-300e7b5ebac4)

[3] [Tcache 이론 정리](https://blog.naver.com/yjw_sz/221481149348)

[4] [glibc 2.26 malloc](https://elixir.bootlin.com/glibc/glibc-2.26/source/malloc)