---
title: "[Heap] 용어 정리"
date: 2025-01-16 09:40:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [heap]
math: true
mermaid: true
---
`ptmalloc2`는 **<u>청크(chunk), bin, tcache, arena</u>**를 주요 객체로 사용한다. 각 개념에 대해서는 다음 페이지들을 참고하면 되고, 여기서는 간략하게 정리만 할 것이다.(tcache는 glibc 2.26부터 추가된 개념으로 추후에 다룰 예정이다.)

- [Dynamic Allocator](/posts/Heap-Dynamic-Allocator)
- [Arena](/posts/Heap-Arena)
- [Chunk](/posts/Heap-Chunk)
- [Bin](/posts/Heap-Bin)


## Arena
Arena는 멀티 스레드 환경에서 메모리 할당 성능을 최적화하는 메모리 관리 단위이다.
- Main Arena
    - 프로그램 시작 시점에 전역변수로 생성되고, 오직 하나만 존재
    - 주로 `brk`/`sbrk` syscall로 힙 확장
    - heap_info 구조체 사용 X
- Sub Arena
    - 여러개 존재할 수 있음(시스템 환경에 따른 갯수 제한 있음)
    - `mmap` syscall 힙 확장
    - Sub Arena마다 heap_info 구조체 갖는다

## Chunk
청크(Chunk)는 `malloc()`에 의해 메모리 할당 요청이 들어온 경우, 실제로 할당 받는 영역

![Chunk Structure](/assets/img/Heap Chunk/Chunk Structure.png)

Chunk 종류

- Allocated chunk: 할당된 chunk
- Freed chunk: 해제된 chunk
- Top chunk(Wildness chunk)

## Bin
Bin은 Free Chunk들을 크기 단위로 관리(binning)하는 역할이다. → **재활용**

- fastbinsY[NFASTBINS]: fast bin을 관리하는 배열(10개)
    - 인접한 Free 청크가 존재해도 병합 X
    - 단일 연결리스트로 LIFO 방식
- bins[NBINS * 2 - 2]: unsorted bin, small bin, large bin을 관리하는 배열
    - bin[0]: N/A(사용되지 않음), 특수한 목적에 사용
    - bin[1]: unsorted bin(1개)
        - small bin, large bin에 삽입되기 전, 재할당을 위한 1번의 기회가 주어짐
    -    이중 연결리스트로 FIFO 방식
    - bin[2] ~ bin[63]: small bin(62개)
        - 인접한 Free 청크가 존재하면 병합
        - 이중 연결리스트로 FIFO 방식
    - bin[64] ~ bin[126]: large bin(63개)
        - 인접한 Free 청크가 존재하면 병합
        - 이중 연결리스트로 FIFO 방식

## 함수 호출 알고리즘
### malloc()
`malloc()` 호출 순서: `libc_malloc()` → `int_malloc()` → `sysmalloc()`

![malloc](/assets/img/Heap glibc/malloc.png)

1. `libc_malloc()`에서 사용하는 Thread에 맞게 Arena를 설정한 후, `int_malloc()` 호출
2. `int_malloc()`에서는 재사용할 수 있는 bin을 탐색하여 재할당하고, 마땅한 bin이 없다면 **top chunk**에서 분리해서 할당
3. top chunk가 요청한 크기보다 작은 경우, `sysmalloc()` 호출
4. `sysmalloc()`를 통해 시스템에 메모리를 요청해서 top chunk의 크기를 병합(확장)하거나 새 Arena를 생성 

### free()
`free()` 호출 순서: `libc_free()` → `int_free()` → `systrim()` or `heap_trim()` or `munmap_chunk()`

![free](/assets/img/Heap glibc/free.png)

1. `libc_free()`에서 `mmap`으로 할당된 메모리인지 확인
    - mmap으로 할당된 경우, `munmap_chunk()`를 통해 메모리 해제
    - mmap 할당이 아닌 경우, 해제하고자 하는 chunk가 속한 Arena의 포인터를 획득한 후, `int_free()` 호출

2. chunk를 해제한 후, 크기에 맞는 bin을 찾아 저장하고 top chunk와 병합을 할 수 있다면 병합 수행
4. 병합된 top chunk가 너무 커서 Arena의 크기를 넘어선 경우, top chunk의 크기를 줄이기 위해 `systrim()` 호출
5. 문제가 없다면, `heap_trim()` 호출
6. mmap으로 할당된 chunk라면 `munmap_chunk()` 호출

## Ref
[1] [Heap 영역 정리](https://tribal1012.tistory.com/141?category=658553)