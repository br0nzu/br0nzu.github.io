---
title: Frame Pointer Overwrite(One-byte Overflow)
date: 2024-10-10 15:00:00 +0900
categories: [0x01. InfoSec, 0x00. Pwnable]
tags: [Pwnable, FPO]
math: true
mermaid: true
---
**Frame Pointer Overwrite(One-byte Overflow)**는 Stack Frame Point에 최하위 1byte 덮어써서 프로그램의 실행 흐름을 제어하는 것이다. FPO 공격을 하기 위해서는 다음과 같은 조건이 필요하다.

1. 메인 함수 이외 서브함수 필요

2. **서브함수의 SFP 영역에서 1byte overflow 반드시 발생**

FPO의 동작과정은 다음과 같다.

![1byte overflow](/assets/img/Frame Pointer Overwrite/1byte overflow.png)

1. FPO는 서브함수의 Frame Pointer를 1byte Overwrite하고, 서브함수의 에필로그 때 변경된 Frame Pointer는 `leave`명령어에 의해 `EBP` 레지스터에 저장된다.

    ![leave](/assets/img/Frame Pointer Overwrite/leave.png)
    ![ret](/assets/img/Frame Pointer Overwrite/ret.png)

2. 메인함수가 종료될 때 `EBP`에 저장된 Frame Pointer는 `leave`명령어에 의해 `ESP` 레지스터에 저장된다. 

    ![main_leave](/assets/img/Frame Pointer Overwrite/main_leave.png)

3. `ret` 명령어에 의해 `buf`에 입력한 값들을 실행할 수 있다. 그래서 `buf`에 쉘코드를 넣는다면 쉘코드가 실행된다.

    ![main_ret](/assets/img/Frame Pointer Overwrite/main_ret.png)

## Ref
[1] [Frame Pointer Overwrite(One-byte Overflow)](https://www.lazenca.net/display/TEC/05.Frame+Pointer+Overwrite)