# 如何在Godot项目设置中找到Excel转换器配置

## 步骤说明

1. **打开项目设置**
   - 在Godot编辑器中，点击菜单 `项目` -> `项目设置`
   
2. **查找Excel转换器设置**
   - 方法1: 在左侧搜索框输入 `excel_converter`
   - 方法2: 在左侧设置树中找到并展开 `Application` 节点
   - 方法3: 直接滚动查找 `Excel Converter` 分类

3. **设置说明**

### 基础设置
- **Python Path**: Python可执行文件路径（留空自动检测）
- **Input Path**: Excel文件默认输入目录
- **Output Path**: JSON文件默认输出目录

### 行为选项  
- **Auto Convert**: 文件改变时自动转换（暂未实现）
- **Show Notifications**: 显示转换完成通知
- **Verbose Logging**: 详细日志输出

### GDScript生成功能
- **Enable Gdscript Generation**: 启用GDScript脚本自动生成
- **Gdscript Output Path**: GDScript文件输出目录
- **Base Resource Path**: 基础资源路径（用于生成脚本内的引用）

## 故障排除

### 如果看不到这些设置:

1. **确认插件已启用**
   - 项目设置 -> 插件 -> 找到 "Excel to JSON Converter" 并确保已启用

2. **重新启用插件**
   - 禁用插件 -> 重新启用插件
   - 这将重新初始化项目设置

3. **手动初始化**
   - 运行 `addons/py_excel_tool/verify_project_settings.gd` 脚本
   - 工具 -> 执行脚本 -> 选择该文件

4. **检查控制台输出**
   - 查看编辑器输出面板是否有错误信息
   - 插件加载时应该显示 "[Excel转换器] 项目设置已初始化"

## 设置保存

- 所有设置会自动保存到项目的 `project.godot` 文件中
- 设置在团队开发中会共享（除非加入 `.gitignore`）
- 卸载插件不会自动删除这些设置（保留用户配置）

## 默认值

```
excel_converter/python_path = ""
excel_converter/input_path = "res://addons/py_excel_tool/data/"
excel_converter/output_path = "res://data/generated/"
excel_converter/auto_convert = false
excel_converter/show_notifications = true
excel_converter/verbose_logging = false
excel_converter/enable_gdscript_generation = false
excel_converter/gdscript_output_path = "res://scripts/generated/"
excel_converter/base_resource_path = "res://scripts"
```