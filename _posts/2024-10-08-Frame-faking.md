---
title: Frame faking(Fake EBP)
date: 2024-10-08 12:30:00 +0900
categories: [0x01. InfoSec, 0x00. Pwnable]
tags: [Pwnable]
math: true
mermaid: true
---
## Frame faking(Fake EBP)
**Frame faking**은 가짜 스택 프레임 포인터(Stack Frame Pointer)를 만들어 프로그램의 실행 흐름을 제어하는 것이다. 

해당 기법은 **RET 영역까지만 덮어쓸 수 있을 때, RET를 스택 주소나 라이브러리 주소로 덮을 수 없을 경우**에 사용되는 기법이다.

해당 공격 기법을 알기 위해서는 함수 에필로그에 대해 알아야 하기 때문에, [스택 프레임](/posts/Stack-Frame/)을 참고하면 된다.

Frame faking은 `RET`에 `leave-ret gadget`을 넣고, `EBP`에 `sh-4`의 주소를 넣어 쉘을 획득할 수 있다. 따라서, Frame faking은 다음과 같은 시나리오로 payload를 작성할 수 있다. 아키텍처에 별로 payload는 달라질 수 있고, 이번 실습에서는 x86 아키텍처를 기반으로 한다.

```sh
sh_addr(4byte) + sh + b"\x90" * (buf_size - sh_size) + (buf-4)_addr + leave-ret gadget addr
```

여기서 `sh`는 shellcode를 의미하고, `addr`은 주소를 의미한다. 

다음은 함수 에필로그의 초기 상태이다.

![init](/assets/img/Frame faking/init.png)

`leave`의 동작 과정은 다음과 같다.

![leave](/assets/img/Frame faking/leave.png)

`pop ebp`과정에서 `pop`을 했기 때문에 `esp`의 값은 증가하여 `RET`을 가리키게 되고, `ebp`는 `SFP`가 가리키는 주소(buf-4)를 가리키게 된다.

이제 `RET` 동작 과정이다. `RET`에 `leave-ret gadget`을 넣었기 때문에 `ret`이 작동하고, 함수 에필로그 과정이 한번 더 반복된다.

![ret](/assets/img/Frame faking/ret.png)

`pop`을 했기 때문에 `esp`의 값은 증가했고, `leave-ret gadget`으로 이동하여 `leave-ret` 명령을 실행한다.

![leave_ret_leave](/assets/img/Frame faking/leave_ret_gadget_leave.png)

`pop`을 했기 때문에 `esp`의 값은 증가하여 shellcode를 가리키게 된다.

![leave_ret_ret](/assets/img/Frame faking/leave_ret_gadget_ret.png)

따라서 payload는 다음과 같이 구성된다.

```sh
sh_addr(4byte) + sh + b"\x90" * (buf_size - sh_size) + (buf-4)_addr + leave-ret gadget addr
```

## Ref
[1] [Frame faking(Fake ebp)](https://www.lazenca.net/pages/viewpage.action?pageId=12189944)