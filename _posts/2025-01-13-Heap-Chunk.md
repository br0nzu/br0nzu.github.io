---
title: "[Heap] Chunk"
date: 2025-01-13 17:20:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [heap, chunk]
math: true
mermaid: true
---
## Chunk
**청크(Chunk)**는 `malloc()`에 의해 메모리 할당 요청이 들어온 경우, 실제로 할당 받는 영역이다. 청크는 헤더와 데이터로 구성되는데, **헤더**는 청크의 상태를 나타내고 **데이터**는 사용자가 입력한 데이터가 저장된다.

청크의 크기는 32비트 환경에서는 8바이트 배수로 할당되고, 64비트 환경에서는 16바이트 단위로 할당된다.

## Chunk Structure

![Chunk Structure](/assets/img/Heap Chunk/Chunk Structure.png)

헤더는 청크의 상태를 나타내므로 사용 중인 청크와 해제된 청크의 헤더 구조는 다르다. 사용 중인 청크는 `fd`와 `bk`를 사용하지 않고, 그 영역에 사용자가 입력한 데이터를 저장한다.

```c
// glibc 2.23 malloc.c line 1111
struct malloc_chunk {

  INTERNAL_SIZE_T      prev_size;  /* Size of previous chunk (if free).  */
  INTERNAL_SIZE_T      size;       /* Size in bytes, including overhead. */

  struct malloc_chunk* fd;         /* double links -- used only if free. */
  struct malloc_chunk* bk;

  /* Only used for large blocks: pointer to next larger size.  */
  struct malloc_chunk* fd_nextsize; /* double links -- used only if free. */
  struct malloc_chunk* bk_nextsize;
};
```

**청크 헤더**의 각 요소는 다음과 같다.

- `prev_size`: 인접한 이전 청크의 크기
    - 인접한 이전 청크가 할당된 경우: 0으로 초기화
    - 인접한 이전 청크가 free된 경우: 이전 청크의 크기 값으로 초기화

![Chunk Bit](/assets/img/Heap Chunk/Chunk Bit.png)

- `size`: 현재 할당된 청크의 크기이며 32비트에서 8바이트 64비트에서 16바이트 단위로 할당되므로, **마지막 3bit는 flag로 사용**
    - **A(Allocated Arena, 0x4)**: Main	Arena가 아닌 Arena에서 할당받은 경우 1로 세팅
    - **M(Mmap'd, 0x2)**: 청크가 mmap() 함수로 할당받은 경우 1로 세팅
    - **P(Prev In Use, 0x1)**: 인접한 이전 청크가 사용되거나 free된 청크가 fastbin에 있으면 세팅 

**Prev In Use bit**가 중요한 이유는 해당 내용을 숙지하고 있어야 heap 취약점에 대해 이해할 수 있기 때문이다.

- `fd`(forward pointer), `bk`(backward pointer): 청크가 free된 경우 fd는 다음 청크를 가리키는 포인터, bk는 이전 청크를 가리키는 포인터

- `fd_nextsize`, `bk_nextsize`: 청크들은 비슷한 크기로 묶어서 관리하기 때문에 가장 큰(512bytes보다 큰, large bin)청크가 free된 경우 세팅됨

## Chunk 종류
청크의 종류에는 크게 3가지로 구분한다.

- Allocated chunk: 할당된 chunk
- Freed chunk: 해제된 chunk
- Top chunk(Wildness chunk) 

### Allocated Chunk(할당되어 있는 청크)

![Allocated Chunk](/assets/img/Heap Chunk/Allocated Chunk.png)

이는 할당되어 있는 청크를 나타낸 사진이다. 인접한 이전 청크가 할당되어 있어, Prev In Use bit가 1로 세팅되어 있다.

![Allocated Chunk2](/assets/img/Heap Chunk/Allocated Chunk2.png)

### Free Chunk(해제된 청크)

![Free Chunk](/assets/img/Heap Chunk/Free Chunk.png)

이는 `free()`로 인해 해제된 청크이다. free chunk의 경우 실제로 해당 영역이 반환되는 것이 아니라 아직 힙 영역에 남아 있으며, Allocated chunk 구조에서 Freed chunk 구조로 변경된다. 

위 사진의 Free Chunk를 보면 마지막 부분 다음 청크의 헤더인 prev_size가 포함된 것을 볼 수 있다. malloc을 통해 할당된 청크가 해제되었다면, 다음 청크의 prev_size 필드도 해제된 청크의 페이로드 필드로 사용된다. 이는 **boundary tag** 알고리즘 때문인데, boundary tag를 통해 이전 청크의 헤더 위치를 쉽게 찾을 수 있다.

> free된 청크들은 단일 free 청크로 결합된다는 특징이 있지만, fastbins의 경우에는 free 청크들끼리 결합하지 않는다. 즉, fastbins인 경우에는 boundary tag를 
세팅하지 않는다.
{: .prompt-tip}

![boundary tag](/assets/img/Heap Chunk/boundary tag.png)

청크가 할당되면 각 청크의 크기 정보는 `size`에 저장되고 `prev_size`는 0으로 초기화 된다.

![boundary tag2](/assets/img/Heap Chunk/boundary tag2.png)

청크가 해제되면, 해제된 청크의 인접한 뒤 청크 `prev_size`에 해제된 청크의 크기값이 들어간다. 이를 통해 Allocated chunk 와 Freed chunk가 존재할 때, 인접한 앞/뒤 청크의 주소를 계산할 수 있다.

```c
// heap.c
// gcc -g -fno-stack-protector -z execstack -z norelro -no-pie -o heap heap.c -lpthread

#include <stdio.h>
#include <stdlib.h>

void main(){
    char *heap1 = malloc(0x90);
    char *heap2 = malloc(0x90);
    char *heap3 = malloc(0x90);

    free(heap1);
    free(heap2);
    free(heap3);
}
```

![boundary tag gdb](/assets/img/Heap Chunk/boundary tag gdb.png)

위 사진은 `free(heap2)` 이전, `free(heap1)` 이후의 결과이다. boundary tag를 이용하면, A 청크 혹은 C 청크의 주소를 알 수 있다.

```
Chunk_A Addr = Chunk_B Addr - Chunk_B prev_size
0x601000 = 0x6010a0 - 0xa0

Chunk_C Addr = Chunk_B Addr - Chunk_B size
0x601140 = 0x6010a0 + 0xa0
```

이를 다른 관점으로 생각하면 다음과 같다.

- `prev_size`를 조작하면, 이전 청크의 위치 조작 가능
- `size`를 조작하면, 다음 청크의 위치 조작 가능
- `prev_inuse bit`를 조작하면, 이전 청크의 할당/해제 여부 조작 가능

### Top chunk

![Top Chunk](/assets/img/Heap Chunk/Top Chunk.png)

Top Chunk는 Arena의 가장 마지막에 위치하는 청크이며, 새롭게 malloc을 호출하면 Top Chunk에서 분리되어 청크를 할당한다. 만약 Top Chunk에 인접한 Chunk가 free되면 Top Chunk에 병합된다.

Top Chunk가 분할되는 경우는 재사용 가능한 Free Chunk가 없거나 Top Chunk가 반환할 수 있는 크기가 존재하는 경우 다음과 같이 2개로 분할된다.

- User Chunk: 사용자가 요청한 크기
- Remainder Chunk: 요청한 크기의 나머지 부분으로 **새롭게 Top Chunk**가 됨

만약 Top Chunk의 크기보다 큰 사이즈를 요청한 경우

- Main Arena: sbrk() 호출하여 메모리 확장하여 Top Chunk의 크기 늘림
- Sub Arena: mmap() 호출하여 메모리 할당

```c
// heap.c
// gcc -g -fno-stack-protector -z execstack -z norelro -no-pie -o heap heap.c -lpthread
#include <stdio.h>
#include <stdlib.h>

void main(){
    char *heap1 = malloc(0x90);
    char *heap2 = malloc(0x90);
    
    free(heap2);
    free(heap1);
}
```

![Top Chunk2](/assets/img/Heap Chunk/Top Chunk2.png)

일반적으로 Top Chunk는 0x21000의 크기를 갖는다. 위 사진을 보면 Top Chunk의 크기가 `0x0000000000020ec1`인데, 이는 Chunk A와 B의 크기가 0xa0이기 때문에 0x21000에서 0xa0 * 2의 값을 뺀 크기를 갖는다.

![Top Chunk3](/assets/img/Heap Chunk/Top Chunk3.png)

또한, Top Chunk와 인접한 청크가 free되면 Top Chunk에 병합되는 모습을 볼 수 있다.

## Ref
[1] [heap - glibc malloc (feat. chunk)](https://rninche01.tistory.com/entry/heap3-glibc-malloc2-feat-chunk)

[2] [드림핵 시스템 해킹 강의 Use After Free](https://dreamhack.io/lecture/roadmaps/2)

[3] [glibc 2.23 malloc](https://elixir.bootlin.com/glibc/glibc-2.23/source/malloc/malloc.c)

[4] [시스템해킹 튜토리얼 - Heap Concept Tutorial](https://www.youtube.com/watch?v=l0GVitgBPf0)