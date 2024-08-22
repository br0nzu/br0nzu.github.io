---
title: Operations on Process
date: 2024-05-29 23:50:00 +0900
categories: [0x00. Computer Science, 0x01. Operating System]
tags: [OS, Process, System Call]
math: true
mermaid: true
---
## 프로세스 생성(Process Creation)
프로그램이 실행되는 동안 프로세스는 여러 개의 새로운 프로세스들을 생성한다. 프로세스의 주체는 **부모 프로세스**이고, 새로운 프로세스는 **자식 프로세스**이다. 

![A tree of processes on a typical Linux system](/assets/img/240423/A tree of processes on a typical Linux system.png)

부모 프로세스가 자식 프로세스를 생성하며, 자식 프로세스는 다른 프로세스를 생성하여 프로세스의 트리를 형성한다. 이러한 트리 구조에서 프로세스간 부모-자식 관계는 특별한 관계를 가지게 되고, 몇 가지 이슈가 생긴다.

* 자원 공유 관점
    * 부모와 자식이 모든 자원을 공유(`fork`)
    * 자식이 부모 자원의 부분집합을 공유
    * 부모와 자식이 자원을 공유하지 않는 경우
* 실행 시점
    * 부모와 자식이 동시에 실행
    * 부모가 자식 프로세스들이 종료될 때까지 기다림(`wait`)
* 주소 공간
    * 자식 프로세스가 부모 프로세스의 주소 영역 복제(`fork`)
    * 자식 프로그램이 복제된 주소 공간에 로드(`exec`)

![Process creation using the fork() system call](/assets/img/240423/Process creation using the fork() system call.png)

자식 프로세스는 **리소스 권한, 스케줄링 속성**을 부모 프로세스로부터 상속 받는다.

### UNIX Process Creation
#### fork() system call
`fork()`는 부모 프로세스에서 자식 프로세스를 생성하는 시스템 콜이다.

```c
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>

int main(){
	pid_t pid;	

	pid=fork();	
	if(pid>0)	
		printf("\nI am parent of pid=%d!\n",pid);

	else if(!pid)
		printf("I am the child!\n",pid);
	else if(pid == -1)
		perror("fork");
	return -1;
}
```

PID가 0이 리턴되는 경우를 받는 프로세스는 **자식 프로세스**이고, **부모 프로세스**는 자식 프로세스에서 생성된 0이상의 PID를 리턴 받아서 자식 프로세스가 어떤 것인지 식별한다.

fork() 시스템 콜의 특징은 다음과 같다.

* PCB Struct User 부분 모두 상속
    * PCB Struct User - PID, Priority, Waiting Event, State, Location of image in disk
* 각 프로세스(부모-자식)은 독립적으로 실행되어, 메모리를 공유하지 않음
* 부모 프로세스는 fork() 호출로 자식 프로세스의 PID를 반환받음
* 자식 프로세스는 fork() 호출로 PID 0를 반환받음

#### exec() system call
`exec()` 시스템 콜은 디스크에서 파일 검색하여 이전의 이미지 위에 덮고, 시작위치로 점프한다. 즉 exec() 호출이 성공하면, 전달된 프로그램의 메모리로 덮어씌워 현재 프로그램 코드는 더이상 실행하지 않는다.

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

위 코드를 실행하면 `execv()`호출 이후 `printf("after executing ls –l.\n")`는 실행되지 않는다. `/bin/ls`의 프로세스 메모리로 덮어써버리기 때문에 뒤에 있던 프로그램 내용은 실행할 수가 없다.

`fork()`와 `exec()`의 차이점은 다음과 같다.

* `fork`는 같은 프로세스만 생성할 수 있지만, `exec`는 다른 프로세스를 생성할 수 있다.
* `fork`를 통해 생성된 자식 프로세스는 부모 프로세스가 종료되지 않고 독립적으로 계속 실행되지만, `exec`를 호출하면 기존 프로세스는 종료되고 새로운 프로그램으로 완전히 대체된다.

#### wait() systemcall
* 자식 프로세스가 종료될 때까지 기다림
* 자식 프로세스가 종료되면, 커널은 부모 프로세스를 깨움
* 커널은 부모 프로세스를 준비 큐에 넣음

`wait()` 시스템 콜은 자식 프로세스의 3가지 반환 코드(PID, exit status, CPU Usage)를 처리한다.

부모 프로세스가 UNIX에서 자식 프로세스의 반환코드를 처리하는 이유는 프로세스 종료의 원인을 바탕으로 부모 프로세스는 자식 프로세스의 미래 실행을 결정할 수 있기 때문이다.

만약 wait()이 구현되지 않은 경우, 자식 프로세스는 **좀비 프로세스**가 된다.

## 프로세스 종료(Process Termination)
### exit()
프로세스가 마지막 문맥(context)에 도달하고 운영 체제에 종료를 요청한다.  프로세스가 종료되면 프로세스의 자원은 운영체제가 해제한다. 그리고 자식에서 부모에게 결과 데이터를 전달한다. 

### abort()
자식 프로세스가 **자원 할당 초과**가 되면 부모 프로세스는 자식 프로세스를 종료시킨다. 또한, 부모 프로세스가 자식에게 할당한 **특정 작업이 더 이상 필요하지 않게 될 경우** 자식 프로세스를 종료시킨다.
> 부모가 종료되었고, 자식은 종료되지 않았을 때 자식 프로세스만 실행될 수 없다.
{: .prompt-info}

### Zombie Process
**좀비 프로세스(Zombie Process)**는 자식 프로세스가 종료되었지만, 부모 프로세스가 아직 `wait()`을 하지 않은 프로세스이다. `wait()` 시스템 콜을 통해 종료 상태가 읽히면, 좀비 프로세스의 pid와 프로세스 테이블 항목이 운영체제에게 반환된다.

### Orphan Process
**고아 프로세스(Orphan Process)**는 부모 프로세스가 종료된 후에도 계속 실행 중인 자식 프로세스이다. 고아 프로세스는 부모 프로세스가 먼저 종료되기 때문에 더 이상 부모 프로세스에 의해 관리되지 않는다. 운영 체제는 이러한 고아 프로세스를 방치하지 않고 고아 프로세스를 처리한다. 고아 프로세스가 되면, 운영 체제는 고아 프로세스를 새로운 부모 프로세스(`init`)로 재배치한다. `init` 프로세스는 고아 프로세스를 인수받아 관리하며, 고아 프로세스가 종료될 때까지 자원을 적절히 회수한다.
> 좀비 프로세스는 자식 프로세스가 **종료**되었지만 아직 부모 프로세스가 종료 상태를 수집하지 않은 것이고, 고아 프로세스는 부모 프로세스가 종료되어 더 이상 부모 프로세스가 없는 **실행 중**인 자식 프로세스이다.
{: .prompt-tip}


## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne)

[2] [Process Creation & Termination](https://m.blog.naver.com/sooftware/221744368058)