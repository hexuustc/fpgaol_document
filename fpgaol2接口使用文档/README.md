# fpgaol2说明文档v1.2
## 1.1改进之处
1. 传输bitstream文件与烧写合并，即传输之后自动进行烧写，成功返回如下结果  
`tips`: 现在已不需要program 命令，文件传输成功后会自动烧写并返回json数据  
```
upload and program successfully
```
并开始传输json数据  
2. 前端给后端发送Gpio信息方式改变  
  sw gpio信息改为从0-7  
  button gpio信息改为8
  (原因：只有sw button是输入，所以只需要改这两个信息，led seg不可从前端更改)

## 1.2改进之处

xdc管脚改变

具体如下：

clk管脚由**E3**改变为**B8**

sw[6]管脚改变为 **U12**

sw[7]管脚改变为 **U11**

## fpgaol2 设备接口说明
### websocket接口
客户端使用如下url即可接入  
```
let ws = new WebSocket('ws://202.38.79.96:3000');
```
### 使用websocket获取设备列表 
```
ws.send('get device list');
```
结果返回一个包含多行的字符串，每行皆为一个ip地址（内网ip，无法访问）  
字符串示例如下  

```
192.168.1.10  
192.168.1.55  
192.168.1.103  
192.168.1.112  
192.168.1.211  
192.168.1.214  
192.168.1.219  
192.168.1.226  
192.168.1.229  
192.168.1.235  
192.168.1.241  
192.168.1.248  
192.168.1.251  
192.168.1.252  
```
### 请求设备
```
ws.send('acquire 103');
```
后面数字表示要请求的设备号（即ip地址最后一列）  
注意格式，中间有空格

### 传输bitstream文件同时自动烧写
本地读取（或者http网页端的）bitstream文件（当然名字任意）,以buffer形式发送
```
fs.readFile('./bitstream.bit', function (err, data) {
        if (err) {
            console.log(err);
        } else {
            ws.send(data.buffer);
        }
    });
```
（当然，前端文件也不一定要从本地读取，只要转化为buffer以websocket发送过来即可）  
其中fs为javascript文件操作模块，其他语言也可用对应模块替换之  
传输完后后端会自动进行烧写到对应设备  
传输成功后会收到如下信息

```
upload and program successfully
```
### 接收json数据
烧写成功后会返回led和seg的json数据  
json格式见下文  
每当数据变化时都会发送json数据  
根据type类型可以判断当前数据是led还是seg

### 发送JSON格式
当想改变开关或按钮状态时，发送改变信息如下  
```
ws.send(JSON.stringify({
        'gpio': gpio,
        'level': level,
    }));
```
gpio见下方的列表  
例如想改变sw[2]=1  
则可写以下命令  
```
ws.send(JSON.stringify({
        'gpio': 2,
        'level': 1,
    }));
```

gpio对应信息如下
```
SW[] = {0, 1, 2, 3, 4, 5, 6, 7};
BUTTON[] = {8};
```


### 接收JSON格式
```
LED变化：
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
如led[1]=1表示led1是亮的，0为熄灭，一次传输八个led灯的数据给前端
```
数码管变化：
{
  "type": "SEG",
  "values": [
    1,
    15 // 0xF
    -1, // 不亮
    0, // 显示数字0
    -1,
    -1,
    0,
    10
  ]
}
```
表示八个数码管的值，0-15表示数码管0-F，其他如上所示


### 约束文件管脚改变
对应关系如下  
led[0] K17  
led[1] K18  
led[2] L14  
led[3] M14  
led[4] L18  
led[5] M18  
led[6] R12  
led[7] R13  

sw[0] M13  
sw[1] R18  
sw[2] T18  
sw[3] N14  
sw[4] P14  
sw[5] P18  
sw[6] U12  
sw[7] U11  

hexplay_data[0] T10  
hexplay_data[1] T9  
hexplay_data[2] U13  
hexplay_data[3] T13  
hexplay_an[0] V14  
hexplay_an[1] U14  
hexplay_an[2] V11  

clk B8  
btn V12

具体约束文件代码就在本仓库fpgaol2.xdc里  
同时example_bitstream文件夹下存放着实例比特流文件，源代码也在其中



