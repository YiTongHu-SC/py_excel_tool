# Excel转换器插件 - GDScript生成功能

## 功能概述

Excel转换器插件现在支持自动生成GDScript脚本功能，可以在转换Excel数据为JSON的同时，自动生成对应的GDScript数据类和加载器类。

## 新增功能

### 1. GDScript脚本自动生成
- **数据类生成**: 根据Excel数据结构自动生成对应的GDScript数据类
- **加载器类生成**: 自动生成数据加载器类，提供便捷的数据访问方法
- **类型推断**: 智能推断字段类型（int, float, String, bool等）
- **命名规范**: 自动转换为GDScript命名规范（snake_case）

### 2. 项目设置集成

- **启用/禁用控制**: 可在项目设置中控制是否启用GDScript生成
- **输出目录配置**: 自定义GDScript输出目录  
- **基础资源路径**: 配置生成的脚本中使用的资源引用路径

**在Godot编辑器中查看这些设置**:
1. 打开 `项目` -> `项目设置`
2. 在左侧搜索框中输入 `excel_converter`
3. 或直接滚动到 `Application` -> `Excel Converter` 节点

## 使用方法

### 方法1: 通过停靠面板
1. 打开Excel转换器停靠面板
2. 勾选"同时生成GDScript脚本"选项
3. 设置输入和输出路径
4. 点击"开始转换"按钮

### 方法2: 通过菜单
1. 在Godot编辑器菜单中选择"项目" > "工具"
2. 选择"转换Excel并生成GDScript"选项

### 方法3: 通过设置对话框
1. 打开"Excel转换器设置"
2. 在"GDScript生成"部分配置相关选项：
   - 启用GDScript脚本生成
   - 设置GDScript输出目录
   - 设置基础资源路径

## 配置选项

### 项目设置

以下设置会自动添加到项目设置中：

```
excel_converter/enable_gdscript_generation (bool): 是否启用GDScript生成，默认false
excel_converter/gdscript_output_path (String): GDScript输出目录，默认"res://scripts/generated/"
excel_converter/base_resource_path (String): 基础资源路径，默认"res://scripts"
```

### Python配置文件

插件会自动更新`addons/py_excel_tool/src/config.ini`中的配置：

```ini
[GDSCRIPT]
# ... 其他配置 ...
base_resource_path = res://scripts  # 从项目设置自动同步
```

## 生成的文件结构

假设有一个名为`equipment.xlsx`的Excel文件，包含装备数据：

```
scripts/generated/
├── data/
│   └── equipment_data.gd          # 装备数据类
└── loader/
    └── equipment_loader.gd        # 装备数据加载器
```

### 数据类示例 (equipment_data.gd)

```gdscript
## equipment数据类，由Excel工具自动生成
class_name EquipmentData

var id: int = 0
var name: String = ""
var type: String = ""
var attack: int = 0
var defense: int = 0
var price: float = 0.0

## 构造函数
func _init(data: Dictionary = {}):
    if data.is_empty():
        return
    
    if data.has("ID"):
        id = data["ID"]
    if data.has("Name"):
        name = data["Name"]
    if data.has("Type"):
        type = data["Type"]
    # ... 其他字段
```

### 加载器类示例 (equipment_loader.gd)

```gdscript
## equipment数据加载器，由Excel工具自动生成
class_name EquipmentLoader

## 引入数据类
const EquipmentData = preload("res://scripts/data/equipment_data.gd")

## 数据字典
var data_dict: Dictionary[int, EquipmentData] = {}
var data_array: Array[EquipmentData] = []

## 加载数据
func load_data(json_path: String):
    # 加载JSON数据并转换为数据对象
    # ...

## 根据ID获取数据
func get_by_id(id: int) -> EquipmentData:
    return data_dict.get(id, null)

## 获取所有数据
func get_all() -> Array[EquipmentData]:
    return data_array
```

## 在游戏中使用

```gdscript
# 使用生成的数据加载器
var equipment_loader = EquipmentLoader.new()
equipment_loader.load_data("res://data/generated/equipment.json")

# 获取特定装备
var sword = equipment_loader.get_by_id(1001)
if sword:
    print("装备名称: ", sword.name)
    print("攻击力: ", sword.attack)

# 获取所有装备
var all_equipment = equipment_loader.get_all()
for equip in all_equipment:
    print("装备: ", equip.name, " 价格: ", equip.price)
```

## 高级配置

### 自定义生成规则

可以通过修改`config.ini`文件来自定义生成规则：

```ini
[GDSCRIPT]
# 输出目录结构
data_class_dir = data          # 数据类目录名
loader_class_dir = loader      # 加载器类目录名

# 类命名规则
class_name_prefix =            # 类名前缀
class_name_suffix = Data       # 数据类后缀
loader_class_suffix = Loader   # 加载器类后缀

# 资源路径设置
base_resource_path = res://scripts  # 基础资源路径
```

## 注意事项

1. **Python环境**: 确保正确配置了Python环境和相关依赖
2. **文件权限**: 确保输出目录有写入权限
3. **命名冲突**: 生成的类名可能与现有类冲突，建议使用独立的命名空间
4. **数据类型**: 插件会自动推断数据类型，但复杂类型可能需要手动调整
5. **文件编码**: 生成的文件使用UTF-8编码，支持中文字段名

## 故障排除

### 常见问题

1. **生成失败**: 检查Python环境和依赖是否正确安装
2. **路径错误**: 确保配置的路径存在且有写入权限
3. **类名冲突**: 修改生成规则或使用不同的输出目录
4. **编码问题**: 确保Excel文件使用正确的编码格式

### 日志查看

插件会在以下位置输出详细日志：
- Godot编辑器输出面板
- Excel转换器停靠面板的日志区域
- Python脚本执行日志

## 更新记录

### v1.1.0
- 新增GDScript自动生成功能
- 集成项目设置配置
- 更新UI界面，添加GDScript相关选项
- 改进错误处理和日志输出