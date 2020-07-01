namespace

linux 创建进程时 namespace 是怎么工作的

https://blog.csdn.net/energysober/article/details/89303542  源代码路径分析



cgroup 文章

https://fuckcloudnative.io/posts/understanding-cgroups-part-2-cpu/  cpu-cgroup的具体使用



Vxlan

https://cizixs.com/2017/09/25/vxlan-protocol-introduction/ 

vxlan 是overlay 网络，通过vtep 封包；然后实现三层可达

Vxlan 的主要问题集中在对方的vtep的ip地址以及对端虚拟机的mac地址



Flannel 如何解决这个问题的呢

l2miss l3miss 数据存储中心化，通过etcd进行l2 l3数据的下发，不必flanneld进行去自主的学习。



calico是个三层网络，通过bgp协议，学习路由信息。



对比flanne 和calico，flannel host-gateway 是etcd分配ip 段 然后写入本机路由表（公共ip 分发的物理机），并写入核心Tor设备（集群间互通）

calico规划宿主机的容器网段，然后各节点的agent通过BGP协议学习各宿主机的的信息和网段的对应关系





cni

https://wiki.opskumu.com/kubernetes/wang-luo-fang-an/src-kubelet-cni

kubelet cni 原理，在kubelet 里怎么进行调用



https://yucs.github.io/2017/12/06/2017-12-6-CNI/

cni 的原理以及具体的原理实现





