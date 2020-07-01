# CPU

基础概念

- 处理器 第七章 进程调度
- 核
- 硬件线程
- CPU内存缓存  课外知识： numa
- 时钟频率 第六章 定时测量
- 每指令周期数CPI和每周期指令数IPC
- CPU指令
- 使用率
- 用户时间／内核时间
- 调度器 第七章 进程调度
- 运行队列 第七章进程调度
- 抢占
- 多进程 第三章 进程
- 多线程 第三章 进程
- 字长

排查常用命令

* uptime
* vmstat
* mpstat
* top
* sar -u
* pidstat
* perf

# 内存

- 主存   第二章 内存寻址 第八章 内存管理
- 虚拟内存
- 常驻内存
- 地址空间
- OOM
- 页缓存  第十五章 页高速缓存
- 缺页 第九章 进程的地址空间
- 换页
- 交换空间
- 交换  第十七章 回收页框
- 用户分配器libc、glibc、libmalloc和mtmalloc  第九章 进程地址空间
- LINUX内核级SLUB分配器    第八章内存管理

常用的几个命令

* free
* vmstat
* top
* pidstat
* pamap
* sar -r
* dtrace
* valgrind

**说明：**

- free,vmstat,top,pidstat,pmap只能统计内存信息以及进程的内存使用情况。
- valgrind可以分析内存泄漏问题。
- dtrace动态跟踪。需要对内核函数有很深入的了解，通过D语言编写脚本完成跟踪。

# 磁盘

- 文件系统 第十二章 虚拟文件系统
- VFS 第十二章 虚拟文件系统
- 文件系统缓存  第十六章 访问文件
- 页缓存page cache 
- 缓冲区高速缓存buffer cache
- 目录缓存 
- inode
- inode缓存
- noop调用策略

常用命令

* iostat
* iotop
* pidstat
* perf

# 网络

网络的监测是所有 Linux 子系统里面最复杂的，有太多的因素在里面，比如：延迟、阻塞、冲突、丢包等，更糟的是与 Linux 主机相连的路由器、交换机、无线信号都会影响到整体网络并且很难判断是因为 Linux 网络子系统的问题还是别的设备的问题，增加了监测和判断的复杂度。现在我们使用的所有网卡都称为自适应网卡，意思是说能根据网络上的不同网络设备导致的不同网络速度和工作模式进行自动调整。

* ping
* tracerout
* netstat
* ss
* host
* tcpdump
* tcpflow
* sar -n DEV
* sar -n SOCK

# 系统负载

* top
* uptime
* strace
* vmstat
* dmesg

# 火焰图

