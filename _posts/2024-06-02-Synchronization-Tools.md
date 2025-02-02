---
title: Synchronization Tools 
date: 2024-06-02 04:30:00 +0900
categories: [0x00. Computer Science, 0x01. Operating System]
tags: [OS, Synchronization]
math: true
mermaid: true
---
**프로세스 동기화**는 여러 프로세스가 동시에 실행될 때, 이들이 공유 자원에 접근하는 순서와 방식에 대해 조정하는 것이다. 동시에 공유 데이터에 접근한다면 데이터 불일치가 일어날 수 있고, 데이터 일관성을 유지하려면 협력 프로세스 간의 순차적인 실행을 보장하는 매커니즘이 필요하다. 즉, 프로세스 동기화를 하지 않으면 데이터 정합성[^footnote] 문제가 일어날 수 있다.

프로세스 동기화에서 중요하게 봐야할 점은 **임계 구역(Critical-Section) 문제**이다. **임계 구역 문제**는 여러 프로세스가 동시에 공유 자원에 접근할 때 발생하며, 데이터의 일관성을 유지하기 위해 반드시 해결해야 하는 문제이다.

![Critical Section Problem](/assets/img/240602/Critical Section Problem.png){: .normal}

각 프로세스에는 임계 구역이라고 하는 코드 세그먼트가 존재한다. **임계 구역**은 특정 프로세스가 공유 자원에 접근하여 작업을 수행하는 코드 영역을 의미한다. 하나의 프로세스가 임계 구역에서 실행 중일 때, 다른 프로세스들은 해당 임계 구역에 접근할 수 없다. 일반적인 프로세스는 위 사진처럼 진입 구역, 퇴출 구역 그리고 나머지 구역으로 구성되어 있다. 

임계 구역 문제를 해결하기 위해서는 다음 세 가지 조건을 만족해야 한다.
* **상호배제(Mutual Exclusion)**: 임계구역에 하나의 프로세스만 들어갈 수 있어야 함
* **진행(Progress)**: 임계구역에 들어가기를 원하는 프로세스가 없으면 다른 프로세스가 임계구역에 들어갈 수 있어야 함
* **제한이 있는 대기시간(Bounded Waiting)**: 특정 프로세스가 임계구역에 들어가기 위해 무한정 기다리지 않아야 함

이를 통해 프로세스들이 공유 자원을 안전하게 사용할 수 있도록 보장하며, 데이터의 일관성과 정합성을 유지할 수 있다.

다음은 프로세스 동기화의 임계 구역 문제를 해결하기 위한 알고리즘들이다.

## Peterson’s Solution
**피터슨의 해결안**은 두 개의 프로세스가 두 개의 데이터 항목을 공유하게 하도록하여 해결하는 방법이다. `turn`은 임계구역으로 진입할 순번을 표시하고, `flag`는 프로세스가 임계구역으로 진입할 준비가 되었다는 여부를 표시하는 변수이다.

![Peterson](/assets/img/240602/Peterson.png)

임계 구역에 진입을 시도한다면 각 프로세스는 자신의 `flag`를 `True`로 설정하여 임계 구역에 진입하려는 의사를 표시한다. `turn`변수를 사용하여 임계 구역에 진입할 순번을 파악한다. `turn`의 순서대로 임계 구역에 진입하여 공유 자원에 접근한다. 임계 구역을 떠나게 된다면, 떠나기 전에 자신의 `flag`를 `False`로 변경하여 다른 프로세스가 임계 구역에 진입할 수 있도록 한다.

피터슨의 해결안은 임계 구역 문제를 해결하기 위한 세 가지 조건을 모두 만족 시켰다. 상호배제하면서 진행하였고, `turn`을 사용하여 제한이 있는 대기시간으로 무한정 임계 구역을 기다리지 않게 되었다.

하지만, 피터슨의 해결방안은 하드웨어적으로 특별한 지원을 요구하지 않지만 대부분의 현대 컴퓨터는 동기화를 위해 하드웨어 기반의 락[^fn-nth-2]을 사용한다. 이로 인해 피터슨의 알고리즘은 실용적인 환경에서 덜 사용된다.

## Mutex Lock
**뮤텍스 락(Mutex Lock)**은 프로세스가 임계 구역에 안전하게 접근할 수 있도록 하는 동기화 동구이다. 

![Mutex Lock](/assets/img/240602/Mutext Lock.png){: .normal }

프로세스는 임계 영역에 진입하기 전 반드시 락을 획득해야 한다. 임계 영역 사용 종료 시 잠금이 해제된다. 

뮤텍스 락은 직관적이고 간단하게 사용할 수 있고, 다양한 환경에서 사용이 가능하다. 하지만, **Busy waiting 가능성**이 여전히 존재한다. **Busy Waiting**은 프로세스가 필요한 조건이 충족될 때까지 반복적으로 확인하며 CPU 자원을 소비하기 때문에, 조건이 만족될 때까지 무의미하게 루프를 계속 돌면서 자원을 효율적으로 사용하지 못하는 단점이 있다.

## Semaphore
뮤텍스 락보다 더 정교하게 동기화 할 수 있는 방법이 필요해졌다. 이에따라 **세마포어(Semaphore)**가 등장하였다. 세마포어는 정적 변수인 S와 두 가지 기본 연산인 **P(Proberen)**와 **V(Verhogen)** 연산을 통해 작동한다. P연산은 세마포어 값을 감소시키며, 값이 0보다 작아지면 프로세스는 대기 상태에 들어간다. V연산은 세마포어 값을 증가시키며, 값이 0보다 크면 대기 중인 프로세스에게 자원 사용을 허가 한다.

```c
wait(S) {
    while (S <= 0) /* busy wait */
    S--;
}
signal(S) {
    S++;
}
```

세마포어는 이진 세마포어와 카운팅 세마포어가 있다. **이진 세마포어(Binary Semaphore)**는 0과 1의 값만 가지며, Mutex Lock과 비슷한 동작을 한다. **카운팅 세마포어(Counting Semaphore)**는 0 이상의 값을 가지며, 유한한 개수를 가진 자원에 대한 접근을 사용하는 데 사용한다. 이때 카운팅은 자원의 개수를 나타내며, 자원의 최대 개수를 설정할 수 있다.

## 교착상태(Deadlock)
**교착상태(Deadlock)**는 두 개 이상의 프로세스가 서로 상대방이 점유하고 있는 자원을 기다리며 무한히 대기하는 상태이다. 이러한 상황에서는 해당 프로세스들이 더 이상 진행할 수 없게 된다.

![Deadlock](/assets/img/240602/Deadlock.png)

교착 상태가 발생하기 위해서는 다음 네 가지 조건이 동시에 만족되어야 한다.
* **상호 배제(Mutual Exclusion)**: 두 프로세스는 동시에 같은 자원에 접근할 수 없음
* **점유와 대기(Hold and Wait)**: 자원을 점유하고 있는 프로세스가 다른 자원을 추가로 요청하면서 대기 상태에 들어감
* **비선점(No Preemption)**: 이미 할당된 자원을 강제로 빼앗을 수 없음
* **순환 대기(Circular Wait)**: 대기하고 있는 프로세스 간에 순환 형태로 자원 대기가 발생

교착 상태를 방지하기 위해서는 다음과 같다.
* **상호 배제(Mutual Exclusion)**: 공유 가능한 자원을 설정하여 상호 배제 조건을 제거한다. 하지만, 대부분의 자원은 공유가 불가능하므로 현실적이지 않다.
* **점유와 대기(Hold and Wait)**: 프로세스가 자원을 요청할 때는 모든 자원을 한 번에 요청한다. 하지만 이는 자원 활용도가 낮고, 기아 문제가 발생할 수 있다.
* **비선점(No Preemption)**: 이미 할당된 자원을 선점할 수 있도록 한다.
* **순환 대기(Circular Wait)**: 자원에 순서를 부여하고, 프로세스가 자원을 요청할 때 정해진 순서대로만 요청할 수 있게 한다.

교착 상태를 회피하는 방법으로는 **은행가 알고리즘(Banker's Algorithm)**이 있다.

### 은행가 알고리즘(Banker's Algorithm)
**은행가 알고리즘(Banker's Algorithm)**은 교착 상태가 발생하지 않도록 시스템 상태를 모니터링하고 자원을 할당하는 방법이다. 상태는 안전 상태(Safe State)와 불안전 상태(Unsafe State)가 있다. 안전 상태를 유지할 수 있는 요청만을 수락하고, 불안전 상태의 경우 추후 만족하는 상태로 바뀔 때까지 계속 거절한다.

![Banker Algorithm](/assets/img/240602/Banker Algorithm.png)

이러한 프로세스들이 있다고 가정할 때, T0는 불안전 상태여서 T1으로 넘어간다. T1의 요구를 들어주고, T2로 이동한다. 이 때, 사용할 수 있는 자원량은 A, B, C 순서대로 4, 5, 4이다. T2 요구사항을 보면 불안전 상태인 것을 알 수 있고 T3로 이동한다. T3는 안전상태기 때문에 T3의 요구를 들어주고 T4로 이동한다. 이 때, 사용할 수 있는 자원량은 4, 6, 5이다. 이런식으로 반복하면 안전 상태를 T1, T3, T4, T2, T0 순서대로 만들어 교착상태를 회피할 수 있다.

## 기아 상태(Starvation)
**기아 상태(Starvation)**는 하나의 프로세스가 필요한 자원을 무한히 기다리면서 실행 기회를 얻지 못하는 상태이다. 기아 상태는 자원 할당 및 스케줄링 과정에서 발생할 수 있다. 기아 상태는 Aging기법을 사용하여 해결할 수 있다. **Aging 기법**은 장시간 기다리는 프로세스나 스레드의 우선순위를 점진적으로 증가시켜, 결국에는 자원을 할당받을 수 있도록 한다.

## 동기화의 고전적 문제
동기화의 고전적 문제는 프로세스가 공유 자원을 사용하는 상황에서 발생하는 문제들이다. 대표적으로 유한 버퍼 문제, Readers-Writers 문제, 식사하는 철학자들 문제가 있다.

### 유한 버퍼 문제(Bounded Buffer Problem)
**유한 버퍼 문제**는 생산자와 소비자가 공유 자원을 통해 데이터를 주고받는 문제이다. 생산자는 데이터를 생성하여 버퍼에 넣고, 소비자는 버퍼에서 데이터를 꺼내서 사용한다. 버퍼는 유한한 크기를 가지고 있으며, 생산자와 소비자가 동시에 버퍼에 접근할 때 동기화 문제가 발생할 수 있다.

이러한 문제를 **Mutex Lock, Semaphores**로 해결할 수 있다.

### Readers-Writers 문제
**Readers-Writers 문제**는 다수의 읽기 스레드(Readers)와 쓰기 스레드(Writers)가 공유 자원에 접근하는 상황이다. **읽기 스레드**는 동시에 자원에 접근할 수 있지만, **쓰기 스레드**는 자원에 독점적으로 접근해야 한다.

이를 해결하기 위한 방법으로는 쓰기 스레드가 자원에 접근하지 못하도록 읽기 스레드가 자원을 계속 점유하는 것이다. 하지만, 이는 쓰기 스레드의 기아 상태를 초래할 수 있다. 다른 방법으로는 쓰기 스레드에게 우선적으로 자원에 접근할 수 있도록 한다. 하지만 이 방법 또한 읽기 스레드의 기아 상태를 초래할 수 있다.

### 식사하는 철학자들 문제(Dining Philosophers Problem)
**식사하는 철학자들 문제(Dining Philosophers Problem)[^fn-nth-3]**는 5명의 철학자가 원형 테이블에 앉아 있고, 각 철학자 사이에 하나의 포크가 놓여 있는 상황이다. 철학자는 생각하거나 식사할 수 있다. 식사하기 위해서는 두 개의 포크가 필요한데, 철학자들이 동시에 포크를 집으려 할 때 교착 상태나 기아 상태가 발생할 수 있다.

이 문제를 해결하기 위한 여러 가지 방법이 있다.

우선 포크의 개수를 5개에서 6개로 늘려 최악의 경우 5명이 포크를 하나씩 선택해도 1명은 2개의 포크로 식사를 마치는 과정을 반복한다.

그 다음 방법으로는 한 철학자가 포크 두 개를 모두 집을 수 있을 때만 포크를 집도록 허용하는 것이다.

마지막으로 홀수 번호의 철학자는 왼쪽 포크 부터, 짝수 번호의 철학자는 짝수 포크부터 사용한다면 최소한 한 명의 철학자가 식사를 마치고 포크를 내려놓을 수 있다.

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne)

## Footnote
[^footnote]: **데이터 정합성**: 데이터가 정확하고 일관된 상태를 유지하는 것

[^fn-nth-2]: **하드웨어 기반의 락(Hardware-Based Lock)**: 프로세스가 임계 구역에 안전하게 접근할 수 있도록 하드웨어가 제공하는 특수한 명령어를 사용하는 방법

[^fn-nth-3]: **식사하는 철학자들 문제(Dining Philosophers Problem)**에서 철학자는 프로세스이고, 포크는 공유 자원이다.