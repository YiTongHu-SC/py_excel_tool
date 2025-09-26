# GDScript路径生成修复指南

## 问题描述

生成的GDScript加载器文件中出现了错误的资源路径：
```
const EquipmentData = preload("res://../data/equipment_data.gd")  # ❌ 错误
```

应该是：
```
const EquipmentData = preload("res://scripts/generated/data/equipment_data.gd")  # ✅ 正确
```

## 已修复的问题

### 1. Python脚本路径生成逻辑修复
- ✅ 修复了 `generate_data_resource_path` 函数中的路径拼接错误
- ✅ 改进了 `base_resource_path` 为空时的默认路径逻辑
- ✅ 移除了错误的相对路径 `res://../data/` 

### 2. 配置文件更新
- ✅ 更新了 `config.ini` 中的 `base_resource_path` 配置
- ✅ 设置为 `res://scripts/generated` 以匹配实际输出目录

### 3. 已生成文件修复
- ✅ 手动修复了 `equipment_loader.gd` 中的路径
- ✅ 手动修复了 `hero_loader.gd` 中的路径

## 预期结果

修复后，生成的加载器文件应该包含正确的路径：
```gdscript
## 引入数据类
const EquipmentData = preload("res://scripts/generated/data/equipment_data.gd")
```

## 验证步骤

1. **检查文件是否存在语法错误**：
   - 在Godot编辑器的文件系统面板中查看生成的.gd文件
   - 应该没有红色错误图标

2. **运行测试脚本**：
   - 执行 `test_generated_scripts.gd` 脚本
   - 工具 -> 执行脚本 -> 选择该文件

3. **重新生成验证**：
   - 使用Excel转换器重新生成GDScript文件
   - 检查新生成的文件是否使用了正确路径

## 未来避免此问题

1. **项目设置配置**：
   - 在项目设置中正确配置 `excel_converter/base_resource_path`
   - 确保路径与实际输出目录匹配

2. **配置验证**：
   - 插件会自动更新Python配置文件中的 `base_resource_path`
   - 转换前会同步Godot项目设置到Python配置

## 路径配置说明

### 推荐配置
```ini
# 在 config.ini 中
[GDSCRIPT]
base_resource_path = res://scripts/generated
```

这将生成路径：
- 数据类: `res://scripts/generated/data/equipment_data.gd`
- 加载器: `res://scripts/generated/loader/equipment_loader.gd`

### 自定义配置示例

如果想要不同的路径结构：
```ini
# 方案1: 放在scripts根目录下
base_resource_path = res://scripts

# 方案2: 放在专门的数据目录
base_resource_path = res://game_data

# 方案3: 留空使用默认路径
base_resource_path = 
```

## 注意事项

- 路径必须使用 `res://` 前缀的绝对路径
- 确保目标目录具有写入权限
- 避免使用包含 `../` 的相对路径