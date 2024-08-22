---
title: Binary Search
date: 2024-05-16 22:45:00 +0900
categories: [0x00. Computer Science, 0x03. Algorithm]
tags: [Algorithm, Binary Search]
math: true
mermaid: true
---
**이진 탐색(Binary Search)**는 **정렬**된 데이터에서 사용할 수 있는 **탐색** 알고리즘이다. 이진 탐색 과정은 다음과 같다.

## 이진 탐색 과정
1. 데이터 중앙에 있는 요소 선택
2. 중앙 요소값과 찾고자 하는 목표값 비교
3. 목표값이 중앙 요소값보다 작다면 중앙 기준으로 데이터 왼편에 대해 이진 탐색을 수행, 크다면 오른편에 대해 이진 탐색을 수행
4. 찾고자 하는 값을 찾을 때까지 1 ~ 3단계 반복

## 이진 탐색 구현

```c
BinarySearch(List[], int Size, Target) {
    int Left, Right, Mid;
	
    Left = 0;
    Right = Size - 1;
	
    while(Left <= Right) {
        Mid = (Left + Right) / 2;
		
        if(Target == List[Mid])
            return List[Mid];
        else if(Target > List[Mid])
            Left = Mid + 1;
        else
            Right = Mid - 1;
    }
	
    return NULL;
}
```

## bsearch
C 언어 표준 라이브러리(`stdlib.h`)에 이진 탐색을 구현한 `bseaerch()`가 있다.

```c
void *bsearch(
   const void *key,     // 찾고자 하는 목표값 데이터 주소
   const void *base,    // 데이터 배열 주소
   size_t num,          // 데이터 요소 개수
   size_t width,        // 한 데이터 요소 크기
   // 비교 함수에 대한 포인터
   int ( __cdecl *compare ) (const void *key, const void *datum)    
);
```

## 이진 탐색의 성능 측정
이진 탐색은 처음 탐색을 시작할 때 탐색 대상 범위가 1/2로 줄어든다. 그 다음 시도할 때는 원래 크기 반의 반 즉, 1/4로 줄어든다. 그 다음은 1/8로 탐색의 범위가 계속 줄어들어 결국 1이되면 탐색을 종료한다. 이를 수식화하면 다음과 같다.

데이터의 크기를 n이라 하고, 탐색 반복 횟수를 x라 할 때,

<center>$1 = n \times \left(\frac{1}{2}\right)^x%$</center>

<center>$2^x = n$</center>

<center>$x = log_2n$</center>

즉, 이진 탐색의 성능은 $O(log n)$이다.

## Ref
[1] [bsearch](https://learn.microsoft.com/ko-kr/cpp/c-runtime-library/reference/bsearch?view=msvc-170)