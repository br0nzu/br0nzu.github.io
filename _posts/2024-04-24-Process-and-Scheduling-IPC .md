---
title: 2. Process and Scheduling - IPC, Synchronization
date: 2024-04-24 00:20:00 +0900
categories: [Computer Science, Operating System]
tags: [OS, Process, Scheduling, IPC, Synchronization]
math: true
mermaid: true
---
## Interprocess Communication (IPC)
**IPC**는 프로세스들간의 통신하는 방법을 의미한다. IPC는 send/receive를 통해 메세지를 전달하여 통신한다.

프로세스가 통신을 해야한다면 서로간의 **통신 링크**를 설정하여 send/receive를 통해 메세지를 교환한다.

IPC는 두 가지 유형이 있다.
* 직접 통신(Direct Communication): 프로세스가 서로 직접적으로 주소를 명시하여 메시지를 주고받는다.
* 간접 통신(Indirect Communication): 메시지 큐나 공유 데이터 구조 같은 중간 엔티티를 통해 메시지가 전송된다.

![Communications models](/assets/img/240424/Communications models.png)

### Direct Communication
프로세스는 서로를 명시적으로 지정해야한다.

직접 통신의 통신 링크 특성은 다음과 같다.
* 링크는 서로 인식하여 자동 설정된다.
* 링크는 정확히 한 쌍의 통신하는 프로세스와 연관된다.
* 각 쌍 사이에는 정확히 하나의 링크가 존재한다.
* 링크는 단방향일 수 있지만, 보통은 양방향이다.

### Indirect Communication
메세지는 포트로 보내지고 받아진다. 각 포트는 고유한 ID가 있고, 프로세스는 같은 포트를 공유할 때만 통신할 수 있다.


간접 통신의 통신 링크 특성은 다음과 같다.
* 링크는 오직 프로세스들이 같은 포트를 공유하는 경우에만 설정된다.
* 링크는 여러 프로세스와 연관될 수 있다.
* 링크는 단방향이거나 양방향이다.

## Synchronization
메세지 전달은 차단(blocking) 또는 비차단(non-blocking)일 수 있다.

차단은 **<U>동기</U>**로 간주된다. **차단 전송**은 송신자가 메세지 수신될 때까지 차단된다. **차단 수신**은 수신자가 메세지가 사용 가능할 때까지 차단된다.

비차단은 **<U>비동기</U>**로 간주된다. **비차단 전송**은 송신자가 메세지를 보내고 다른 작업을 계속한다. **비차단 수신**은 수신자가 유효한 메세지가 없을 때 다른 작업을 수행한다.

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne) 
