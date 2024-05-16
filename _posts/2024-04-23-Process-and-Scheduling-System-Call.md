---
title: 2. Process and Scheduling - System Call
date: 2024-04-23 13:20:00 +0900
categories: [0x0. Computer Science, 0x1. Operating System]
tags: [OS, Process, Scheduling, System Call]
math: true
mermaid: true
---
## Process Creation
부모 프로세스가 자식 프로세스를 생성하며, 자식 프로세스는 다른 프로세스를 생성하여 프로세스의 트리를 형성한다.

![A tree of processes on a typical Linux system](/assets/img/240423/A tree of processes on a typical Linux system.png)

프로세스는 다음과 같은 기준에 따라 분류된다.

* 프로세스 계층에서의 자원 공유 유형
    * 부모와 자식이 모든 자원을 공유(UNIX)
    * 자식이 부모 자원의 부분집합을 공유
    * 부모와 자식이 자원을 공유하지 않음

* 실행
    * 부모와 자식 동시에 실행
    * 부모는 자식 프로세스들이 종료될때까지 기다림(UNIX)

* 주소 공간
    * 자식 프로세스는 부모 프로세스 주소 영역을 복제
    * 자식 프로그램은 복제된 주소 공간에 로드
    * UNIX 예시
        * **fork** 시스템 콜은 새 프로세스를 만듦
        * **exec** 시스템 콜은 fork 이후에 사용되어 프로세스의 메모리 공간을 새 프로그램으로 교체

![Process creation using the fork() system call](/assets/img/240423/Process creation using the fork() system call.png)

### UNIX Process Creation
kernel system calls for process management

#### fork() system call
* 자기 자신의 복사본을 생성(부모의 논리적 복사)
* PCB Struct User 부분 모두 상속
    * PCB Struct User - PID, Priority, Waiting Event, State, Location of image in disk
* PID 부분만 다르고 나머지 동일
    * 부모 프로세스는 fork() 호출로 자식 프로세스의 프로세스 번호를 반환받음
    * 자식 프로세스는 부모 프로세스에게 프로세스 번호 0를 반환받음
* 메모리를 공유하지 않음

#### exec() system call
exec() 시스템 콜은 디스크에서 파일 검색하고 이전의 이미지 위에 덮고, 시작위치로 점프한다. 즉 exec() 호출이 성공하면, 현재 프로그램 코드는 더이상 실행하지 않는다.

```c
#include <stdio.h>
#include <unistd.h>

int main() {
    char *arg[] = {"ls", "-l", (char *)0};
	printf("before executing ls -l\n");
	execv("/bin/ls", arg);
	printf("after executing ls –l.\n");
}
```
위 코드를 실행하면 `execv()`호출 이후 `printf("after executing ls –l.\n")`는 실행되지 않는다.

> `fork`는 같은 프로세스만 생성할 수 있지만, `exec`는 다른 프로세스를 생성할 수 있다.
{: .prompt-tip }
> `fork`를 통해 생성된 자식 프로세스는 부모 프로세스가 종료되지 않고 독립적으로 계속 실행되지만, `exec`를 호출하면 기존 프로세스는 종료되고 새로운 프로그램으로 완전히 대체된다.
{: .prompt-tip }

#### wait() system call
* 자식 프로세스가 종료될 때까지 기다림
* 자식 프로세스가 종료되면, 커널은 부모 프로세스를 깨움
* 커널은 부모 프로세스를 준비 큐에 넣음

wait() 시스템 콜은 자식 프로세스의 3가지 반환 코드(PID, exit status, CPU Usage)를 처리한다.

부모 프로세스가 UNIX에서 자식 프로세스의 반환코드를 처리하는 이유는 프로세스 종료의 원인을 바탕으로 부모 프로세스는 자식 프로세스의 미래 실행을 결정할 수 있기 때문이다.

만약 wait()이 구현되지 않은 경우, 자식 프로세스는 좀비 프로세스(실행이 종료되었지만 삭제되지 않은 프로세스)가 된다.

## Process Termination
### exit()
프로세스가 마지막 문장에 도달하고 운영 체제에 종료를 요청한다. 프로세스가 종료되면 프로세스의 자원은 운영체제가 해제한다. 그리고 자식에서 부모에게 결과 데이터를 전달한다. 

### abort
자식 프로세스가 자원 할당 초과가 되면 부모 프로세스는 자식 프로세스를 종료시킨다. 또한, 부모 프로세스가 자식에게 할당한 특정 작업이 더 이상 필요하지 않게 될 경우 자식 프로세스를 종료시킨다. 

## Zombie process
좀비 프로세스는 메모리 컨텍스트가 이미 해제되었지만, 프로세스 테이블 내에 여전히 존재하는 프로세스이다. `wait()` 시스템 콜을 통해 종료 상태가 읽히면, 좀비 프로세스의 항목은 프로세스 테이블에서 제거된다.

> `init` 프로세스(PID 1)은 좀비 프로세스의 반환 코드를 처리하는 역할을 한다.
{: .prompt-info }

## Cooperating Processes
독립적인 프로세스는 다른 프로세스의 실행 의해 영향을 받거나 줄 수 없다. **협력 프로세스**는 다른 프로세스의 실행에 영향을 주거나 받을 수 있다.

협력 프로세스의 장점은 다음과 같다.
* 정보 공유
* 계산 속도 향상
* 모듈성
* 편의성

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne) 
