---
title: 2. Process and Scheduling - CPU Scheduling
date: 2024-04-24 03:50:00 +0900
categories: [Computer Science, Operating System]
tags: [OS, Process, CPU Scheduling]
math: true
mermaid: true
---
## Basic Concepts
하나의 CPU는 한순간에 오직 하나의 프로세스만을 실행할 수 있다. **CPU 스케줄링**은 CPU가 다음에 수행할 프로세스의 실행 순서를 정하는 것을 의미한다.

프로세스 실행은 CPU 실행과 I/O 대기의 사이클로 구성된다.

![Alternating sequence of CPU and IO bursts](/assets/img/240424/Alternating sequence of CPU and IO bursts.png)

* CPU 버스트: 프로세스가 CPU를 집중적으로 사용하는 단계이다. 이 단계에서는 계산 작업이 이루어지며, 프로세스는 CPU 자원을 많이 소모한다.
* I/O 버스트: 프로세스가 입력/출력 작업을 수행하는 단계이다. 이 단계에서는 데이터를 읽거나 쓰는 등의 I/O 작업이 주를 이루며, CPU는 일반적으로 유휴 상태가 된다.

![Histogram of CPU-burst durations](/assets/img/240424/Histogram of CPU-burst durations.png)

* 많은 수의 짧은 CPU 버스트 → I/O 바운드 프로그램(CPU 연산보다는 입력과 출력 작업에 더 많은 시간을 할애)
* 소수의 긴 CPU 버스트 → CPU 바운드 프로그램(복잡한 계산이나 데이터 처리가 주 작업)

## CPU Scheduler
**CPU 스케줄링**은 프로세스 중 메모리에 있는 준비 상태의 것들을 선택하고, 그 중 하나에 CPU를 할당하는 작업이다. CPU 스케줄링 결정은 다음과 같은 상황에서 발생할 수 있다.
* 실행 상태에서 대기 상태로 전환(비선점 스케줄링)
* 실행 상태에서 준비 상태로 전환(선점 스케줄링)
* 대기 상태에서 준비 상태로 전환하거나 새로운 프로세스가 준비 상태로 전환(선점 스케줄링)
* 프로세스 종료할 때(비선점 스케줄링)

### Preemptive Scheduling
선점 스케줄링은 CPU가 현재 프로세스를 실행중일때 스케줄러에 의해 현재 프로세스의 CPU 제어권을 다른 프로세스한테 넘기는 스케줄링을 의미한다. 실행중인 프로세스가 다른 프로세스에게 CPU 제어권을 선점당하면 Running 상태에서 Ready 상태로 변하고, 입/출력을 위하여 대기 중인 상태에서 다른 프로세스가 CPU를 선점하면 Ready 상태로 전환된다.

### Non-Preemptive Scheduling
비선점 스케줄링은 CPU가 현재 실행중인 프로세스가 완료될때까지 다른 프로세스들은 대기하는 스케줄링을 의미한다. 오직 현재 실행중인 프로세스가 종료되거나 입/출력을 위하여 대기 상태(wating state)로 들어가는 경우에만 다른 프로세스들이 실행할 수 있다.

## Dispatcher
디스패처 모듈은 단기 스케줄러에 의해 선택된 프로세스에게 CPU의 제어권을 부여한다.
* 문맥 교환(Context Switching)
* 사용자 모드 변경
* 해당 프로그램을 재시작하기 위해 사용자 프로그램의 적절한 위치로 점프

디스패치 지연(Dispatch latency)은 디스패처가 한 프로세스를 중지하고 다른 프로세스를 실행하기 시작하는 데 걸리는 시간을 의미한다.

## Scheduling Criteria
스케줄링 기준에는 다음과 같은 요소들이 있다.

* CPU 이용률(CPU Utilization) : CPU 이용률은 0에서 100%까지 이릅니다. 실제 시스템에서는 40%~90%까지의 범위를 가져야 합니다.
* 처리량(Throughput) : 처리량은 단위 시간당 완료된 프로세스의 개수입니다. 긴 프로세스의 경우에는 이 비율은 시간 당 한 프로세스가 될 수도 있고, 짧은 트랜잭션인 경우 처리량은 초 당 10개의 프로세스가 될 수도 있습니다.
* 총처리 시간(Turnaround Time) : 총처리 시간은 프로세스의 제출 시간과 완료 시간의 간격입니다. 즉, 메모리에 들어가기 위해 기다리며 소비한 시간과 준비 완료 큐에서 대기한 시간, CPU에서 실행하는 시간, 입/출력 시간을 합한 시간입니다.
* 대기 시간(Wating Time) : 대기 시간은 준비 완료 큐에서 대기하면서 보낸 시간의 합입니다.
* 응답 시간(Response Time) : 응답 시간은 하나의 요구를 제출한 후 첫번째 응답이 나올 때까지의 시간입니다.

`-----------추후 작성-----------`













## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne) 
