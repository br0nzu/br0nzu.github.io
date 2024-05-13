---
title: 2. 입출력
date: 2024-02-25 09:00:00 +0900
categories: [CODE TREE, NOVICE LOW]
tags: [Programming, CodeTree, NOVICE LOW]
math: true
mermaid: true
---
`<stdio.h>`

입력 = `scanf`

## 정수 입력
```c
int i;
scanf("%d", &i);
```

## 실수 입력
```c
double d;
scanf("%lf", &d);
```

## 공백을 사이에 두고 입력
scanf를 통해 `%d` 포맷으로 입력을 받는경우, 입력으로 주어지는 모든 공백은 무시

## 2개의 줄에 걸쳐 입력
C에서는 줄을 바꿔주는 `\n` 역시 공백(white space)에 포함

## 문자, 문자열 입력
* 문자 1개 입력: char 변수와 `%c` 포맷을 이용
* 문자열 1개 입력: char[] type 과 `%s` 포맷을 이용

변수 주소 자리에 & 없이 **변수 이름 자체**가 들어가야 한다. 이는 문자열은 char 들의 배열에 받을 수 있고, 문자열이 담긴 배열의 주소는 **변수의 이름이 곧 주소**가 되기 때문이다.

### 문자열에 값을 넣어주는 방법 3가지
1. 문자열 선언과 동시에 값 초기화
```c
char str[7] = "Hello!";
```
2. strcpy 함수 사용하여 값 넣어주기(string.h 포함)
```c
char str[7];
strcpy(str, "Hello!");
```
3. scnaf 함수로 값 직접 입력받아 넣어주기
```c
char str[7];
scanf("%s", str);
```

## 특정 문자를 사이에 두고 입력
두 수가 공백이 아닌 특정 문자를 사이에 두고 입력으로 들어는 경우에는, scanf 안의 문자열 내에서 그 특정 문자를 받아주어야 한다.

## 후기
공백과 특정 문자 입력을 유의 있게 봤고, `scanf`를 `scnaf`로 실수하는 경우가 종종 있는데 주의해서 쓰면 될 것 같다. 또한, 입출력 파트는 쉬운 부분이어서 빨리 끝냈다.

> `PROCESS EXITED ON SIGNAL 11`: 프로그램이 `Segmentation fault` 오류로 종료되었다는 것을 의미합니다. 이 오류는 메모리에 액세스할 수 없는 위치에 접근하려고 할 때 발생한다.
{: .prompt-info }