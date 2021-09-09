# 编译服务器接口说明

## 服务器地址

202.38.79.96:18888

## 提交编译任务

方法：POST

url: /submit	(如：202.38.79.96:18888/submit )

数据：

| 字段         | 内容                                             | 备注                                                         |
| ------------ | ------------------------------------------------ | ------------------------------------------------------------ |
| inputJobId   | 工程id                                           | 每一个编译工程都有一个唯一的id，B32编码（url里没有转义）     |
| inputFPGA    | 设备型号                                         | 使用芯片型号，如xc7a100tcsg324-1，目前也只有这种类型         |
| inputZipFile | xdc与.v源文件的打包zip文件，用Base64编码进行传输 | 将所有源代码一起打包，其中要求顶层模块必须命名为top.v，其中模块名必须是module top()，并用base64进行编码传输（文件encode.py提供了对zip文件编码的方法，编码之后zipencode.txt里面的内容就是本字段的值） |

返回json（注意：json 都进行了dumps编码传输，需要json.loads解码才能显示完整内容）：

| 成功：                                                       | 失败：                                        |
| ------------------------------------------------------------ | --------------------------------------------- |
| {“code”: 1,<br/> "msg": "提交编译成功，请使用查询接口查询编译状态"} | {"code": 0,<br/>"msg": "提交编译失败，XXXXX"} |
|                                                              | 备注：后面会显示提交的哪些字段是有错误的      |



## 查询编译任务

方法：GET

url：/query/id	(id为编译工程号)

参数：无

返回json:

| 编译中：                                                     | 编译暂停：                                                   | 编译成功：                                                   | 编译失败(同时会在msg里显示错误信息)                          | 编译错误（未知原因）：                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| {"code": 1,<br/>"msg": "running",<br/>"data": {<br/>"status": 1<br/>	}<br/>} | {"code": 1,<br/>"msg": "pending",<br/>"data": {<br/>"status": 2<br/>	}<br/>} | {"code": 1,<br/>"msg": "successful",<br/>"data": {<br/>"status": 3<br/>	}<br/>} | {"code": 1,<br/>"msg": "compiling failed, the error message is as follows: $(error)",<br/>"data": {<br/>"status": 4<br/>	}<br/>} | {"code": 1,<br/>"msg": "error",<br/>"data": {<br/>"status": 0<br/>	}<br/>} |

备注：

编译信息，warning等信息的详细情况都在compiling_log里面，可以通过返回的链接进行下载

## 下载比特流文件

方法：GET

url：/download/id

参数：无

返回json：

| 下载成功                                                     | 下载失败                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| {"code": 1,<br/>"msg": "下载成功",<br/>"data": {<br/>"bitstream": "http://202.38.79.96:18887/id/results/top.bit",<br />"compiling_log": "http://202.38.79.96:18887/id/compiling.log",<br />"timing_rpt": "http://202.38.79.96:18887/id/results/timing.rpt",<br />"util_rpt": "http://202.38.79.96:18887/id/results/util.rpt"<br />    }<br/>} | {"code": 0,<br/>"msg": "下载失败，没有相应文件",<br/>"data": {<br/>"bitstream": ""<br />"compiling_log": ""<br />"timing_rpt": ""<br />"util_rpt": ""<br />    }<br/>} |

备注：

bitstream 为生成都比特流文件

compiling_log 为编译的信息，warning 和 error 等都可以在这里获取

timing_rpt 为时序分析报告，

util_rpt为资源占用报告

## 示例文件

在本目录example_files里面

example.xdc与top.v都是源文件

它们打包成了example.zip

把zip文件用base64编码后即可写进inputZipFile字段进行post请求