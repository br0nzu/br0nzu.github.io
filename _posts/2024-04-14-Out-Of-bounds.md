---
title: Out of bounds
date: 2024-04-14 06:00:00 +0900
categories: [0x1. Pwnable, 0x0. Pwn Theory]
tags: [Pwnable, OOB]
math: true
mermaid: true
---
## Out of bounds
**Out of bounds**는 배열의 임의의 인덱스에 접근할 수 있는 취약점이다. OOB는 요소를 참조할 때, **<U>인덱스 값이 음수거나 배열의 길이를 벗어날 때 발생</U>**한다.

OOB를 방지하는 것은 전적으로 개발자의 몫이다. 왜냐하면 컴파일러는 배열의 범위를 벗어나는 인덱스를 사용해도 아무런 경고를 나타내지 않기 때문이다.

아래 예시 코드로 설명을 구체화 한다.

```c
// Name: oob.c
// Compile: gcc -o oob oob.c

#include <stdio.h>

int main() {
    int arr[10];

    printf("In Bound: \n");
    printf("arr: %p\n", arr);
    printf("arr[0]: %p\n\n", &arr[0]);

    printf("Out of Bounds: \n");
    printf("arr[-1]: %p\n", &arr[-1]);
    printf("arr[100]: %p\n", &arr[100]);

    return 0;
}
```

위 예시 코드를 컴파일하여 결과를 보면 다음과 같다.

```bash
In Bound: 
arr: 0x7ffd62e0a3b0
arr[0]: 0x7ffd62e0a3b0

Out of Bounds: 
arr[-1]: 0x7ffd62e0a3ac
arr[100]: 0x7ffd62e0a540
```

`arr[0]`과 `arr[100]`의 주소 차이는 400만큼 차이 난다.

`arr[100]` - `arr[0]` =  `0x7ffd62e0a540` - `0x7ffd62e0a3b0` = 0x190 = 4 * 100

OOB를 활용하면 임의 주소를 읽거나 쓸 수 있는데, OOB로 임의 주소의 값을 읽으려면 **<U>읽으려는 변수와 배열의 오프셋</U>**을 알아야 한다.

변수와 배열이 같은 영역에 할당되어 있다면, 둘 사이의 오프셋은 항상 일정해서 디버깅으로 알아낼 수 있다.

변수와 배열이 다른 영역에 각각 할당되어 있다면, 다른 취약점을 통해 두 변수의 주소를 구하고 차이를 계산한다.

## Ref
[1] [드림핵 시스템 해킹 강의 Out of bounds](https://dreamhack.io/lecture/roadmaps/2)
