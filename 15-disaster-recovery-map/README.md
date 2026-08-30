# 地球 Online · 观测站

HarmonyOS 本机记录切片。用户用内置示例照片确认一种自然现象，并把未核验公众线索保存在本机。

## 第一版可玩流程

1. 首次打开阅读隐私说明：同意后才读写本机目击线索；拒绝仍可浏览科普。
2. 在「观测」页点击「用示例记录」。
3. 确认这是内置示例照片，不是相机或识别。
4. 选择最接近的描述，可选填写地点与备注，保存到本机。
5. 从右上角「N」查看、清除本机线索。紧急情况使用「打开系统电话」。

## 本版边界

- 覆盖暴雨云团、台风外雨带、山洪水迹、潮汐变化。
- 本版只产生「未核验公众线索」，不生成权威发布或已核验协作信息。
- 不展示灾害影响范围、避险指引或恢复进度，也不替代 110 / 119 / 120。
- 不接入相机、相册、定位、账号、网络或后端。

## 视觉方向

冷淡的深海蓝黑、冰灰与低饱和冷蓝。真实摄影承载现场感，底部保留观测、记录、科普三处入口，个人记录放在右上角。

## 运行

用 DevEco Studio 打开当前文件夹，选择 `entry` 模块与已签名的调试设备后运行。

构建命令（在项目根目录，通过 Node 调用 hvigor，不要把 `hvigorw.js` 当 shell 脚本执行）：

```bash
NODE='/Applications/DevEco-Studio.app/Contents/tools/node/bin/node'
HVIGOR='/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js'
export JAVA_HOME='/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home'
export DEVECO_SDK_HOME='/Applications/DevEco-Studio.app/Contents/sdk'
"$NODE" "$HVIGOR" --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental
```

未配置发布签名。未签名 HAP 不能当作可安装包或上架包。详见 `docs/release/RELEASE_LEDGER.md`。
