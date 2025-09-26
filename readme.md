# Excel到JSON批量转换工具 - Godot 4编辑器插件

本工具集用于将Excel文件批量转换为JSON格式，专为Godot项目数据预处理设计。包含Python脚本和Godot 4编辑器插件，提供完整的数据处理工作流。

**🆕 v1.1.0 新增GDScript自动生成功能！**

---

## 🚀 功能特性

### Python端功能

- ✅ 批量转换Excel文件(.xlsx, .xls)到JSON格式
- ✅ 支持多工作表Excel文件
- ✅ 使用pipenv管理虚拟环境和依赖
- ✅ 可配置的转换选项
- ✅ 详细的日志输出和错误处理

### Godot编辑器集成

- ✅ 工具菜单集成，一键调用Python转换
- ✅ 停靠面板，可视化操作界面
- ✅ 设置对话框，配置Python路径和目录
- ✅ 实时状态显示和日志输出
- ✅ 自动路径管理和项目设置持久化
- 🆕 **自动生成GDScript脚本**

### 🆕 GDScript生成功能 (v1.1.0)

- ✅ **自动生成数据类**: 根据Excel结构生成对应的GDScript数据类
- ✅ **自动生成加载器**: 生成数据加载器类，提供便捷的数据访问API
- ✅ **智能类型推断**: 自动推断字段类型（int, float, String, bool等）
- ✅ **命名规范转换**: 自动转换为GDScript命名规范
- ✅ **可配置路径**: 支持自定义生成路径和资源引用
- ✅ **项目设置集成**: 完整的配置选项管理

## 📁 项目结构

```
addons/py_excel_tool/
├── plugin.cfg                    # 插件配置
├── py_excel_tool.gd              # 主插件脚本
├── excel_converter_core.gd       # 核心转换逻辑
├── excel_converter_dock.gd       # 停靠面板脚本
├── settings_dialog.tscn/.gd      # 设置对话框
├── excel_toolbar.tscn/.gd        # 工具栏组件
├── data/                         # Excel输入文件目录
│   └── README.md                 # 使用说明
└── src/                          # Python脚本源代码
    ├── Pipfile                   # pipenv依赖管理
    ├── excel_to_json.py          # 主转换脚本
    ├── excel_converter.py        # 高级配置版本
    ├── simple_converter.py       # 简化示例
    ├── config.ini                # Python配置文件
    ├── run_converter.bat/.ps1    # 启动脚本
    └── README.md                 # 详细文档

data/generated/                   # JSON输出文件目录
scripts/core/json_data_loader.gd  # JSON数据加载工具类
```

## ⚡ 快速开始

### 1. 安装Python环境

```bash
cd addons/py_excel_tool/src
pip install pipenv
pipenv install
```

### 2. 启用Godot插件

1. 打开Godot项目
2. 进入 **项目设置 → 插件**
3. 启用 **"Excel to JSON Converter"** 插件

### 3. 配置设置

1. 使用工具菜单 → **"Excel转换器设置"**
2. 设置Python路径（留空自动检测）
3. 配置输入输出目录

### 4. 转换Excel文件

#### 基础转换（JSON）
1. 将Excel文件放入 `addons/py_excel_tool/data/` 目录
2. 使用工具菜单 → **"转换Excel文件为JSON"**
3. 或使用停靠面板进行可视化操作

#### 🆕 转换并生成GDScript
1. 将Excel文件放入输入目录
2. 使用工具菜单 → **"转换Excel并生成GDScript"**
3. 或在停靠面板勾选"同时生成GDScript脚本"
4. 插件将自动生成数据类和加载器类

## 🎯 使用方式

### 方式一：工具菜单

- **转换Excel文件为JSON** - 执行批量转换
- **Excel转换器设置** - 打开设置对话框
- **打开Excel转换器面板** - 显示停靠面板

### 方式二：停靠面板

- 可视化界面，支持路径浏览
- 实时日志显示
- 进度状态提示

### 方式三：Python命令行

```bash
cd addons/py_excel_tool/src
pipenv run python excel_to_json.py --input ../data/ --output ../../data/generated/
```

## 📊 数据格式示例

**输入Excel文件**：

| ID | 名称   | 等级 | 生命值 | 攻击力 |
|----|--------|------|--------|--------|
| 1  | 史莱姆 | 1    | 10     | 5      |
| 2  | 哥布林 | 2    | 25     | 8      |

**输出JSON文件**：

```json
{
  "Sheet1": [
    {
      "ID": 1,
      "名称": "史莱姆",
      "等级": 1,
      "生命值": 10,
      "攻击力": 5
    },
    {
      "ID": 2,
      "名称": "哥布林",
      "等级": 2,
      "生命值": 25,
      "攻击力": 8
    }
  ]
}
```

## 🆕 生成的GDScript文件示例

### 生成的文件结构

```text
scripts/generated/
├── data/           # 数据类文件
│   └── equipment_data.gd
└── loader/         # 加载器文件
    └── equipment_loader.gd
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
    # ... 其他字段赋值
```

### 加载器类示例 (equipment_loader.gd)

```gdscript
## equipment数据加载器，由Excel工具自动生成
class_name EquipmentLoader

const EquipmentData = preload("res://scripts/data/equipment_data.gd")

var data_dict: Dictionary[int, EquipmentData] = {}
var data_array: Array[EquipmentData] = []

## 加载数据
func load_data(json_path: String):
    # 自动加载和解析JSON数据
    # ...

## 根据ID获取数据
func get_by_id(id: int) -> EquipmentData:
    return data_dict.get(id, null)

## 获取所有数据
func get_all() -> Array[EquipmentData]:
    return data_array
```

## 💻 Godot中使用数据

### 🆕 使用生成的GDScript类

```gdscript
extends Node

func _ready():
    # 使用生成的数据加载器
    var equipment_loader = EquipmentLoader.new()
    equipment_loader.load_data("res://data/generated/equipment.json")
    
    # 获取特定装备
    var sword = equipment_loader.get_by_id(1001)
    if sword:
        print("装备名称: ", sword.name)
        print("攻击力: ", sword.attack)
        print("价格: ", sword.price)
    
    # 获取所有装备
    var all_equipment = equipment_loader.get_all()
    for equip in all_equipment:
        print("装备: ", equip.name, " 类型: ", equip.type)
    
    # 统计信息
    print("总装备数量: ", equipment_loader.get_count())
```

### 传统方式：使用JsonDataLoader工具类

```gdscript
# 使用JsonDataLoader工具类
extends Node

func _ready():
    # 加载怪物数据
    var monster_data = JsonDataLoader.load_sheet_data("monsters.json", "Sheet1")
    
    # 遍历所有怪物
    for monster in monster_data:
        print("怪物: ", monster.get("名称", ""))
        print("等级: ", monster.get("等级", 0))
        print("生命值: ", monster.get("生命值", 0))
    
    # 查找特定怪物
    var slime = JsonDataLoader.find_record_by_id(monster_data, "名称", "史莱姆")
    if not slime.is_empty():
        print("找到史莱姆，攻击力: ", slime.get("攻击力", 0))
    
    # 过滤指定等级怪物
    var level_1_monsters = JsonDataLoader.filter_records(monster_data, "等级", 1)
    print("1级怪物数量: ", level_1_monsters.size())
```

## 🔧 高级配置

### Python配置 (src/config.ini)

```ini
[DEFAULT]
input_directory = ./excel_files
output_directory = ./json_files
log_level = INFO
include_null_values = false
json_encoding = utf-8
json_indent = 2

[EXCEL]
supported_extensions = .xlsx,.xls
read_all_sheets = true
skip_blank_lines = true
```

### Godot项目设置

插件会自动管理以下项目设置：

- `excel_converter/python_path` - Python可执行文件路径
- `excel_converter/input_path` - 默认输入目录
- `excel_converter/output_path` - 默认输出目录
- `excel_converter/auto_convert` - 自动转换开关
- `excel_converter/show_notifications` - 显示通知
- `excel_converter/verbose_logging` - 详细日志
- 🆕 `excel_converter/enable_gdscript_generation` - 启用GDScript生成
- 🆕 `excel_converter/gdscript_output_path` - GDScript输出目录
- 🆕 `excel_converter/base_resource_path` - 基础资源路径

## 🛠 故障排除

### Python相关问题

1. **pipenv未安装**: `pip install pipenv`
2. **依赖安装失败**: 确保网络连接，运行 `pipenv install --skip-lock`
3. **编码错误**: 已内置UTF-8支持，确保Excel文件编码正确

### Godot插件问题

1. **插件未加载**: 检查 `plugin.cfg` 文件完整性
2. **菜单项未出现**: 重新启用插件
3. **设置未保存**: 确保项目有写入权限

### 转换问题

1. **Excel文件格式**: 仅支持 .xlsx 和 .xls 格式
2. **文件占用**: 关闭Excel程序后再转换
3. **路径问题**: 使用绝对路径或确保相对路径正确

## 🔄 工作流建议

### 🆕 使用GDScript生成功能的工作流

1. **数据设计**: 在Excel中设计数据表结构，第一行作为字段名
2. **一键生成**: 使用"转换Excel并生成GDScript"功能
3. **代码集成**: 直接使用生成的类，享受强类型和IDE支持
4. **数据更新**: Excel数据更改后重新运行转换，保持代码同步

### 传统工作流

1. **开发阶段**: 使用停靠面板进行交互式转换
2. **批量处理**: 使用命令行脚本进行自动化
3. **版本控制**: 将生成的JSON文件加入Git（或忽略）
4. **数据更新**: Excel文件更改后重新运行转换
5. **代码集成**: 使用JsonDataLoader类加载和使用数据

## 📝 更新日志

- **v1.1.0** - 🆕 GDScript生成功能
  - 新增自动生成GDScript数据类功能
  - 新增自动生成数据加载器功能
  - 集成项目设置配置选项
  - 更新UI界面，添加GDScript相关控件
  - 智能类型推断和命名规范转换
  - 改进错误处理和日志输出

- **v1.0.0** - 初始版本
  - Python脚本转换功能
  - Godot 4编辑器插件集成
  - 停靠面板和设置对话框
  - 完整的工作流支持

---

**开发团队**: Game Development Team  
**技术支持**: 查看 `src/README.md` 获取详细技术文档

---

## 目录规划（目标结构示例）

```text
res://
 addons/
  python_tools/        # (插件目录示例) plugin.cfg, generate_data.gd 等
 data/
  generated/           # Python 脚本输出 JSON/CSV（加入版本控制或部分忽略）
 python/
  requirements.txt
  tools/
   build_tables.py    # 初始示例数据生成脚本
   tasks/             # 后续扩展：多个任务脚本
  sources/             # 原始 Excel / CSV 源文件（可选）
  util/                # 公共 Python 工具（hash/日志/schema）
```

建议在仓库根 `.gitignore` 中忽略：

```text
python/venv/
python/**/__pycache__/
logs/
```
