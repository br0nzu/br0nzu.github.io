---
title: NOVICE LOW 6. 다중 반복문
date: 2024-04-03 18:45:00 +0900
categories: [0x7. Problem Solving, 0x0. CODE TREE]
tags: [Programming, CodeTree, NOVICE LOW]
math: true
mermaid: true
---
바깥 for문은 행을 나타내고, 안쪽의 for문은 열을 나타낸다. 

```python
for i in range(행의_수):        # 바깥쪽 for문은 각 행을 순회
    for j in range(열의_수):    # 안쪽 for문은 해당 행의 각 열을 순회
                               # (i, j) 위치의 원소에 접근하거나 처리
```

## 후기
단순 반복문과 위의 개념으로 문제에 나와 있는 규칙을 파악하며 풀면 된다. 문제를 무지성으로 풀지 말고, 규칙이 무엇인가 생각하면서 푸는 것이 중요하다.