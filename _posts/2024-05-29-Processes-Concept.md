---
title: Processes Concept
date: 2024-05-29 20:00:00 +0900
categories: [0x0. Computer Science, 0x1. Operating System]
tags: [OS, Processes, Process Scheduling, Context Switch]
math: true
mermaid: true
---
## 프로세스(Processes)
**프로세스(Processes)**는 **실행중인 프로그램**이다. 디스크에 저장된 파일이 메모리에 적재될 때 프로세스가 된다.

### Layout of a Process in Memory
메모리 상에서 프로세스는 다음과 같다.

![Layout of a process in memory](/assets/img/240423/Layout of a process in memory.png){: .w-50 .left}

* 커널 모드: 전체 주소에 접근 가능
* 사용자 모드: 사용자 주소 공간만 접근 가능
* **Text(Code)**: 실행 가능한 영역
* **Data**: 전역 변수, 상수값(매크로, 기호, 문자열 상수 등..)
* **Bss**: 초기화되지 않은 전역 변수
* **Stack**: 지역변수, 함수 매개변수로 운영체제에 의해 관리되며, 자동으로 메모리 할당과 해제가 이루어 짐
* **Heap**: 동적으로 할당되는 변수로 사용자에 의해 관리되며, 할당과 해제가 잘 이루어지지 않으면 메모리 누수가 발생

### 프로세스 상태(Process State)
프로세스는 실행됨에 따라 상태가 변화한다.

![Diagram of process state](/assets/img/240423/Diagram of process state.png)

* **new**: 프로세스 생성
* **running**: 명령어가 실행되고 있음
* **waiting**: 프로세스가 어떤 이벤트 발생을 기다리고 있음(ex. I/O 동작, 메세지 송수신 관리 등)
* **ready**: 프로세스가 프로세서에 할당될 준비가 됨
* **terminated**: 프로세스 실행 완료

### Process Control Block (PCB)
각 프로세스는 운영체제에서 프로세스 제어 블록(PCB)에 의해 표현된다. PCB와 관련한 내용은 다음과 같다.

![Process control block](/assets/img/240423/Process control block.png)

* **프로세스 상태(Process State)**: new, running, waiting, ready, terminated
* **프로그램 카운터(Program Counter)**: 프로세스가 다음에 실행할 명령어 주소
* **CPU 레지스터(CPU Registers)**: CPU의 임시 저장 공간
* **CPU 스케줄링 정보(CPU Scheduling Information)**: 프로세스 실행 순서를 정하는 정보
* **메모리 관리 정보(Memory-Management Information)**: 기준 레지스터와 limits레지스터의 값(페이지 테이블, 세그먼트 테이블 등)
* 입출력 상태 정보(I/O Status Information)

## Process Scheduling
운영체제가 프로세스들에게 효율적으로 자원을 할당하는 것을 **프로세스 스케줄링(Process Scheduling)**이다. **실행 빈도**에 따라 장기/중기/단기 스케쥴러로 나뉜다.

* **장기 스케줄러**
    * 실행 빈도 낮음
    * 메모리 상의 프로세스들의 수 제어
* **중기 스케줄러**
    * 메모리에서 프로세스들을 제거(메모리 상의 프로세스 수 완화)
    * 스와핑[^footnote]
* **단기 스케줄러**
    * 실행 빈도 높음

### Process Scheduling Queues
프로세스는 다양한 큐 사이를 이동하는데, 아래는 다양한 프로세스 스케줄링 큐이다.

* **Job Queue**: 프로세스가 시스템에 들어오면 Job Queue에 있음
* **Ready Queue**: 메인 메모리 안에 있으며, 실행을 대기 중인 프로세스의 집합
* **Device Queue**: I/O장치를 기다리고 있는 프로세스의 집합

## 문맥 교환(Context Switch)
프로세스에서 **문맥(Context)**은 마지막에 수행한 명령어 위치이다. 프로세스의 문맥은 PCB에 표시된다.

**문맥 교환(Context Switch)**은 CPU가 다른 프로세스로 전환할 때, 시스템은 이전 프로세스의 상태를 저장하고 새 프로세스에 대한 저장된 상태를 불러오는 것이다. 

![Context Switch](/assets/img/240529/Context Switch.png)

문맥 교환이 진행될 동안 시스템은 아무런 유용한 일을 하지 못한다.

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne)

## Footnote
[^footnote]: **스와핑(Swapping)**: 메모리에서 사용되지 않는 일부 프로세스를 보조기억장치로 내보내고, 실행할 프로세스를 메모리에 적재하는 메모리 관리 기법