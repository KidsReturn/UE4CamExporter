# UE4CamExporter
3dsMax的插件，可以导出镜头动画到UE4中
A tool for 3dsMax to export camera animation to UE4

1. 功能/Feature
  支持一般自由相机以及绑在骨骼上(由骨骼动画驱动)的像机导出。
  Support free or attached(drive by bone) camera.
  支持坐标系旋转和偏移的配置。
  Support axis rotation and offset.
  
2. 安装/Installation
  2.1 在3dsMax关闭的情况下，将插件解压到3dsMax根目录下的MacroScript文件夹下
      With 3dsMax closed, decompress files to MacroScript folder(under root directory of 3dsMax)
  2.2 启动3dsMax，通过菜单 "自定义->自定义用户界面->工具栏" 类别选择'ExportTool' 就能看到插件UE4CamExporter 拖拽到工具栏任意位置即可
      Launch 3dsMax, through menu "Customize->CustomizeUserInterface->ToolBar->Category", Choose 'ExportTool' and there's UE4CamExporter. Then just drag the icon onto the toolBar.
      
3. 使用/Manual
  3.1 点击插件按钮，开启界面。选择需要导出的摄像机，点击生成按钮
      Press the icon to pop the window. Follow instuctions: 1.select camera 2.choose range 3.create ue4 camera
  3.2 导出生成的UE4相机。导出时注意1)开启BakeAnimation选项 2)坐标轴转换需要选择Z轴朝上
      Export ue4 camera. While exporting, 1)check BaseAnimation option 2)in axis convertion, choose Z up.
  3.3 导入到UE4需要的地方
      Import FBX in UE4.
