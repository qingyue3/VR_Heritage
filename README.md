# 项目文件目录 Project File Directory
包含呈现项目的文件和资源
This folder contains files and resources used in the project. Below is a detailed description of the directory structure and file contents:
## 1. 3D 模型 3D Models
该文件夹里是扫描保存下来的3D模型包括mesh和texture
This directory stores all 3D assets (meshes + textures) used in the project:
- `Band/`: 3D model files for the band component
- `Farm Building/`: 3D model files for farm building structures
- `Turntable/`: 3D model files for the turntable component
- `Wheel/`: 3D model files for the wheel component

## 2. 代码 Code
- `script.m`:根据数据统计结果绘制结果的matlab 脚本代码
  > **注意**: 把最后两行取消注释可以查看对照组的结果图
- `script.m`: MATLAB script for generating result figures
  > **Note**: Uncomment the last two lines of this script to export 8 result images in total.

## 3. 数据和问卷 Data and Questionnaire
- `Data.xlsx`: 原始数据
- `Data.xlsx`: Raw dataset collected during the project research
- `Questionnaire.pdf`: 问卷
- `Questionnaire.pdf`: Questionnaire document used in the study

## 4. 展示 Media and Presentation
### 预览 Overview:
![预览 Overview](./Video/Overview.gif)
### 基础交互 Interaction:
![Interaction](./Video/Interaction.gif)
### 其他有意思的交互 Other Interesting Interaction
- `天气 Weather`
- `时间 Time`
![Other](./Video/OtherInteraction.gif)

