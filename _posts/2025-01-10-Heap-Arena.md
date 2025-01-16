---
title: "[Heap] Arena"
date: 2025-01-10 22:00:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [heap, arena]
math: true
mermaid: true
---
`ptmalloc2`는 **<U>청크(chunk), bin, tcache, arena</U>**를 주요 객체로 사용한다. 여기서 `arena`에 대한 내용을 설명할 것이다. 해당 내용에 대해서는 구글링과 많은 블로그의 도움을 받았지만, [여기](https://rninche01.tistory.com/entry/heap2-glibc-malloc1-feat-Arena?category=838537) 내용을 많이 참고했다.

`ptmalloc2`은 dlmalloc에서 멀티 스레딩 기능이 추가된 메모리 할당자로 **Arena** 개념이 도입되었다.

## Arena
**Arena**는 멀티 스레드 환경에서 메모리 할당 성능을 최적화하기 위해 도입된 개념으로 메모리 관리 단위이다. 각각의 스레드[^footnote]가 서로 간섭하지 않고 서로 다른 메모리 영역에서 접근할 수 있게 도와주는 힙 영역이다. 단일 스레드 프로세스인 경우 하나의 Arena를 가지지만, 멀티 스레드 프로세스인 경우 하나 이상의 Arena를 가지므로 서로 다른 Arena안에 존재하는 각각의 스레드는 정지하지 않고 힙 작업을 수행할 수 있다.

여기서 주의해야할 점은 `스레드 수 = Arena 수`가 1:1로 고정되는 것은 아니다. 모든 스레드마다 Arena를 할당하면 자원이 고갈되기 때문에 시스템 환경에 따라 Arena 갯수가 제한되어 있다.

```c
// glibc 2.23 malloc.c line 1776

#define NARENAS_FROM_NCORES(n) ((n) * (sizeof (long) == 4 ? 2 : 8))
// 32bit system인 경우 long타입 크기가 4bytes이므로 (core 갯수 * 2)만큼 arena를 가짐
// 64bit system인 경우 long타입 크기가 8bytes이므로 (core 갯수 * 8)만큼 arena를 가짐
```

glibc 2.23 malloc.c에서 1776줄을 보면 위와 같은 코드가 있다. 이를 분석하면 32비트 환경에서는 코어 수 * 2만큼 Arena를 가질 수 있고, 64비트 환경에서는 코어 수 * 8만큼 Arena를 가질 수 있다.

제한된 크기만큼 Arena의 개수가 증가하여 더이상 늘릴 수 없다면, 여러 스레드가 하나의 Arena안에서 공유하며 힙 작업을 수행해야 한다. 따라서, 각각의 Arena안에서 여러 개의 스레드가 존재할 수 있으며 뮤텍스를 사용하여 액세스를 제어한다.

만약 새로운 스레드가 생성되면, 다른 스레드가 사용하지 않는 Arena를 찾아 해당 스레드에 Arena를 연결한다. 사용 가능한 모든 Arena가 다른 스레드에서 사용중이면, 새로운 Arena를 만들고 제한된 Arena의 갯수에 도달하면 여러 스레드가 하나의 Arena에서 공유하게 된다.

Arena는 크게 Main_Arena와 Main_Arena가 아닌 Arena(Sub_Arena)로 나뉜다. 해당 내용에 대해서는 먼저 glibc 2.23 malloc을 분석한 후 스레드 관리 예시를 통해 다시 설명할 것이다.

## glibc 2.23 malloc 소스 코드
ptmalloc2이 스레드 관리하는 것을 알아보기 전, [glibc 2.23 malloc 소스 코드](https://elixir.bootlin.com/glibc/glibc-2.23/source/malloc)를 참조하여 중요한 구조체 및 개념을 숙지한다.

### main_arena

```c
// glibc 2.23 malloc.c line 1761

static struct malloc_state main_arena =
{
  .mutex = _LIBC_LOCK_INITIALIZER,
  .next = &main_arena,
  .attached_threads = 1
};
```
glibc 2.23 malloc.c에서 1761줄에서 main_arena의 구조를 볼 수 있다. main_arena는 프로그램 시작 시점에 오직 하나만 존재하는 **전역 변수**이다. 멤버를 살펴보면 `mutex`를 사용하는 것을 볼 수 있고, `next`를 통해 여러 arena를 연결리스트 형태로 관리한다. 또한 프로그램 시작 시점에는 메인 스레드가 1개 존재하므로, `.attached_threads = 1`이 설정된다.

### malloc_state(Arena Header)

```c
// glibc 2.23 malloc.c line 1686

struct malloc_state
{
  /* Serialize access.  */
  mutex_t mutex;

  /* Flags (formerly in max_fast).  */
  // 아레나 동작 모드 등을 저장하는 용도
  int flags;

  /* Fastbins */
  // Fast bin을 관리하기 위한 포인터 배열
  mfastbinptr fastbinsY[NFASTBINS];

  /* Base of the topmost chunk -- not otherwise kept in a bin */
  // topchunk 포인터
  mchunkptr top;

  /* The remainder from the most recent split of a small request */
  // small bin 할당을 수행할 때 블록을 분할하고 남은 잔여 블록을 가리키는 포인터
  mchunkptr last_remainder;

  /* Normal bins packed as described above */
  // fast bin을 제외한 일반 bin을 저장하는 배열
  mchunkptr bins[NBINS * 2 - 2];

  /* Bitmap of bins */
  unsigned int binmap[BINMAPSIZE];

  /* Linked list */
  // 연결 리스트
  struct malloc_state *next;

  /* Linked list for free arenas.  Access to this field is serialized
     by free_list_lock in arena.c.  */
  // 해제된 아레나를 위한 연결 리스트
  struct malloc_state *next_free;

  /* Number of threads attached to this arena.  0 if the arena is on
     the free list.  Access to this field is serialized by
     free_list_lock in arena.c.  */
  // 현재 해당 아레나와 연결되어 사용 중인 스레드 수
  INTERNAL_SIZE_T attached_threads;

  /* Memory allocated from the system in this arena.  */
  INTERNAL_SIZE_T system_mem;
  INTERNAL_SIZE_T max_system_mem;
};
```

glibc 2.23 malloc.c에서 1686줄에서 malloc_state의 구조를 볼 수 있다. malloc_state는 각 Arena에 하나씩 주어지고, 해제된 chunk를 관리하는 bin과 top chunk와 같은 Arena에 대한 정보를 저장하기 때문에 Arena Header라고 한다.

단일 스레드 arena는 여러 개의 힙을 가질 수 있지만, 이러한 모든 힙에 대해서는 오직 하나의 Arena Header만 존재한다.

### heap_info(Heap Header)

```c
// glibc 2.23 arena.c line 48

typedef struct _heap_info
{
  /* Arena for this heap. */
  // 현재 heap을 담당하는 arena
  mstate ar_ptr; 
  /* Previous heap. */
  // 이전 heap 영역
  struct _heap_info *prev;
  /* Current size in bytes. */
  // 현재 size(bytes) 
  size_t size;  
  
  size_t mprotect_size; /* Size in bytes that has been mprotected
                           PROT_READ|PROT_WRITE.  */
  /* Make sure the following data is properly aligned, particularly
     that sizeof (heap_info) + 2 * SIZE_SZ is a multiple of
     MALLOC_ALIGNMENT. */
  // 메모리 정렬: sizeof(heap_info) + 2*SIZE_SZ는 MALLOC_ALIGN_MASK의 배수
  char pad[-6 * SIZE_SZ & MALLOC_ALIGN_MASK];
} heap_info;
```

glibc 2.23 arena.c에서 48줄에서 _heap_info의 구조를 볼 수 있다.

Sub_arena는 각 스레드들에 대한 힙 영역이기 때문에, 힙 영역의 공간이 부족하면 새로운 영역에 추가로 할당받기 때문에(`mmap`사용) 여러개의 힙 영역을 가질 수있다.

Main_arena는 여러개의 힙을 가질수 없다. Main_arena의 공간이 부족한 경우, sbrk 힙 영역은 메모리가 매핑된 영역까지 확장된다. 

이러한 힙 영역은 어떤 arena가 관리하고 있는지, 힙 영역의 크기가 어느정도인지, 이전에 사용하던 힙 영역의 정보가 어디에 있는지를 저장할 필요가 있다. 이런 정보를 저장하기 위한 구조체가 바로 위 구조체인 heap_info이며, 힙에 대한 정보를 저장하기 때문에 Heap Header라고 한다.

여기서 중요한 점은 메인 스레드는 확장을 통해 공간을 늘리기 때문에 heap_info 구조체를 갖지 않는다. 즉, Main_arena는 heap_info 구조체를 갖지 않는다. 

### malloc_chunk(Chunk Header)

```c
// glibc 2.23 malloc.c line 1111

struct malloc_chunk {

  INTERNAL_SIZE_T      prev_size;  /* Size of previous chunk (if free).  */
  INTERNAL_SIZE_T      size;       /* Size in bytes, including overhead. */

  struct malloc_chunk* fd;         /* double links -- used only if free. */
  struct malloc_chunk* bk;

  /* Only used for large blocks: pointer to next larger size.  */
  // large block에서만 사용하고 해당 bin list의 크기 순서를 나타냄
  struct malloc_chunk* fd_nextsize; /* double links -- used only if free. */
  struct malloc_chunk* bk_nextsize;
};
```

glibc 2.23 malloc.c에서 1111줄에서 malloc_chunk의 구조를 볼 수 있다. 힙 영역은 사용자에 의해 할당되거나, 해제되거나 하면 청크(Chunk)라는 단위로 관리된다. 각 청크마다 Header를 포함하고, 이중 연결 리스트로 구성된다. 멤버들을 보면 다음과 같다.

- prev_size: 바로 이전 청크의 크기를 저장
- size: 현재 청크 크기를 저장
- fd, bk: malloc시 데이터가 들어가고, free시 fd, bk포인터로 사용
- fd(bk)_nextsize: large bin을 위해서 사용되는 포인터

청크에 대한 더 자세한 내용은 다음 게시물에서 다룰 예정이다.

## ptmalloc2 스레드 관리 예시

```c
// heap.c
// gcc -g -fno-stack-protector -z execstack -z norelro -no-pie -o heap heap.c -lpthread

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
 
void* threadFunc(void* arg) {
  printf("Before malloc in thread 1\n");
  getchar();
  char* addr = (char*) malloc(1000);
  printf("After malloc and before free in thread 1\n");
  getchar();
  free(addr);
  printf("After free in thread 1\n");
  getchar();
}
 
int main() {
  pthread_t t1;
  void* s;
  int ret;
  char* addr;

  printf("Welcome to per thread arena example::%d\n",getpid());
  printf("Before malloc in main thread\n");
  getchar();
  addr = (char*) malloc(1000);
          
  printf("After malloc and before free in main thread\n");
  getchar();
  free(addr);
          
  printf("After free in main thread\n");
  getchar();
  ret = pthread_create(&t1, NULL, threadFunc, NULL);
        
  if(ret) {
    printf("Thread creation error\n");
    return -1;
  }
        
  ret = pthread_join(t1, &s);
        
  if(ret) {
    printf("Thread join error\n");
    return -1;
  }

  return 0;
}
```

위 코드에서는 다음과 같이 확인할 것이다.
- main thread에서의 malloc 호출 이전
- main thread에서의 malloc 호출 이후, free 호출 이전
- main thread에서의 free 호출 이후
- thread 1에서의 malloc 호출 이전
- thread 1에서의 malloc 호출 이후, free 호출 이전
- thread 1에서의 free 호출 이후

### main thread에서의 malloc 호출 이전
![main thread before malloc](/assets/img/Heap Arena/main thread before malloc.png)

main()에서 malloc이 호출되기 전 메모리 상태이다. 아직 힙 영역이 없고, `pthread_create`가 진행되지 않아 메인 스레드만 있는 상태이다.

![main thread main_arena](/assets/img/Heap Arena/main thread main_arena.png)

해당 Arena는 Main Arena로써 메인 스레드에 의해 생성되며, malloc과 같은 힙 작업을 하지 않아도 기본적으로 존재한다. Sub_Arena가 존재하지 않으므로 **다음 Arena는 자기 자신**을 가리키고 있다.

또한, Main_arena는 아직 heap에 존재하지 않으며, **libc-2.23.so의 데이터 세그먼트**에 존재한다.(Main_arena = `0x7ffff7bb4b20`)

### main thread에서의 malloc 호출 이후, free 호출 이전
![main thread before free](/assets/img/Heap Arena/main thread before free.png)

malloc이 호출되고, free되기 전 상태이다. 위 사진에서 힙 영역이(`0x601000 ~ 0x622000`)에 생성된 것을 알 수 있다. 이는 `brk` syscall[^fn-nth-2]을 사용하여 프로그램의 break 위치를 증가시킴으로 힙 영역이 생성되었다.

```
gef➤  p main_arena
$3 = {
  mutex = 0x0, 
  flags = 0x1, 
  fastbinsY = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}, 
  top = 0x601c10, 
  last_remainder = 0x0, 
  bins = { ... }, 
  binmap = {0x0, 0x0, 0x0, 0x0}, 
  next = 0x7ffff7bb4b20 <main_arena>, 
  next_free = 0x0, 
  attached_threads = 0x1, 
  system_mem = 0x21000, 
  max_system_mem = 0x21000
}
```
Main Arena의 malloc_state구조체의 값(top, bins, system_mem, max_system_mem)이 바뀐 것을 알 수 있다.

![brk](/assets/img/Heap Arena/brk.png)

**`catch syscall brk`** 명령어를 사용하여 brk에 bp를 걸고 malloc 함수가 호출되면, malloc이 실행되는 과정에서 brk syscall이 호출된다.

또한, 1000바이트만큼 동적할당을 요청했지만, 힙 메모리의 크기는 135168바이트(0x622000 - 0x601000)만큼 생성되었다. 이는 **<U>Main_Arena</U>**가 생성된 것을 볼 수 있다. Main_Arena는 메인 스레드로써 생성되고, 기본적으로 132KB 크기의 initial heap을 가진다. Main_Arena가 감당할 수 있을만큼 동적 할당 요구가 들어오면 `sbrk`[^fn-nth-3] syscall을 통해 힙 영역을 확장한다. 만약 너무 큰 크기의 동적 할당이 요청되면 `mmap` syscall을 통해 새로운 힙 메모리를 할당한다. 중요한 것은 Main_Arena는 하나의 힙만 가질 수 있으며, 위에서 언급한 것 처럼 `heap_info`구조체를 가질 수 없다.

### main thread에서 free 호출 이후
![main thread after free](/assets/img/Heap Arena/main thread after free.png)

free가 호출되어 메모리가 해제되어도, 메모리 영역에 변화가 없는 것을 확인할 수 있다. 이는 free가 호출되어 메모리가 해제된 경우에 즉각 운영체제에 반환되지 않는다. 할당된 메모리의 일부분(1000바이트)은 오로지 Main_Arena의 bin에 이 해제된 청크를 추가하고, gblic malloc 라이브러리에 반환된다.(bin에 대한 설명은 다음에 자세히 다룰 예정이다.)

이후, 사용자가 다시 메모리를 요청하는 경우, `brk` syscall로 바로 할당하는 것이 아닌 bin에 비어있는 블록이 있는지 탐색하고, 존재한다면 비어있는 블록을 할당한다. 만약 비어있는 블록이 없다면 Main_arena에서 메모리를 할당 받은 과정처럼 동일하게 메모리를 할당한다.

### thread 생성후, 생성한 스레드에서 malloc 호출 이전
![sub thread before malloc](/assets/img/Heap Arena/sub thread before malloc.png)

`pthread_create` 함수를 통해 ID 값이 2인 스레드(thread2)가 생성되었다. thread2는 `threadFunc` 함수를 실행한다. thread2의 영역은 아직 malloc을 호출하지 않았으므로 thread2의 힙 영역은 없지만, 해당 thread2의 스레드 스택이 생성된 것을 확인 할 수 있다. → `0x00007ffff6fef000` ~ `0x00007ffff6ff0000` 영역이 thread2의 스택 영역이다.

### 생성한 thread에서 malloc 호출 이후, free 호출 이전
![sub thread before free](/assets/img/Heap Arena/sub thread before free.png)

thread2의 힙 영역(`0x00007ffff0000000` ~ `0x00007ffff4000000`)이 생성된 것을 확인 할 수 있다. 해당 영역은 brk를 사용해서 할당하는 main_thread와는 달리 `mmap`을 사용하여 힙 메모리가 생성된다. threadFunc 함수에서 malloc이 호출되는 과정 중에서 mmap이 호출된다.

![mmap](/assets/img/Heap Arena/mmap.png)

**`catch syscall brk`** 명령어를 이용하여 mmap에 bp를 걸고 malloc 함수가 호출되면 malloc이 실행되는 과정에서 mmap syscall이 호출된다.

사용자는 1000바이트만 요청했지만, 67MB 크기(`len=0x8000000`)의 힙 메모리가 프로세스 주소 공간에 매핑되어있다. 이 67MB 중, 135KB(`size=0x21000`)의 영역이 rwx 권한으로 세팅되어, thread2를 위한 힙 메모리로 할당되었다. 이러한 메모리의 일부분(135KB)을 Sub_arena라고 부른다. 

![sub arena](/assets/img/Heap Arena/sub arena.png)

**Sub_arena**는 새로운 스레드가 생성되어 힙 작업을 수행하고자 할 때, 다른 스레드를 기다리는 것을 줄이기 위해 새로운 Arena한 것이다. Sub_arena는 Main_arena와 달리 brk syscall로 힙 메모리를 할당받는 것이 아닌, `mmap` syscall을 통해 힙 메모리를 할당받는다. 또한, Main_arena와 달리 여러 개의 서브 힙과 heap_info 구조체를 가질 수 있다.

> 사용자가 요청한 크기가 현재 arena(main_arena 혹은 sub_arenea)에 사용자의 요청을 만족시킬 수 있는 충분한 공간이 없는 경우, `mmap` syscall(brk 미사용)을 사용하여 부족한 메모리를 할당한다.
{: .prompt-tip}

### 생성한 thread에서 free 호출 이후
![sub thread after free](/assets/img/Heap Arena/sub thread after free.png)

thread2에서 free 호출 이후 역시, 바로 메모리를 반환하지 않는다는 것을 확인 할 수 있다. 해제한 영역은 Sub_arena의 bin에 해제된 블럭을 추가하고 gblic malloc에 반환한다.

위와 같은 방법으로 메인 스레드 및 스레드들이 관리된다.

## 정리

ptmalloc2가 Arena라는 개념을 도입했으며, Arena는 멀티 스레드 환경에서 메모리 할당 성능을 최적화하는 메모리 관리 단위이다.

Arena의 종류에는 Main Arena와 Main Arena가 아닌 Arena(Sub Arena)가 있다. **Main Arena**는 프로그램 시작 시점에 전역 변수로 생성되고, 오직 하나만 존재한다. 또한 주로 `brk`/`sbrk` syscall로 힙을 확장하고, heap_info 구조체를 사용하지 않는다. **Sub_Arena**는 멀티 스레드 환경에 스레드가 추가로 생성할 수 있는 Arena로 여러개 존재할 수 있다.(단, 시스템 환경에 따른 제한 있음) 또한, `mmap` syscall로 힙을 확장하고 Sub_Arena마다 heap_info 구조체를 갖는다.

## Ref
[1] [heap - glibc malloc (feat. Arena)](https://rninche01.tistory.com/entry/heap2-glibc-malloc1-feat-Arena?category=838537)

[2] [Heap 영역 정리](https://tribal1012.tistory.com/141?category=658553)

[3] [Understanding glibc malloc](https://tribal1012.tistory.com/78)

[4] [glibc 2.23 malloc](https://elixir.bootlin.com/glibc/glibc-2.23/source/malloc/malloc.c)

## Footnote
[^footnote]: **스레드**: 프로세스 내부에서 실행 흐름을 나눌 수 있는 독립적인 작업 단위(실행흐름)

[^fn-nth-2]: **`brk` syscall**: 프로세스의 힙(Heap) 영역의 끝 주소 (program break)를 조정하는 데 사용되는 시스템 콜

[^fn-nth-3]: **`sbrk` syscall**: 내부적으로 `brk` syscall을 사용