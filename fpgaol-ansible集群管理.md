# fpgaol-ansible集群管理

仓库：[fandahao17 / fpgaol-ansible · GitLab (ustc.edu.cn)](https://git.lug.ustc.edu.cn/fandahao17/fpgaol-ansible)

项目所在位置：202.38.79.134:~/fpgaol-ansible

## 项目概览

这是管理树莓派集群的项目

一代服务器管理一代的树莓派

二代服务器管理二代的树莓派

一代通过dhcp-lease-list来获取已连接设备节点

二代通过arp -a 来获取设备节点列表

二代的dhcp动态地址分配是通过dnsmasq来实现的

```
sudo systemctl restart dnsmasq
```

相关链接：https://linuxhint.com/dnsmasq_ubuntu_server/

## 管理方式

### yml脚本管理

通过yml脚本一键管理树莓派

### shell文件管理

通过写sh文件，然后运行来管理树莓派节点

### python管理

从文件中读取树莓派节点地址列表，逐个执行命令进行管理

