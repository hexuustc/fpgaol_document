# fpgaol_pi_ng文档

仓库：[cyh / fpgaol_pi_NG · GitLab (ustc.edu.cn)](https://git.lug.ustc.edu.cn/cyh/fpgaol_pi_ng)

使用说明：[he xu / FPGAOL-Examples · GitLab (ustc.edu.cn)](https://git.ustc.edu.cn/hexuustc/fpgaol-examples)

项目所在位置：

一代：202.38.86.70:~/temp/fpgaol_pi_ng

二代：二代服务器下192.168.1.148:~/fpgaol_pi_ng_src/fpgaol_pi_ng

## 项目概览

使用qt的fpgaol设备端程序

qt没有http服务器实现，使用QtWebApp处理http

使用qtwebsocket处理ws

http使用8080端口，ws使用8090端口

前端为docroot，其中docroot/static/js/room.js为主要的前端脚本

后端为fpgaol_pi_ng

文件编译之后会在build文件夹生成可执行文件，把此文件直接拷贝至树莓派即可执行

项目运行需要可执行文件和docroot文件夹，docroot是静态文件，包含了html和js脚本等

将fpgaol_pi_ng可执行文件和docroot文件夹 拷贝至每个树莓派的/home/pi/中，启动程序，即每个树莓派都是一个服务器，每个树莓派负责一个页面

文件树如下：

```
.
├── build						编译后文件所在文件夹
│   └── fpgaol_pi_ng			编译后生成的可执行文件
├── build.sh					linux的自动编译脚本
├── build_win32.bat				win32下自动编译脚本
├── docroot						静态文件，前端页面
│   ├── alive					若能访问alive，表明程序在工作
│   ├── index.html				项目主要html文件
│   └── static					静态文件
│       ├── css
│       ├── fonts
│       └── js					里面包含room.js，为重点文件
├── fpgaol_pi_ng				后端程序文件夹
│   ├── fpgaol_pi_ng.pro		qt的makefile相关文件
│   ├── include					头文件
│   │   ├── fpga.h
│   │   ├── gpio_defs.h
│   │   ├── httpserver.h
│   │   ├── log.h
│   │   └── wsserver.h
│   └── src						后端程序代码
│       ├── fpga.cpp			负责管脚采样与比特流烧写
│       ├── httpserver.cpp		http服务器，与web页面操作交互
│       ├── main.cpp			main,程序入口
│       └── wsserver.cpp		websocket服务器，负责与前端页面的管脚信息传输
├── QtWebApp
└── README.md					项目的一些文档说明
```

## 项目运行

**首先对文件进行编译**（对于没有编译的代码而言），如下命令，即可得到可执行文件，位于build文件夹中

```
./build.sh
```

可将可执行文件拷至 **/home/pi/** 中运行，也可直接在build文件夹中运行，默认使用docroot位于 **/home/pi/docroot**中

然后执行fpgaol_pi_ng即可(**对于已经编译好的文件直接运行即可**)

```
sudo ./fpgaol_pi_ng
```

**本系统采用systemd来进行项目的运行**

systemd配置文件位于 **/etc/systemd/system/fpgaol.service** (可从主服务器~/fpgaol-ansible/fpgaol.service中复制)

为使项目开启自启动，在/etc/systemd/system/中配置好fpgaol.service后，需要执行

```
sudo systemctl enable fpgaol.service
```

要求 fpgaol_pi_ng可执行文件和docroot 都在 **/home/pi/**中

利用systemd启动方式

```
sudo systemctl restart fpgaol.service
```

如上即可启动程序，访问其8080端口即可访问web页面

#### 运行环境

**注意：**项目在一个新的树莓派上运行需要配置一下运行环境，方法如下：

拷贝202.38.79.96里的~/fpgaol-ansible/new_server/libqt5websockets5_5.11.3-5_armhf.deb 到树莓派里然后运行

```
sudo apt install /home/pi/libqt5websockets5_5.11.3-5_armhf.deb
```

## 反向代理

由于树莓派作为内网节点，要使服务器网页被外网访问，需要配置反向代理

本系统采用nginx来配置反向代理

### 树莓派端

**对于未配置nginx的树莓派而言，配置方法如下：**

（以下命令是在主服务器中运行的）

```
scp ./new_server/nginx.service ./new_server/nginx pi@192.168.1.xxx:~
scp -r ./new_server/nginx_conf pi@192.168.1.xxx:~
ssh pi@192.168.1.xxx 'sudo mv ~/nginx /usr/sbin/; sudo mkdir /var/log/nginx/; sudo touch /var/log/nginx/error.log; sudo mv ~/nginx_conf /etc/nginx; sudo mkdir /var/lib/nginx; sudo mv ~/nginx.service /etc/systemd/system/; sudo systemctl enable nginx.service; sudo systemctl restart nginx.service;'
```

**注释：**nginx是可执行文件，nginx.service是systemd配置文件，用来配置nginx开机与异常自启动，nginx_conf是关于nginx的一系列配置文件，已经配置好了，复制即可

mkdir与touch都是创建一系列相关文件和文件夹以给nginx使用

systemctl enable是设置开机自启动，最后systemctl restart 启动nginx配置

**对于已配置nginx的树莓派，若异常退出，可执行如下命令重启nginx**

```
sudo systemctl restart nginx.service
```

### 主服务器端

#### 一代服务器：

位于**/etc/nginx/modules-enabled/raspi.conf**中，其中以下字段

```
server {
    listen 12138;
    proxy_pass 192.168.1.138:80;
}
```

表明主服务器的端口12138转发给了192.168.1.138:80

一代树莓派ip规则为 12+树莓派ip地址最后一段

二代树莓派ip规则为 13+树莓派ip地址最后一段

二代转发示例如下：

```
server {
    listen 13148;
    proxy_pass 202.38.79.96:12148;
} 
```

一代是直接转发给了树莓派

而二代则是先转发给二代服务器，再转发给二代树莓派

默认转发了12010~12240，13010~13240的所有地址

#### 二代服务器：

位于**/etc/nginx/conf.d/fpgaol_nginx.conf**中

转发规则与一代类似

最后，重启nginx

```
sudo nginx -s reload
```

## 比特流烧写

一代树莓派使用了digilent adept的djtgcfg命令来进行烧写，命令详情[Programming an FPGA Board with the Analog Discovery Pro (ADP3450/ADP3250) - Digilent Reference](https://digilent.com/reference/test-and-measurement/analog-discovery-pro-3x50/programming-an-fpga?s[]=djtgcfg)

二代树莓派使用了ustcfg来进行烧写，ustcfg详情见202.38.79.96:~/ustcfg

## token

默认token为token_debug_ignore

当要申请一个节点时，访问 **http://192.168.1.xxx:8080/set/?token=%s** 来设置token，%s是服务器自动生成的一串字符串

即访问set即可设置token，同时在申请同时设置了节点有效期限，默认十分钟

当期限达到时访问 **http://192.168.1.xxx:8080/unset/** 来消除token，树莓派端会将token重置为默认token，这样原先的token就无效了

默认token为 **token_debug_ignore** ,即访问 http://202.38.79.134:12xxx/?token=token_debug_ignore 即可永久使用一个节点

## 管脚配置信息

位于fpgaol_pi_ng/include/gpio_defs.h中

在这里可以设置时钟，开关，数码管，按钮对应的管脚配置信息

一代和二代在这里有所不同，具体详见每个服务器下的这个头文件

## 管脚数据交互

前端以json形式通过websocket传输gpio和电平信息给后端，后端再把管脚信息写到FPGA中

同时后端把实时采样数据周期性地传输给前端，前端把接收到的数据展示在页面上

### json格式

LED变化：

```json
{
  "type": "LED",
  "values": [
    0,
    1,
    0,
    1,
    1,
    0,
    0,
    1
  ]
}
```

数码管变化：

```json
{
  "type": "SEG",
  "values": [
    1,
    15, // 0xF
    -1, // 不亮
    0, // 显示数字0
    -1,
    -1,
    0,
    10
  ]
}
```

当传输给后端的GPIO为-1时，结束notification

当传输给后端的GPIO为-2时，开启notification

当传输给后端的GPIO为-3时，为uart的数据传输

