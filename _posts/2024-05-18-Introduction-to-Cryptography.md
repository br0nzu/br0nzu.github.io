---
title: Introduction to Cryptography
date: 2024-05-18 16:00:00 +0900
categories: [0x3. Crypto, 0x0. Crypto Theory]
tags: [Crypto]
math: true
mermaid: true
---
**암호기술**은 중요한 정보를 읽기 어려운 값으로 변환하여 제 3자가 볼 수 없도록 하는 기술이다. 이 기술의 안전성은 수학적인 원리에 기반하며, 보안에 있어서 중요한 정보를 직접적으로 보호하는 핵심 기술이다. 

암호기술을 통해 보호하려는 원본 데이터를 **평문(plaintext)**라고 하며, 평문에 암호기술을 적용한 결과를 **암호문(ciphertext)**라 한다. 평문을 암호문으로 변환하는 과정을 **암호화(encryption)**라고 하며, 암호문을 다시 평문으로 복원하는 과정을 **복호화(decryption)**라고 한다. 암호화하기 위해서는 암호 **키(key)**가 필요하며, 이 키가 있어야만 암호문을 복호화할 수 있다.

암호기술을 이용하여 **데이터 기밀성, 데이터 무결성, 인증 및 부인 방지** 등의 기능을 제공할 수 있다.

## 케르크호프스의 원리(Kerckhoffs's Principle)
케르크호프스의 원리는 암호 시스템의 안전성을 보장하기 위해 따라야 할 중요한 원칙 중 하나이다. 케르크호프스의 원리는 다음과 같다.

```text
The system must be practically, if not mathematically, indecipherable
It should not require secrecy, and it should not be a problem if it falls into enemy hands
It must be possible to communicate and remember the key without using written notes, and correspondents must be able to change or modify it at will
It must be applicable to telegraph communications
It must be portable, and should not require several persons to handle or operate
Lastly, given the circumstances in which it is to be used, the system must be easy to use and should not be stressful to use or require its users to know and comply with a long list of rules.
```

위 내용 중에서 케르크호프스는 2번 항목을 중요시 했다. 즉, 암호 알고리즘의 비밀은 유지되기 어렵기 때문에 비밀키를 잘 보호 해야한다는 **비밀키의 중요성**을 강조했다.

## 암호기술 분류
암호 기술에는 **일방향 암호기술**과 **양방향 암호기술**이 있다.

### 일방향 암호기술
**일방향 암호기술**은 주로 **해시 함수**로 구현되며, 한 번 데이터를 변환하면 원래 데이터를 복원하는 것이 매우 어렵거나 불가능하다. 이러한 기술에는 데이터의 무결성을 제공하는 MD5, SHA-2, SHA-3 등이 있으며, 무결성과 인증을 제공하는 HMAC 등이 있다.

### 양방향 암호기술
**양방향 암호기술**은 복호화와 암호화가 모두 가능한 암호기술로, **대칭키 암호기술**과 **비대칭키 암호기술**이 있다.

#### 대칭키 암호기술
**대칭키 암호기술**은 암호화 키와 복호화 키가 동일한 암호기술이다. 대칭키 암호기술에는 **스트림 암호**와 **블록 암호**가 있다. **스트림 암호**는 데이터를 연속적인 비트나 바이트 단위로 암호화하며, 주로 실시간 데이터 암호화에 사용된다. 스트림 암호는 기밀성을 제공하며, 대표적인 예로 RC4가 있다. **블록 암호**는 데이터를 고정된 크기의 블록 단위로 암호화한다. 블록 암호는 기밀성과 더불어 인증 기능도 제공할 수 있다. 대표적인 블록 암호로는 AES가 있다.

#### 비대칭키 암호기술
**비대칭키 암호기술**은 암호화 키와 복호화 키가 서로 다른 암호기술이다. 비대칭키 암호기술은 기밀성, 인증, 부인방지 기능을 제공한다. 대표적인 비대칭키 암호로는 RSA가 있으며, 이 외에도 ECC와 같은 알고리즘이 있다. 비대칭키 암호기술은 주로 안전한 키 교환, 디지털 서명, 그리고 데이터 암호화에 사용된다.

## Ref
[1] [암호기술의 정의](https://seed.kisa.or.kr/kisa/intro/EgovDefinition.do)

[2] [케르크호프스의 원리](https://ko.wikipedia.org/wiki/%EC%BC%80%EB%A5%B4%ED%81%AC%ED%98%B8%ED%94%84%EC%8A%A4%EC%9D%98_%EC%9B%90%EB%A6%AC)