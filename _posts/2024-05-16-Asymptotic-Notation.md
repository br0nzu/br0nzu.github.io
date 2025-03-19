---
title: Asymptotic Notation
date: 2024-05-16 17:45:00 +0900
categories: [0x00. Computer Science, 0x03. Algorithm]
tags: [Algorithm, Asymptotic Notation]
math: true
mermaid: true
---
알고리즘을 평가하기 위해 다양한 기준을 고려할 수 있다. 주로 사용되는 기준으로는 **정확성, 작업량, 메모리 사용량, 단순성, 그리고 최적성**이 있다. 그러나 알고리즘의 성능을 평가할 때 가장 중요한 요소 중 하나는 **알고리즘 성능 수행 시간**이다. 이때 중요한 점은 알고리즘의 수행 시간을 **하드웨어에 의존하지 않는** 방식으로 측정해야 한다.

> 알고리즘 성능 수행시간에 영향을 미치는 요소는 **시간 복잡도**[^footnote]와 **공간 복잡도**[^fn-nth-2]이다. 
{: .prompt-tip }

## 점근 표기법(Asymptotic Notation)
알고리즘 수행 시간을 평가할 때 자주 사용되는 방법에 **점근 표기법(Asymptotic Notation)**이 있다. **점근 표기법**은 알고리즘의 수행 시간을 대략적으로 나타내는 방법으로 **최고차 항을 제외한 나머지 모든 항과 모든 계수를 제거**하여 표기한다.

점근 표기법은 다음과 같은 표기법이 있다.

![function](/assets/img/Asymptotic Notation/function.png)

- **O(Big O) 표기법**
    - 알고리즘 성능이 최악인 경우
    - 주어진 식을 값이 가장 큰 대표항만 남겨서 나타내는 방법법
- **Ω(Big Omega) 표기법**: 알고리즘 성능이 최선인 경우
- **Θ(Big Theta) 표기법**
    - 알고리즘이 처리해야 하는 수행 시간의 상한과 하한을 동시에 나타냄
    - $\theta(f(n)) = O(f(n)) \cap \omega(f(n))$

## Ref
[1] [[실전 알고리즘] 0x01강 - 기초 코드 작성 요령 I](https://blog.encrypted.gg/922)

## Footnote
[^footnote]: **시간 복잡도**: 입력의 크기와 문제를 해결하는 데 걸리는 시간의 상관관계

[^fn-nth-2]: **공간 복잡도**: 입력의 크기와 문제를 해결하는데 필요한 공간의 상관관계