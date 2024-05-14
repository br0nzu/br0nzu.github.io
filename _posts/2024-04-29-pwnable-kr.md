---
title: pwnable.kr settings
date: 2024-04-29 13:00:00 +0900
categories: [Misc, Settings]
tags: [settings]
math: true
mermaid: true
---
## 서버에 위치한 바이너리 다운
`scp -P 2222 ID@server addr:server_absolutepath local_absolutepath`

ex) `scp -P 2222 fd@pwnable.kr:/home/fd/fd /home/User/Desktop`

## pwntools
```py
from pwn import *

p = ssh("ID", "Server_Addr", port=2222, password="pw") # ssh 설정

p = p.process(executable="Server_AbsolutePath", argv=['argv1','argv2', ..]) # 인자가 더 있으면 추가

p.sendline() 

p.interactive()
```