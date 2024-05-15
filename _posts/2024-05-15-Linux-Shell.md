---
title: Linux Shell
date: 2024-05-15 12:00:00 +0900
categories: [Computer Science, CS Theory]
tags: [linux, shell]
math: true
mermaid: true
---
**리눅스 쉘(shell)**은 사용자 명령어 및 프로그램을 실행할 수 있는 공간이다.
![shell](/assets/img/240515/shell.png)

## 쉘 종류
쉘의 종류는 Bourne Shell과 C-type Shell이 있다.

### Bourne Shell
#### Bourne Shell(.sh)
* 1974년 Stephen Bourne이 개발
* 최초의 쉘(Shell)

#### Korn Shell(.ksh)
* Bourne Shell과 호환
* C Shell의 많은 기능(history, vi, 명령 행, 편집 등)을 포함

#### Bourne Again Shell(.bash)
* GNU 프로젝트를 위해 Brian Fox가 작성한 Shell(리눅스의 표준 Shell)
* Bourne Shell을 토대로 C Shell과 Korn Shell의 기능들을 통합시켜 개발

#### Z Shell(.zsh)
* MacOs에서 기본 Shell로 설정
* 다양한 기능, 플러그인, 테마가 존재

### C-type Shell
#### C Shell(.csh)
* 1978년 Bill Joy가 개발
* Bourne Shell의 사용성을 높이고 기능(history, alias 등) 추가

#### TC Shell(.tcsh)
* 1983년 Carnegie Mellon University의 학생들이 개발
* C Shell 에서 명령 행 완성과 명령 행 편집 기능 추가

## Ref
[1] [쉘 스크립트 종류](https://velog.io/@devnoong/Linux-%EC%89%98-%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8-%EC%A2%85%EB%A5%98)