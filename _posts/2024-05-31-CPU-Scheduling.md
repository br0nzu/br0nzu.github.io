---
title: CPU Scheduling
date: 2024-05-31 04:45:00 +0900
categories: [0x0. Computer Science, 0x1. Operating System]
tags: [OS, Thread, CPU Scheduling]
math: true
mermaid: true
---
## CPU Scheduling
**CPU 스케줄링(CPU Scheduling)**은 CPU를 여러 프로세스나 스레드에 효율적으로 할당하는 방식이다. CPU 스케줄링의 주요 목표는 CPU 이용률을 최대화하여 자원을 효율적으로 사용하는 것이다. 이러한 목표를 달성하기 위해 운영체제는 다음과 같은 개념을 사용한다.

![Alternating sequence of CPU and I/O bursts](/assets/img/240531/Alternating sequence of CPU and I-O bursts.png){: .normal}

* **CPU-I/O 버스트(Burst)**[^footnote] 사이클
    * 프로세스 실행은 CPU 실행과 I/O 대기로 구성
    * CPU 버스트: 프로세스가 CPU에서 실제로 실행되는 시간
    * I/O 버스트: 프로세스가 I/O 작업을 수행하는 시간

![Histogram of CPU-burst durations](/assets/img/240531/Histogram of CPU-burst durations.png)

* CPU 버스트 분포: 많은 수의 짧은 CPU 버스트와 적은 수의 긴 CPU 버스트가 존재
    * I/O-bound 프로그램: 많은 수의 짧은 CPU 버스트를 갖고, 이는 주로 I/O 작업을 많이 하는 프로그램
    * CPU-bound 프로그램: 적은 수의 긴 CPU 버스트를 갖고, 이는 주로 계산 작업을 많이 하는 프로그램

## CPU Scheduler
**CPU 스케줄러(CPU Scheduler)**는 메모리에 있는 프로세스 중 실행할 준비가 되어있는 ready상태의 프로세스를 선택하고, 그 프로세스에 CPU를 할당한다. CPU 스케줄링 결정은 다음의 네 가지 상황에서 발생한다.

1. 한 프로세스가 실행 상태에서 대기 상태로 전환될 때
2. 프로세스가 실행 상태에서 준비 완료 상태로 전환될 때
3. 프로세스가 대기 상태에서 준비 완료 상태로 전환될 때
4. 프로세스가 종료될 때

이러한 상황에서 CPU 스케줄링 결정은 **선점형(1번, 4번)**과 **비선점형(2번, 3번)**으로 구분할 수 있다.

## Dispatcher
CPU 스케줄러가 어떤 프로세스를 실행할지 결정하면, 다음 단계는 **디스패처(Dispatcher)**의 역할이다. **디스패처**는 선택된 프로세스를 실제로 CPU에서 실행되도록 하는 역할을 담당한다. 

![The role of the dispatcher](/assets/img/240531/Alternating sequence of CPU and I-O bursts.png){: .normal }

디스패처는 다음과 같은 작업을 수행한다.

* 문맥 교환(Context Switching): 현재 실행 중인 프로세스의 상태를 저장하고, 새로운 프로세스의 상태를 복원합니다.
* 사용자 모드로 전환: 커널 모드에서 사용자 모드로 전환하여 프로세스가 사용자 모드에서 실행될 수 있도록 합니다.
* 프로그램 카운터 설정: 선택된 프로세스의 프로그램 카운터를 설정하여 CPU가 해당 프로세스의 명령어를 올바르게 실행할 수 있도록 합니다.

## Scheduling Criteria
CPU 스케줄링의 목표는 시스템 성능을 최적화하는 것이다. 이를 위해 다음과 같은 주요 스케줄링 기준이 사용된다.

* **CPU 이용률(CPU Utilization)**: CPU가 유휴 상태로 있는 시간을 최소화하고, 항상 작업을 처리하는 것이 중요
* **처리량(Throughput)**: 처리량이 높을수록 시스템의 생산성이 향상
* **총 처리 시간(Turnaround Time)**: 총 처리 시간이 짧을수록 시스템의 응답성이 향상
* **대기 시간(Waiting Time)**: 대기 시간이 짧을수록 프로세스는 더 빨리 실행
* **응답 시간(Response Time)**: 프로세스가 실행을 시작한 후 처음으로 응답을 받기까지 걸리는 시간으로, 짧은 응답 시간이 바람직 함

## Scheduling Algorithm
대표적인 CPU 스케줄링 알고리즘은 FCFS, SJF, Priority, RR 등이 있다.

### 선입 선처리 스케줄링(First-Come First-Served, FCFS)
**FCFS**는 CPU를 먼저 요청하는 프로세스가 CPU를 먼저 할당 받는다.

| Process | Burst Time |
|:--------|------------|
|    P1   |     24     |
|    P2   |      3     |
|    P3   |      3     |

![FCFS](/assets/img/240531/FCFS.png){: .normal}

위 예시처럼 P1, P2, P3 프로세스가 있다. FCFS으로 CPU 스케줄링을 할 때, 평균 대기시간은 17초((0+24+27) / 3)이다. 또한, 총 처리 시간은 27초((24+27+30) / 3)이다.

FCFS 알고리즘의 장점은 가장 간단한 CPU 스케줄링 알고리즘이고, 구현하기 간단하다. FCFS 알고리즘의 단점은 다음과 같다.
* 프로세스 순서에 따라 대기 시간 차이가 큼
* **비선점형**이기 때문에 시분할[^fn-nth-2]에 부적합

### 최단 작업 우선 스케줄링(Shortest-Job-Frist, SJF)
**SJF**는 CPU Brust가 짧을 수록 CPU에 먼저 할당을 받는다. SJF에는 선점형과 비선점형 SJF가 있다.

#### 선점형 최단 작업 우선 스케줄링(Preemptive SJF)
**선점형 SJF**는 준비 큐에 더 짧은 실행 시간을 가진 프로세스가 도착하면, 현재 실행 중인 프로세스를 중단시키고 CPU를 새로운 프로세스에 할당한다.

| Process | Arrival Time |  Burst Time  |
|:--------|--------------|--------------|
|    P1   |       0      |       8      |
|    P2   |       1      |       4      |
|    P3   |       2      |       9      |
|    P4   |       3      |       5      |

![Preemptive SJF](/assets/img/240531/Preemptive SJF.png){: .normal}

선점형 최단 작업 우선 스케줄링을 할 때, 평균 대기시간은 6.5초(((10-1)+(1-1)+(17-2)+(5-3)) / 4)이다. 

#### 비선점형 최단 작업 우선 스케줄링(Non-Preemptive SJF)
**비선점형 SJF**는 현재 실행 중인 프로세스가 완료될 때까지 CPU를 점유한다.

| Process | Arrival Time |  Burst Time  |
|:--------|--------------|--------------|
|    P1   |       0      |       7      |
|    P2   |       1      |       4      |
|    P3   |       4      |       1      |
|    P4   |       5      |       4      |

![Non Preemptive SJF](/assets/img/240531/Non Preemptive SJF.png){: .normal }

비선점형 최단 작업 우선 스케줄링을 할 때, 평균 대기시간은 4.25초((0+(7-4)+(8-1)+(12-5)) / 4)이다.

SJF는 최소의 평균 대기 시간을 가질 수 있지만, 다음 CPU 요청 길이 파악이 예측하기가 어렵다. 

### 우선 순위 스케줄링(Priority)
**우선 순위 스케줄링(Priority)**는 우선순위가 프로세스들에 연관되어 있으며, 높은 우선순위를 가진 프로세스에게 CPU를 할당한다.

| Process | Burst Time |  Priority |
|:--------|------------|-----------|
|    P1   |     10     |      3    |
|    P2   |      1     |      1    |
|    P3   |      2     |      4    |
|    P4   |      1     |      5    |
|    P5   |      5     |      2    |

![Priority](/assets/img/240531/Priority.png)

우선 순위 스케줄링을 할 때, 평균 대기 시간은 8.2초((0+1+6+16+18) / 5)이다.

우선 순위 스케줄링의 장점은 다음과 같다.
* 긴급한 작업 빠르게 처리 가능
* 시스템 응답 시간 향상 = 우선 순위가 높은 프로세스가 빠르게 실행 됨

하지만, 우선 순위가 낮은 프로세스가 계속해서 실행되지 못하고 대기하는 상태가 될 수 있다. 이는 **기아 상태**라 하는데, 노화(Aging)으로 해결할 수 있다. **Aging**은 기아 문제를 해결하기 위해, 오래 대기하는 프로세스의 우선순위를 점진적으로 높이는 방법이다.

### 라운드 로빈 스케줄링(Round Robin)
**라운드 로빈 스케줄링(Round Robin)**은 모든 프로세스에게 동일한 우선순위를 부여하고, 각 프로세스가 CPU 시간을 공평하게 나누어 사용하는 것을 목표로 한다.

| Process | Burst Time |
|:--------|------------|
|    P1   |     24     |
|    P2   |      3     |
|    P3   |      3     |

![RR](/assets/img/240531/RR.png)

Time Quantum을 4로 설정할 때 **라운드 로빈 스케줄링(Round Robin)**의 평균 대기시간은 5.6초(((10-4)+4+7) / 3)이고, 평균 총 처리 시간은 15.6초((30+7+10) / 3)이다.

라운드 로빈 스케줄링의 장점은 공정한 자원분배로 인해 시분할 시스템에 최적화 되어있다. 하지만, 시간 할당량(Time Quantum)이 너무 클 경우는 FCFS와 동일한 알고리즘이 되고 너무 작을 경우는 문맥 교환(Context Switch)에 시간을 더 뺏긴다는 단점이 있다.

### 다단계 큐 스케줄링(Multilevel Queue Scheduling)

![Multilevel Queue Scheduling](/assets/img/240531/Multilevel Queue Scheduling.png)

**다단계 큐 스케줄링(Multilevel Queue Scheduling)**은 프로세스들을 여러 개의 큐로 나누어 각 큐마다 서로 다른 스케줄링 알고리즘을 적용하는 방식이다. 각 큐는 특정 유형의 프로세스를 포함하며, 큐 간에는 우선순위가 설정되어 있다.

![Multilevel Queue Scheduling Example](/assets/img/240531/Multilevel Queue Scheduling Example.png)

위 사진을 기반으로 Q0는 quantum = 8, Q1은 quantum = 16, Q2 = FCFS라고 할 때, 새로운 프로세스가 Q0으로 진입하고 Q0에서 종료되지 않을 경우 Q1으로 이동한다. Q1으로 진입한 프로세스가 종료되지 않을 경우 Q2로 이동한다. 이러한 방식이 다단계 큐 스케줄링이다.

이러한 알고리즘 외에도 여러가지 CPU 스케줄링 알고리즘이 있다.

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne)

## Footnote
[^footnote]: **버스트(Burst)**: 프로세스가 CPU 또는 I/O 작업을 수행하는 동안의 활동 기간

[^fn-nth-2]: **시분할(Time-sharing)**: 여러 사용자가 동시에 시스템을 사용할 수 있도록 컴퓨터 자원을 분배하는 운영 체제 기법(ex. 멀티테스킹)