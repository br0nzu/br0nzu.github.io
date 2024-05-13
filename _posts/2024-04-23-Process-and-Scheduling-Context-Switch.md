---
title: 2. Process and Scheduling - Context Switch
date: 2024-04-23 10:00:00 +0900
categories: [Computer Science, Operating System]
tags: [OS, Process, Context Switch]
math: true
mermaid: true
---
## Process Concept
**프로세스(Process)**는 실행 중인 프로그램이다. 프로세스는 자원 할당의 단위이며, 실행은 순차적으로 진행된다. 

## Process Structure
프로세스는 메모리에서 다음과 같은 기능이 있다.
* 커널 모드: 전체 주소에 접근 가능
* 사용자 모드: 사용자 주소 공간만 접근 가능

![Layout of a process in memory](/assets/img/240423/Layout of a process in memory.png)

* **Text(Code)**: 실행가능한 코드 영역
* **Data**: 전역 변수, 상수값(매크로, 기호, 문자열 상수 등..)
* **Bss**: 초기화되지 않은 전역 변수
* **Stack**
    * 지역변수, 함수 매개변수 등
    * 운영체제에 의해 관리되며, 자동으로 메모리 할당과 해제가 이루어 짐
* **Heap**
    * 동적으로 할당되는 변수
    * 사용자에 의해 관리되며, 할당과 해제가 잘 이루어지지 않으면 메모리 누수가 발생

## Process State
프로세스는 실행됨에 따라 상태가 변화한다.

![Diagram of process state](/assets/img/240423/Diagram of process state.png)

* new: 프로세스 생성
* running: 명령어가 실행되고 있음
* waiting: 프로세스가 어떤 이벤트 발생을 기다리고 있음(ex. I/O 동작, 메세지 송수신 관리 등)
* ready: 프로세스가 프로세서에 할당될 준비가 됨
* terminated: 프로세스의 실행 완료

## Process Control Block (PCB)
운영체제에서 각각의 프로세스는 PCB로 표현된다. PCB는 하나의 프로세스에 연관된 정보들을 포함한다. PCB와 관련한 내용은 다음과 같다.

![Process control block](/assets/img/240423/Process control block.png)

* 프로세스 상태(Process State): new, running, waiting, ready, terminated
* 프로그램 카운터(Program Counter): 메모리의 다음 명령어 주소 지정
* CPU 레지스터(CPU Registers): CPU의 임시 저장 공간
* CPU 스케줄링 정보(CPU Scheduling Information): 프로세스 실행 순서를 정하는 정보
* 메모리 관리 정보(Memory-Management Information)
* 통계 정보(Accounting Information): 프로세스의 실행, 시간 제한, 실행 ID 등에 사용되는 CPU양의 정보
* 입출력 상태 정보(I/O Status Information)
* PID
* Priority
* Location of image in memory - 페이지 테이블
* Open files - 파일 테이블

## Process Scheduling
운영체제가 프로세스들에게 효율적으로 자원을 할당하는 것을 프로세스 스케줄링이다.

### Process Scheduling Queues
프로세스는 다양한 큐 사이를 이동하는데, 아래는 다양한 프로세스 스케줄링 큐이다. 
* **Job Queue**: 시스템의 모든 프로세스 집합
* **Ready Queue**: 메인 메모리 안에 있으며, 실행을 준비하고 대기중인 모든 프로세스의 집합
* **Device Queue**: I/O 장치를 기다리고 있는 프로세스의 집합

## Schedulers
* **Long-term Scheduler(Job Scheduler)**
    * 어떤 프로세스를 준비 큐로 가져올지 선택한다.
    * Job Scheduler에 의해 Job Queue → Ready Queue
    * CPU 스케줄러보다는 드물게 호출하기 때문에 조금 느려도 괜찮다.
    * 멀티 프로그래밍의 정도를 제어한다. 즉, 메모리에서 프로세스의 수를 제어한다.
* **Short-term Scheduler(CPU Scheduler)**
    * 다음에 실행될 프로세스를 선택하고 CPU에 할당한다.
    * 자주 호출되기 때문에 빨라야 한다.
* Medium-term scheduler(Swapping)
    * 프로세스를 메모리에서 제거하여 멀티 프로그래밍의 정도를 줄이는 것이 유리할 수 있음
    * 멀티 프로그래밍을 제어해야하는 이유는 쓰레싱(Thrashing) 때문이다.

## Context Switch
프로세스에서 **문맥(Context)**은 마지막에 수행한 명령어 위치이다. 프로세스의 문맥은 PCB에 표시된다.

**Context Switch**은 CPU가 다른 프로세스로 전환할 때, 시스템은 이전 프로세스의 상태를 저장하고 새 프로세스에 대한 저장된 상태를 불러오는 것이다.

* **System Context**
    * 커널에 의해 할당된 프로세스 데이터 구조
    * PCB, 페이지/세그먼트 테이블, 파일 테이블 등
* **Hardware Context**: 레지스터 정보(프로그램 카운터, 스택 포인터 등..)
* **Memory Context**: 디스크에서 메모리 공간

스위칭을 하는 동안 시스템은 작업을 수행하지 않는다.(스위칭 시간은 오버헤드)

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne) 
