---
title: "[Linux] Memory Layout"
date: 2024-09-30 00:00:00 +0900
categories: [0x00. Computer Science, 0x00. Theory]
tags: [Linux, Memory Layout]
math: true
mermaid: true
---
Stack Frame을 정리하다가 Memory Layout도 제대로 정리하면 좋을거 같아서 Memory Layout 정리글을 올린다.

## Linux Memory Layout

![Linux Memory Layout](/assets/img/Memory Layout/Linux Memory Layout.png)

8086메모리는 4GB 메모리 기준으로 2GB 커널 영역과 2GB 유저 영역이 존재한다. 이번 포스팅에서 집중해야할 부분은 **유저 영역**이다.

유저 영역은 세그먼트[^footnote]라는 단위로 프로세스들이 들어가는데 CPU는 이 세그먼트를 병렬적으로 처리한다. 세그먼트는 스택 영역, 힙 영역, BSS 영역, 데이터 영역, 코드 영역등 여러개의 구역으로 나누어 진다.

![Linux Memory Layout Segment](/assets/img/Memory Layout/Linux Memory Layout Segment.png)

위 사진을 보면 코드 세그먼트, 데이터 세그먼트, BSS 세그먼트, 힙 세그먼트, 스택 세그먼트가 있다.

### Code Segment
**코드 세그먼트(Code Segment)**는 <u>실행 가능한 기계 코드가 위치하는 영역</u>으로 **텍스트 세그먼트(Text Segment)**라고도 불린다. 

```c
int main() { return 31337 }
```

위 코드를 컴파일 하면 `554889e5b8697a00005dc3`라는 기계 코드로 변환되는데, 이 기계코드가 코드 세그먼트에 위치한다.

### Data Segment
**데이터 세그먼트(Data Segment)**는 <u>컴파일 시점에 값이 정해진 전역 변수 및 전역 상수들이 위치</u>한다.

```c
int data = 26                       // data 
const int const_data = 19990813     // rodata
int main() { ... }
```

데이터 세그먼트에는 Data Segment와 Rodata(read-only data) Segment로 나뉜다. **Data Segment**에는 프로그램이 실행되면서 <u>값이 변할 수 있는 데이터들이 위치</u>하는데, **RoData Segment**에는 프로그램이 실행되면서 <u>값이 변하면 안되는 데이터들이 위치</u>한다.

### BSS Segment
**BSS 세그먼트(BSS Segment, Block Started By Symbol Segment)**는 <u>컴파일 시점에 값이 정해지지 않은 전역 변수가 위치</u>하는 메모리 영역이다.

```c
int data;
int main() { ... }
```

BSS Segment의 메모리 영역은 **프로그램이 시작할 때 모두 0으로 초기화** 된다.

### Stack Segment
**스택 세그먼트(Stack Segment)**는 프로세스의 스택이 위치하는 영역으로, <u>함수의 인자나 지역 변수</u>들이 실행 중 Stack Segment에 저장된다. 스택 세그먼트는 **스택 프레임(Stack Frame)**이라는 단위로 사용되는데, 이는 함수가 호출될 때 생성되고 반환될 때 해제된다.

```c
void func()
{
    int choice = 0;
    scanf("%d", &choice);
    if (choice)
        call_true();
    else
        call_false();
    return 0;
}
```

위 코드는 `choice`에 따라 `call_true()`가 호출될 수도, `call_false()`가 호출될 수 있다. 이처럼 어떤 프로세스가 실행될 때 해당 프로세스가 얼마 만큼의 스택 프레임을 사용하게 될 지를 미리 계산하는 것은 거의 불가능하다. 그래서 운영체제는 프로세스를 시작할 때 작은 크기의 스택 세그먼트를 먼저 할당해주고, 부족해 질 때마다 이를 확장한다. 스택에 대해서 <u>아래로 자란다</u>라는 표현을 종종 사용하는데, 이는 스택이 확장될 때, **기존 주소보다 낮은 주소로 확장**되기 때문입니다.

### Heap Segment
**힙 세그먼트(Heap Segment)**는 힙 데이터가 위치하는 세그먼트로, 스택과 마찬가지로 실행중에 동적으로 할당될 수 있으며, 리눅스에서는 스택 세그먼트와 **반대 방향**으로 자란다.

C언어에서는 `malloc()`, `calloc()`등을 호출해서 할당받는 메모리가 이 세그먼트에 위치한다.

> **힙과 스택 세그먼트가 자라는 방향이 반대인 이유**는 동일 방향으로 자라게 된다면 **충돌**할 수 있다. 그래서 스택은 메모리 끝에 위치하고, 힙과 반대로 자라게 한다.
{: .prompt-info }

## Ref
[1] [드림핵 시스템 해킹 강의 Background: Linux Memory Layout](https://dreamhack.io/lecture/roadmaps/2)

[2] [스택 구조](https://jeongzero.oopy.io/1ee38455-434e-4de7-8046-028421d3c096)

## Footnote
[^footnote]: **세그먼트**: 적재되는 데이터의 용도별로 메모리의 구획을 나눈 것