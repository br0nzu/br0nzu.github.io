---
title: IDA 원격 디버깅
date: 2024-09-02 05:00:00 +0900
categories: [Misc, Settings]
tags: [IDA]
math: true
mermaid: true
---
IDA의 원격 디버깅 설정은 다음과 같다. 먼저 IDA가 설치된 파일을 보면 `dbgsrv`라는 폴더가 있다. 

![dbgsrv files](/assets/img/Remote Debugger IDA/dbgsrv files.png)

해당 파일에서 디버깅하려는 시스템의 OS 버전에 맞는 원격 디버거 서버를 선택하고, 해당 파일을 원격 시스템에 복사한다. 

## Linux
만약 리눅스 64비트 환경에서 디버깅하고 싶다면 `linux_server64`를 원격 서버에 복사하면 된다. 원격 서버에서 `linux_server64` 파일을 실행하고 IDA의 디버거를 선택하면 된다. 또한, IDA 상단 메뉴에서 Debuuger → Prcess option을 선택하면 다음과 같은 창이 나온다.

![IDA Linux gdb](/assets/img/Remote Debugger IDA/IDA Linux gdb.png)

위처럼 설정하고 실행하면 된다.

## Remote GDB

```sh
sudo apt-get install gdbserver
```
먼저 gdbserver를 설치한다. 이제 Debuuger → Prcess option을 선택하면 다음과 같은 창이 나온다.

![IDA gdb](/assets/img/Remote Debugger IDA/IDA gdb.png)

이제 원격 서버에서 다음과 같은 명령어를 입력하면 된다.

```sh
gdbserver RemoteServerIP:PORT ./Target (Parameters)
```
`Target`은 실행할 파일이고, `Parameters`는 실행 파일에 넘겨줄 인자이다.


## Ref
[1] [[IDA] 원격 디버깅](https://biji-jjigae.tistory.com/64)

[2] [Linux remote debugging using IDA pro](https://jkns.kr/entry/Linux-remote-debugging-using-IDA-pro)