---
title: 4. 조건문
date: 2024-02-26 10:00:00 +0900
categories: [CODE TREE, NOVICE LOW]
tags: [Programming, CodeTree, NOVICE LOW]
math: true
mermaid: true
---
## 삼항 연산자
`if-else` 로만 이루어져 있는 구문은 **삼항연산자**를 이용하면 한 줄에 표현이 가능하다.
변수 a는 조건이 참인 경우 v1값을 조건이 거짓인 경우에는 v2 값을 갖는다.
`a = 조건 ? v1 : v2;`

## if elif else 조건문
`if-else if-else` 조건문

## 비교 연산자와 조건문
비교 연산자는 식이 옳은지 틀린지에 따라 `1(참, true)` 혹은 `0(거짓, false)` 값을 반환
> C/C++는 0이 아닌 값은 true이고, 0은 false로 정의
{: .prompt-tip }

## and 기호
`&&`

## or 기호
`or`
> C에서는 조건 2개를 `&&` , `||` 등을 사용하지 않고 동시에 표현할 수 없음
{: .prompt-warning }

## and, or 혼합
and(`&&`)는 or(`||`) 보다 연산자 우선순위가 높음

## 후기
`if / else if / else 및 and / or` 조합을 적절히 잘 활용하여 코드 복잡도 최소화 생각해야 함
