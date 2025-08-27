**ℹ注意：当网页首次打开时，会请求位置权限。这是因为站点需要您的位置信息来计算卫星过境预测。**

### 1. 界面
(1) **ZH/EN**: 切换界面语言.

(2) **CODE**: 查看项目源代码。

(3) **STAT**: 查看访问数据统计。

(4)**SSTV DECODE**：一个网页版的SSTV解码器，可以对录音进行解码

(5) **Show favorites**: 计算已收藏卫星的过境信息。

(6) **Show selected**: 计算当前选中卫星的过境信息。

<img width="352" height="78" alt="image" src="https://github.com/user-attachments/assets/f2603420-34bb-429a-ab05-9dd2f94bcc30" />


### 2. 卫星过境预测

(1) 在**搜索框**输入卫星关键词，点击搜索结果即可选中卫星进行过境预测。

<img width="451" height="187" alt="image" src="https://github.com/user-attachments/assets/550efd46-3d20-429b-95e8-4f6a4d9a13f3" />


(2) **可选设置**：选择预测天数、最小仰角阈值，以及是否仅显示19:00-23:59的过境。

<img width="280" height="27" alt="image" src="https://github.com/user-attachments/assets/62304ba8-9eb0-45c5-94d7-6fc58003afba" />


(3)  **收藏功能**：点击搜索框旁的圆圈图标可收藏卫星。

<img width="438" height="55" alt="image" src="https://github.com/user-attachments/assets/81f87142-ebb2-4dd2-84ee-95fcc82c9d11" />


(4) 点击**显示收藏**或**显示选择**，计算对应卫星的过境信息。


(5) 计算结果将显示以下内容：日期、起止时间、过境轨迹预览、最大仰角。（蓝色/黑色背景分别表示白天/夜晚过境，绿色背景表示卫星正在过境中。）

<img width="432" height="454" alt="image" src="https://github.com/user-attachments/assets/522b51e7-a4f4-4637-b86a-d5c2a952261a" />
<img width="428" height="448" alt="image" src="https://github.com/user-attachments/assets/b9d0a672-a03a-4de4-87be-17cce1544570" />

<img width="424" height="137" alt="image" src="https://github.com/user-attachments/assets/e6e0b0d4-db28-45fd-b2e3-6792c2fee9de" />





(6) 在iOS/Android设备上，点击**开始时间**可将过境添加至**日历提醒**。

(7) 点击**最大仰角数值**，可跳转至该次过境的**实时卫星追踪页面**。

<img width="428" height="177" alt="image" src="https://github.com/user-attachments/assets/f5380fd9-03e0-457c-9132-e709b5c4496e" />


### 3. 实时卫星追踪

**此页面显示卫星实时仰角/方位角，并调用手机传感器辅助天线对准（通过箭头指示是否对准卫星）。
因需调用传感器，页面会请求传感器权限，iOS用户需点击底部「iOS设备传感器授权」按钮启用。**

<img width="229" height="34" alt="image" src="https://github.com/user-attachments/assets/fc57dbef-ebde-475d-a2a2-50426ed41696" />


(1) 顶部**信息栏**显示：卫星名称、实时仰角/方位角、预测最大仰角、AOS（信号获取）/LOS（信号丢失）时间、当前时间及AOS倒计时。

(2) 信息栏下方为过境进度条，显示从AOS至今秒数与剩余秒数（适用于SSTV接收）。

<img width="457" height="186" alt="image" src="https://github.com/user-attachments/assets/e96c9cb5-8bb6-4503-97a8-65cad0d1d84a" />

(3) 中部为卫星追踪罗盘，显示过境轨迹与设备当前指向。当卫星进入天空时，左侧仰角刻度显示实时位置，罗盘中心箭头指示卫星方位角。

<img width="384" height="329" alt="image" src="https://github.com/user-attachments/assets/bfdc3113-6e53-4db5-a61d-db831b7861f2" />

(4) **卫星频率显示**卫星频段信息。点击**多普勒显示**可查看卫星距离及经多普勒效应调整的实时频率。（SSTV特别提示：卫星在轨期间，页面还会显示Robot36/Robot72/PD120模式的推荐接收频率。这些频率取当前与过境结束时多普勒频移的中点值，以减少手动调谐需求。）


<img width="462" height="437" alt="image" src="https://github.com/user-attachments/assets/58f308e9-6d0d-4978-9da3-4037a380a833" />
<img width="409" height="477" alt="image" src="https://github.com/user-attachments/assets/d45d1195-0aa6-4ac7-bbd0-8cac1705c503" />





(5) **开始录音**可进行音频录制，文件将下载至设备。（个人更推荐使用设备自带录音功能。）

#### 4. SSTV解码
(1) 选择音频文件

(2) 点击解码按钮