# GDScript自动生成功能使用指南

## 功能概述

该工具可以根据Excel文件自动生成Godot 4.x的GDScript脚本，包括：
1. **数据类脚本** - 定义数据结构的类
2. **数据加载器脚本** - 负责加载和管理数据的类

## 使用方法

### 方法一：独立使用GDScript生成器

```bash
# 从JSON文件生成GDScript脚本
python gdscript_generator.py --json-dir ../example/data --output ./gdscript_output

# 生成单个JSON文件的脚本
python gdscript_generator.py --file ../example/data/test.json --output ./gdscript_output
```

### 方法二：Excel转换时同时生成GDScript

```bash
# 转换Excel并生成GDScript脚本
python excel_to_json.py --input ../example/data --output ./json_output --generate-gdscript --gdscript-output ./gdscript_output

# 转换单个Excel文件并生成GDScript
python excel_to_json.py --file ../example/data/test.xlsx --output ./json_output --generate-gdscript
```

## 参数说明

### GDScript生成器参数
- `--json-dir, -j`: 输入JSON文件目录
- `--output, -o`: 输出GDScript文件目录
- `--file, -f`: 生成单个JSON文件的脚本
- `--config, -c`: 配置文件路径

### Excel转换器新增参数
- `--generate-gdscript, -g`: 启用GDScript生成
- `--gdscript-output, -go`: GDScript输出目录

## 配置文件

在`config.ini`文件中的`[GDSCRIPT]`部分可以配置以下选项：

```ini
[GDSCRIPT]
# GDScript输出目录
gdscript_output_dir = ./gdscript_output

# 数据类输出目录
data_class_dir = data

# 加载器类输出目录
loader_class_dir = loader

# 类名前缀
class_name_prefix = 

# 数据类名后缀
class_name_suffix = Data

# 加载器类名后缀
loader_class_suffix = Loader

# 生成脚本中使用的基础资源路径
# 留空则使用相对路径 (res://../data/xxx.gd)
# 填写则使用绝对路径 (如: res://scripts/data)
base_resource_path = 
```

### 路径配置说明

**相对路径模式** (默认，`base_resource_path`为空):
- 生成的preload路径格式: `"res://../data/xxx_data.gd"`
- 适用于生成的脚本直接放在Godot项目中使用

**绝对路径模式** (`base_resource_path`有值):
- 生成的preload路径格式: `"res://your_base_path/data/xxx_data.gd"`
- 适用于需要将脚本放置在项目特定位置的情况

## 生成的文件结构

```
gdscript_output/
├── data/           # 数据类脚本
│   ├── sheet1_data.gd
│   └── sheet2_data.gd
└── loader/         # 加载器类脚本
    ├── sheet1_loader.gd
    └── sheet2_loader.gd
```

## 数据类型映射

Excel数据类型会自动映射为相应的GDScript类型：

| Excel类型 | GDScript类型 |
|-----------|--------------|
| 整数      | int          |
| 小数      | float        |
| 文本      | String       |
| 布尔值    | bool         |
| 数组      | Array        |
| 对象      | Dictionary   |
| 空值      | Variant      |

## 使用示例

### 1. Excel数据示例

| ID | Name | HP  | Attack | IsActive |
|----|------|-----|--------|----------|
| 1  | 战士 | 100 | 25     | true     |
| 2  | 法师 | 80  | 35     | true     |

### 2. 生成的数据类 (character_data.gd)

```gdscript
## Sheet1数据类，由Excel工具自动生成
class_name CharacterData

var id: int = 0
var name: String = ""
var hp: int = 0
var attack: int = 0
var is_active: bool = false

## 构造函数
func _init(data: Dictionary = {}):
	if data.is_empty():
		return
	
	if data.has("ID"):
		id = data["ID"]
	if data.has("Name"):
		name = data["Name"]
	if data.has("HP"):
		hp = data["HP"]
	if data.has("Attack"):
		attack = data["Attack"]
	if data.has("IsActive"):
		is_active = data["IsActive"]
```

### 3. 生成的加载器类 (character_loader.gd)

```gdscript
## Sheet1数据加载器，由Excel工具自动生成
class_name CharacterLoader

## 引入数据类
const CharacterData = preload("res://path/to/character_data.gd")

## 数据字典
var data_dict: Dictionary[int, CharacterData] = {}
var data_array: Array[CharacterData] = []

## 加载数据
func load_data(json_path: String):
	# ... 加载逻辑

## 根据ID获取数据
func get_by_id(id: int) -> CharacterData:
	return data_dict.get(id, null)

## 获取所有数据
func get_all() -> Array[CharacterData]:
	return data_array
```

### 4. 在Godot项目中使用

```gdscript
# 在游戏中使用生成的类
extends Node

var character_loader: CharacterLoader

func _ready():
	character_loader = CharacterLoader.new()
	character_loader.load_data("res://data/characters.json")
	
	# 获取特定角色
	var warrior = character_loader.get_by_id(1)
	if warrior:
		print("战士血量: ", warrior.hp)
	
	# 获取所有角色
	var all_characters = character_loader.get_all()
	for character in all_characters:
		print("角色: ", character.name, " 攻击力: ", character.attack)
```

## 特性

1. **自动类型推断** - 根据Excel数据自动推断GDScript类型
2. **命名规范转换** - 自动将字段名转换为GDScript的snake_case命名规范
3. **ID字段识别** - 自动识别ID字段并创建索引字典
4. **类型安全** - 生成的代码包含完整的类型注释
5. **错误处理** - 包含完整的文件读取和JSON解析错误处理
6. **可配置** - 通过配置文件自定义生成选项

## 注意事项

1. **路径配置** - 生成的脚本中的preload路径需要根据实际项目结构调整
2. **字段命名** - Excel中的字段名会自动转换为小写下划线格式
3. **数据验证** - 建议在使用前验证生成的脚本是否符合项目需求
4. **版本兼容** - 生成的脚本针对Godot 4.x版本优化

## 故障排除

1. **导入错误** - 确保pandas和openpyxl包已正确安装
2. **路径问题** - 确保输入和输出路径正确
3. **权限问题** - 确保对输出目录有写入权限
4. **编码问题** - 确保Excel文件使用正确的编码格式