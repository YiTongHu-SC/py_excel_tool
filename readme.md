# Excel到JSON批量转换工具 - Godot 4编辑器插件

本工具集用于将Excel文件批量转换为JSON格式，专为Godot项目数据预处理设计。包含Python脚本和Godot 4编辑器插件，提供完整的数据处理工作流。

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
1. 将Excel文件放入 `addons/py_excel_tool/data/` 目录
2. 使用工具菜单 → **"转换Excel文件为JSON"**
3. 或使用停靠面板进行可视化操作

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

## 💻 Godot中使用JSON数据

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

1. **开发阶段**: 使用停靠面板进行交互式转换
2. **批量处理**: 使用命令行脚本进行自动化
3. **版本控制**: 将生成的JSON文件加入Git（或忽略）
4. **数据更新**: Excel文件更改后重新运行转换
5. **代码集成**: 使用JsonDataLoader类加载和使用数据

## 📝 更新日志

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

---

## 分阶段 TODO（渐进式实施）

### Phase 0 基础准备

- [ ] 创建目录：`python/tools`, `data/generated`, `addons/python_tools`
- [ ] 新建 `python/requirements.txt`（如暂不需要第三方可留空）
- [ ] （可选）创建虚拟环境：`python -m venv python/venv`
- [ ] `.gitignore` 更新忽略 `python/venv/` 与 `__pycache__`
- [ ] 在 `readme`（或本文件）记录输出目录约定：`res://data/generated/`

### Phase 1 最小数据生成脚本

- [ ] 添加 `python/tools/build_tables.py`：硬编码示例数据并输出 `monsters.json`
- [ ] 运行：`python python/tools/build_tables.py` 验证生成文件
- [ ] 在 Godot（任意测试场景）编写临时代码读取并打印 JSON 验证

示例脚本（初版）：

```python
import json, os
out_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data", "generated")
os.makedirs(out_dir, exist_ok=True)
data = [
  {"id": 1, "name": "Slime", "hp": 10},
  {"id": 2, "name": "Goblin", "hp": 25},
]
with open(os.path.join(out_dir, "monsters.json"), "w", encoding="utf-8") as f:
  json.dump(data, f, ensure_ascii=False, indent=2)
print("OK: monsters.json")
```

### Phase 2 Editor 插件基础

- [ ] 创建插件目录（若与现有插件不同）：`addons/python_tools/`
- [ ] 新建 `plugin.cfg` 与 `generate_data.gd`
- [ ] 添加菜单项：`生成数据(Python)` -> 同步 `OS.execute` 调用脚本
- [ ] 输出成功 / push_error 失败信息

`plugin.cfg` 示例：

```ini
[plugin]
name="PythonTools"
description="Run python data generators"
author="Team"
version="0.1.0"
script="generate_data.gd"
```

`generate_data.gd` 示例：

```gdscript
@tool
extends EditorPlugin

const DEFAULT_SCRIPT := "res://python/tools/build_tables.py"

func _enter_tree():
  add_tool_menu_item("生成数据(Python)", Callable(self, "_run_generation"))

func _exit_tree():
  remove_tool_menu_item("生成数据(Python)")

func _run_generation():
  var python_path := ProjectSettings.get_setting("python_tools/python_path", "python")
  var script_path := ProjectSettings.globalize_path(DEFAULT_SCRIPT)
  var output:Array = []
  var code = OS.execute(python_path, [script_path], output, true)
  if code == 0:
    print("[PythonTools] OK\n" + "\n".join(output))
  else:
    push_error("[PythonTools] 失败 code=%d\n%s" % [code, "\n".join(output)])
```

### Phase 3 可配置化

- [ ] 使用 `ProjectSettings.set_setting` & `save()` 添加键：`python_tools/python_path`
- [ ] 若未设置尝试回退执行顺序：`python` -> `py` (Windows)
- [ ] 增加菜单项：`设置 Python 路径`（弹出对话框输入后保存）

### Phase 4 多脚本与任务管理

- [ ] 约定任务目录：`python/tools/tasks/`
- [ ] 启动时扫描 `tasks/*.py` 生成列表
- [ ] 菜单项：`运行数据任务...` 弹窗列出任务可选择
- [ ] 统一脚本协议：退出码 0=成功；stdout 第一行使用 `OK:` / `WARN:` / `ERROR:` 前缀
- [ ] 抽取公共 Python 工具模块（路径、hash、日志）到 `python/util/`

### Phase 5 数据源解耦

- [ ] 添加真实源：`python/sources/monsters.xlsx` 或 `monsters.csv`
- [ ] 脚本改为读取源文件生成 JSON
- [ ] 实现源文件 hash / mtime 对比：未变化则跳过生成（打印 `SKIP:`）
- [ ] 生成 `version.json`（时间戳、git commit id 可选）

### Phase 6 Godot 端数据封装

- [ ] 新建 `scripts/DataRepository.gd`（或放 `core/`）集中加载 JSON
- [ ] 实现懒加载与缓存：首次读取后存内存
- [ ] 提供 `reload()` 用于开发刷新
- [ ] 字段校验：缺失字段 `push_warning` 或 `push_error`

### Phase 7 监视与自动刷新（编辑器模式）

- [ ] 菜单项：`开启监视模式`
- [ ] 使用 `EditorPlugin` + `Timer` 周期检查源文件 mtime
- [ ] 改变则自动触发生成并在输出面板提示
- [ ] 可选：状态图标（Dock 面板）显示最近一次生成结果

### Phase 8 日志与错误改进

- [ ] Python 脚本统一写 `logs/pipeline.log`
- [ ] 插件添加 `查看生成日志` 菜单 -> 打开文件或弹出文本对话框
- [ ] 把 stderr 与 stdout 分离显示（可在 `OS.execute` 增设重定向；若不支持则脚本内部写日志）

### Phase 9 测试与 CI

- [ ] 引入 `pytest`，为数据构造、schema 校验写测试
- [ ] CI（GitHub Actions / 本地脚本）步骤：安装依赖 -> 运行生成脚本 -> 运行测试 -> （可选）headless Godot 启动做 smoke
- [ ] 对比生成目录：如需防意外变化，可引入快照 diff（`pre-commit` 或 CI 中）

### Phase 10 导出集成

- [ ] 导出前（手动或脚本）自动执行全部生成任务
- [ ] 确保 `data/generated/*.json` 在导出模板包含（检查 `export_presets.cfg`）
- [ ] 不把 `python/`（除非需要）打包进最终发行版本

### Phase 11 进阶功能（可择需）

- [ ] 并行 / 批量调度：Python 端集中调度多个任务减少 Godot->Python 次数
- [ ] 增量合并：大型表按模块拆分再合并输出
- [ ] Schema 校验（`jsonschema`）+ 失败生成报告（HTML / Markdown）
- [ ] 输出差异：比较上一次与本次 JSON，生成 diff 报告
- [ ] Watchdog（Python 侧实时监听）+ Godot 仅读取信号文件触发刷新

---

## 运行与调试指令示例（PowerShell）

```powershell
# 进入虚拟环境（如果已创建）
python -m venv python/venv
python/venv/Scripts/Activate.ps1

# 安装依赖
pip install -r python/requirements.txt

# 运行生成
python python/tools/build_tables.py
```

---

## 后续可扩展请求

如需要以下示例可进一步添加：

1. 任务选择 UI Popup 示例代码
2. 源文件 hash/缓存实现片段
3. JSON schema 校验集成
4. 监视模式 Timer 与状态面板
5. CI 工作流 yaml 示例

> 在提出需求时直接引用编号（如："请给 2 和 3 的示例"）。

---

（完）
