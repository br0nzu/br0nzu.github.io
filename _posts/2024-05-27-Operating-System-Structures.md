---
title: Operating System Structures
date: 2024-05-27 06:00:00 +0900
categories: [0x0. Computer Science, 0x1. Operating System]
tags: [OS, System Call]
math: true
mermaid: true
---
## 운영체제에서 제공하는 서비스
운영체제는 **효율적인 시스템 운영**을 위해 제공하는 기능은 **자원을 할당하고, 로깅, 보안**을 제공한다. **사용자의 편의성**을 위해 다음과 같은 기능을 제공한다.
* 유저 인터페이스(GUI, CLI, UI)
* 프로그램 실행: 시스템은 메모리에 프로그램을 적재하고, 실행 및 종료 함
* I/O 수행
* 파일시스템 조작: 사용자 권한 관리, 파일 및 디렉토리 읽기/쓰기/생성/삭제 지원
* 통신

## 시스템 콜(System Call)
운영체제에는 **사용자 모드**와 **커널 모드**가 있다. 이렇게 모드가 나눠진 이유는 사용자에게 제한을 두어 메모리 내의 주요 운영체제 자원에 직접적으로 접근할 수 없도록 하기 위해서이다. **시스템 콜(System Call)**은 커널 영역의 기능을 사용자 모드가 가능하게 하는 하나의 수단이다. 즉, 프로세스가 하드웨어에 접근하여 필요한 기능을 할 수 있게 한다.

### 시스템 콜의 유형
시스템 콜의 유형은 다음과 같다.
* **프로세스 제어**
* **파일 관리**
* **장치 관리**
* **정보 유지**: 시스템 날짜, 시스템 데이터, 프로세스, 파일 및 장치 속성 가져오기 및 설정
* **통신**
* **보호**: 파일 권한 얻기 및 설정

## Ref
[1] Operating System Concepts(Silberschatz, Galvin and Gagne)