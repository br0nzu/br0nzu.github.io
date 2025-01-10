---
title: "[Heap] Dynamic Allocator"
date: 2025-01-10 21:30:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [heap, ptmalloc2]
math: true
mermaid: true
---
## Dynamic Memory Allocator
동적으로 할당된 메모리는 힙(Heap) 영역에서 관리되고, **동적 메모리 할당기(Dynamic Memory Allocator)**를 사용하여 관리한다. 동적 메모리 할당기에는 크게 두 종류로 나뉜다.

- **Explicit Allocator**: 개발자가 직접 메모리 공간의 할당과 해제를 관리

    ex) C언어의 `malloc`과 `free`

- **Implicit Allocator**: 개발자는 메모리 공간의 할당만 담당하며, 메모리 해제는 내부적으로 자동 처리

    ex) Java의 가비지 컬렉터(Garbage Collector), Lisp 등

**Explicit Allocator**의 대표적인 종류는 다음과 같다.
- `dlmalloc`: 리눅스 초창기에 사용된 기본 메모리 할당자
- `ptmalloc2`: dlmalloc에서 멀티 스레딩 기능이 추가된 메모리 할당자로, **glibc** 소스 코드에 통합
- `Jemalloc`: 페이스북이나 파이어폭스에서 주로 사용
- `tcmalloc`: 크롬에서 주로 사용

여기서 집중적으로 다뤄볼 할당자는 dlmalloc과 ptmalloc2이다. **ptmalloc2**는 어떤 메모리가 해제되면, 해제된 메모리의 특징을 기억하고 있다가 비슷한 메모리의 할당 요청이 발생하면 이를 빠르게 반환한다. 이를 통해 **메모리 할당의 속도를 높이고** **불필요한 메모리 사용을 막을 수 있고**, **메모리 단편화를 방지할 수 있다.**

## ptmalloc2 특징
위에서 언급한 것 처럼 `ptmalloc2`의 특징은 다음과 같다.
* 메모리 낭비 방지
* 빠른 메모리 재사용
* 메모리 단편화 방지

### 매모리 낭비 방지
`ptmalloc`은 메모리 할당 요청이 발생하면, 이전에 해제된 메모리 공간 중에서 재사용할 수 있는 공간이 있는지 탐색한다. 해제된 메모리 공간 중에서 요청된 크기와 같은 크기의 메모리 공간이 있다면 재사용한다. 또한, 작은 크기의 할당 요청이 있으면 해제된 메모리 공간 중 요청한 크기보다 큰 영역에서 메모리를 나누어 주기도 한다.

### 메모리 재사용
메모리를 재사용하려면 해제된 메모리 주소를 알고 있어야 한다. `ptmalloc`은 `tcache` 또는 `bin`이라는 연결 리스트에 해제된 메모리 주소를 저장한다.

### 메모리 단편화 방지
메모리 단편화(Memory Fragmentation)는 내부 단편화와 외부 단편화가 있다.

* **내부 단편화**: 할당한 메모리 공간의 크기에 비해 실제 데이터가 점유하는 공간이 작을 때 발생한다.
* **외부 단편화**: 할당한 메모리 공간들 사이에 공간이 많아서 발생하는 비효율을 의미한다.

메모리 단편화가 심해질수록, 각 데이터 사이에 공간이 많아져서 메모리 사용의 효율이 감소한다. 이를 해결하고자 `ptmalloc`은 **정렬(Alignment)**, **병합(Coalescence)**, **분할(Split)**을 사용한다. 

* 정렬 : 64bit 환경에서는 16바이트, 32bit 환경에서는 8바이트 단위로 정렬
* 병합 : 특정 조건을 만족하면 해제된 공간들을 병합
* 분할 : 병합된 메모리 공간이 이후의 할당 요청에 의해 분할

## ptmalloc2 객체
`ptmalloc2`는 **<U>청크(chunk), bin, tcache, arena</U>**를 주요 객체로 사용한다. 각 개념에 대해서는 다음에 자세하게 다뤄볼 것이다.

## Ref
[1] [드림핵 시스템 해킹 강의 Use After Free](https://dreamhack.io/lecture/roadmaps/2)

[2] [Heap 기초1](https://jeongzero.oopy.io/bcb0067a-3d2d-4e00-b8e7-499fba15e1bb#6b006a76-4d32-4079-af96-2f7d3f643ac9)
