# fpgaol_compiling项目文档

仓库：[cyh / fpgaol_compiling_server · GitLab (ustc.edu.cn)](https://git.lug.ustc.edu.cn/cyh/fpgaol_compiling_server)

项目所在位置：202.38.79.96:~/fpgaol_compiling/fpgaol_compiling_server

使用接口说明：[fpgaol_compiling · master · he xu / fpgaol2-document · GitLab (ustc.edu.cn)](https://git.ustc.edu.cn/hexuustc/fpgaol2-document/-/tree/master/fpgaol_compiling)

## 项目概览

此项目用来提供编译服务

按接口规定形式提供代码给服务器，服务器会自动编译代码并返回编译结果

项目基于tornado搭建而成

用户通过submit把打包好的文件上传，服务器会在jobs文件夹里创建一个以工程id命名的文件夹，产生的所有内容都放入这个文件夹；服务器把压缩包解压在这个文件夹，然后调用tcl命令进行编译；根据有没有生成比特流文件来判断编译是否成功；把比特流文件通过链接形式发送给用户，用户点击链接即可通过nginx下载

比特流等文件的下载是通过nginx转发实现的，端口18887，配置文件位置：202.38.79.96:/etc/nginx/conf.d/fpgaol_compiling_18888.conf , nginx转发的根目录为jobs文件夹

文件树如下：

```
.
├── compile.py					负责编译功能，对tcl脚本进行调用
├── compiling.log				编译一个工程过程中所产生的log信息
├── env							vue文件，环境相关
├── FileExist.py				负责判断若干文件是否存在
├── jobmanager.py				任务管理，对一个任务进行排队，运行与结束
├── jobs						任务文件夹，编译任务产生文件都放在此文件夹，命名为任务工程号
|   └── 1411					工程号为1411的任务
│		├── compiling.log		此任务的编译log信息
│   	├── error.log			从log中提取的错误信息
│   	├── example.xdc			解压得到的xdc文件
│   	├── raw.log				从项目主文件夹复制来的编译log
│   	├── results				烧写后产生的结果
│   	│   ├── timing.rpt		时序报告
│   	│   ├── top.bit			比特流文件
│   	│   └── util.rpt		资源报告
│   	├── top.v				解压得到的顶层文件
│   	└── UserZip.zip			传送过来的代码压缩包
├── LogExtract.py				log提取程序，负责从log中提取出错误信息
├── page						编译服务器静态页面，已废弃
├── prepare.sh					运行程序前的准备工作
├── run.sh						运行程序
├── server.py					服务器代码，处理http请求
└── vivado_tools				vivado工具
    └── build.tcl				tcl脚本
```

## 项目运行

```
./prepare.sh
./run.sh
```

后台运行

```
sudo nohup python3 server.py >> compiling.log 2>&1 & 
```

web页面访问地址：202.38.79.96:18888

## 编译

编译是调用vivado来对代码进行编译

使用了tcl脚本来进行编译

目前还未实现对ip核的编译

顶层文件要求命名为top.v

## log提取

在提交编译任务后，会先把log写进主文件夹里面的compiling.log

任务的第一句会写上CompilingPrjid + 工程id

任务结束时会打印CompilingPrjid + 工程id + Finish

编译完成后把这两句中间的内容截下来放入jobs里的工程id的文件夹里，然后从中提取错误信息等

## 跨域问题

在想要设置跨域的方法里添加如下几行：

```
self.set_header("Access-Control-Allow-Origin", "*")
self.set_header("Access-Control-Allow-Headers", "x-requested-with")
self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
```

即可允许跨域
