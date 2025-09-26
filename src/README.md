# Excel到JSON批量转换工具

这是一个用于将Excel文件批量转换为JSON格式的Python工具集。

## 功能特性

- 支持.xlsx和.xls格式的Excel文件
- 批量转换功能
- 单文件转换功能
- 可配置的转换选项
- 支持多工作表Excel文件
- 使用pipenv管理虚拟环境和依赖
- 自动生成gd脚本

## 环境要求

- Python 3.8+
- pipenv (用于环境管理)

## 安装步骤

1. **安装pipenv** (如果尚未安装):
   ```bash
   pip install pipenv
   ```

2. **进入项目目录**:
   ```bash
   cd addons/py_excel_tool/src
   ```

3. **安装项目依赖**:
   ```bash
   pipenv install
   ```

## 文件说明

### 核心脚本

- `excel_to_json.py` - 基础版Excel转JSON转换器
- `excel_converter.py` - 高级配置版转换器
- `simple_converter.py` - 简化示例脚本

### 配置文件

- `Pipfile` - pipenv依赖管理文件
- `config.ini` - 转换器配置文件

### 辅助工具

- `run_converter.bat` - Windows批处理启动脚本

## 使用方法

### 方法1: 使用批处理脚本 (推荐)

双击运行 `run_converter.bat`，按照提示操作。

### 方法2: 直接使用Python脚本

#### 基础版本
```bash
# 激活虚拟环境
pipenv shell

# 批量转换 (将excel_files目录中的所有Excel文件转换到json_files目录)
python excel_to_json.py

# 指定输入输出目录
python excel_to_json.py --input /path/to/excel/files --output /path/to/json/files

# 转换单个文件
python excel_to_json.py --file /path/to/your/file.xlsx
```

#### 配置版本
```bash
# 使用默认配置批量转换
python excel_converter.py

# 使用自定义配置文件
python excel_converter.py --config my_config.ini

# 显示配置摘要
python excel_converter.py --summary

# 覆盖配置中的目录设置
python excel_converter.py --input ./my_excel_files --output ./my_json_files
```

#### 简化版本
```bash
python simple_converter.py
```

## 目录结构

```
src/
├── Pipfile                 # pipenv依赖文件
├── config.ini             # 配置文件
├── excel_to_json.py       # 基础转换器
├── excel_converter.py     # 配置版转换器
├── simple_converter.py    # 简化示例
├── run_converter.bat      # Windows启动脚本
├── excel_files/           # Excel输入文件目录 (需要创建)
└── json_files/            # JSON输出文件目录 (自动创建)
```

## 配置说明

编辑 `config.ini` 文件可以自定义转换行为:

```ini
[DEFAULT]
input_directory = ./excel_files    # 输入目录
output_directory = ./json_files    # 输出目录
log_level = INFO                   # 日志级别
include_null_values = false       # 是否包含空值
json_encoding = utf-8              # JSON编码
json_indent = 2                    # JSON缩进

[EXCEL]
supported_extensions = .xlsx,.xls  # 支持的文件扩展名
read_all_sheets = true             # 是否读取所有工作表
default_sheet = Sheet1             # 默认工作表名
skip_blank_lines = true            # 是否跳过空行
```

## 输出格式

转换后的JSON文件结构:

```json
{
  "Sheet1": [
    {
      "列1": "值1",
      "列2": "值2",
      "列3": "值3"
    },
    {
      "列1": "值4",
      "列2": "值5", 
      "列3": "值6"
    }
  ],
  "Sheet2": [
    // 第二个工作表的数据...
  ]
}
```

## 常见问题

### 1. 依赖安装失败
确保已正确安装pipenv:
```bash
pip install pipenv
pipenv install
```

### 2. Excel文件读取失败
- 检查文件路径是否正确
- 确保Excel文件没有被其他程序占用
- 检查文件格式是否支持(.xlsx, .xls)

### 3. 中文编码问题
配置文件中已设置UTF-8编码，如果仍有问题，请检查:
- Excel文件的编码格式
- 系统的区域设置

## 依赖包

- `pandas` - 数据处理和Excel读取
- `openpyxl` - Excel 2010+ 格式支持
- `xlrd` - 旧版Excel格式支持

## 许可证

此工具供学习和项目使用。

## 更新历史

- v1.0 - 初始版本
  - 基础Excel到JSON转换功能
  - 批量处理支持
  - pipenv环境管理