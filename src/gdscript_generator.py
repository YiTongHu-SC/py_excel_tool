#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GDScript自动生成工具

该脚本用于根据Excel数据结构自动生成Godot游戏引擎的GDScript脚本。
包括数据类脚本和数据加载类脚本。
"""

import os
import json
import pandas as pd
from pathlib import Path
import argparse
import logging
from typing import List, Dict, Any, Tuple, Optional
import configparser
import re

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class GDScriptGenerator:
    """GDScript生成器类"""
    
    def __init__(self, config_path: str = "config.ini"):
        """
        初始化生成器
        
        Args:
            config_path (str): 配置文件路径
        """
        self.config = configparser.ConfigParser()
        self.config_path = Path(config_path)
        
        # 默认配置
        self.default_config = {
            'gdscript_output_dir': './gdscript_output',
            'data_class_dir': 'data',
            'loader_class_dir': 'loader',
            'class_name_prefix': '',
            'class_name_suffix': 'Data',
            'loader_class_suffix': 'Loader',
            'base_resource_path': ''
        }
        
        self.load_config()
    
    def load_config(self):
        """加载配置文件"""
        if self.config_path.exists():
            self.config.read(self.config_path, encoding='utf-8')
        
        # 添加GDSCRIPT section如果不存在
        if 'GDSCRIPT' not in self.config:
            self.config.add_section('GDSCRIPT')
        
        # 设置默认值
        for key, value in self.default_config.items():
            if not self.config.has_option('GDSCRIPT', key):
                self.config.set('GDSCRIPT', key, value)
    
    def save_config(self):
        """保存配置文件"""
        with open(self.config_path, 'w', encoding='utf-8') as f:
            self.config.write(f)
    
    def analyze_json_structure(self, json_data: Dict[str, Any]) -> Dict[str, Dict[str, str]]:
        """
        分析JSON数据结构，推断字段类型
        
        Args:
            json_data (Dict[str, Any]): JSON数据
        
        Returns:
            Dict[str, Dict[str, str]]: 每个表的字段类型信息
        """
        sheets_structure = {}
        
        for sheet_name, records in json_data.items():
            if not records or not isinstance(records, list):
                continue
            
            field_types = {}
            
            # 分析第一条记录的字段类型
            first_record = records[0]
            if isinstance(first_record, dict):
                for field_name, value in first_record.items():
                    field_types[field_name] = self.infer_gdscript_type(value)
                
                # 检查其他记录以确保类型一致性
                for record in records[1:]:
                    if isinstance(record, dict):
                        for field_name, value in record.items():
                            if field_name in field_types:
                                inferred_type = self.infer_gdscript_type(value)
                                # 如果类型不一致，使用更通用的类型
                                if field_types[field_name] != inferred_type:
                                    field_types[field_name] = self.get_common_type(
                                        field_types[field_name], inferred_type
                                    )
            
            sheets_structure[sheet_name] = field_types
        
        return sheets_structure
    
    def infer_gdscript_type(self, value: Any) -> str:
        """
        根据值推断GDScript类型
        
        Args:
            value (Any): 值
        
        Returns:
            str: GDScript类型
        """
        if value is None:
            return "Variant"
        elif isinstance(value, bool):
            return "bool"
        elif isinstance(value, int):
            return "int"
        elif isinstance(value, float):
            return "float"
        elif isinstance(value, str):
            return "String"
        elif isinstance(value, list):
            return "Array"
        elif isinstance(value, dict):
            return "Dictionary"
        else:
            return "Variant"
    
    def get_common_type(self, type1: str, type2: str) -> str:
        """
        获取两个类型的公共类型
        
        Args:
            type1 (str): 类型1
            type2 (str): 类型2
        
        Returns:
            str: 公共类型
        """
        if type1 == type2:
            return type1
        
        # 数值类型的兼容性
        numeric_types = {"int", "float"}
        if {type1, type2}.issubset(numeric_types):
            return "float"  # int和float的公共类型是float
        
        # 其他情况返回Variant
        return "Variant"
    
    def generate_data_class(self, sheet_name: str, field_types: Dict[str, str]) -> str:
        """
        生成数据类脚本
        
        Args:
            sheet_name (str): 表名
            field_types (Dict[str, str]): 字段类型信息
        
        Returns:
            str: 数据类脚本内容
        """
        class_name = self.get_data_class_name(sheet_name)
        
        script_lines = [
            f"## {sheet_name}数据类，由Excel工具自动生成",
            f"## 使用: var data = {class_name}.new(json_record)",
            f"class {class_name}:",
            ""
        ]
        
        # 生成字段声明
        for field_name, field_type in field_types.items():
            gd_field_name = self.convert_to_gdscript_name(field_name)
            default_value = self.get_default_value(field_type)
            script_lines.append(f"\tvar {gd_field_name}: {field_type} = {default_value}")
        
        script_lines.extend([
            "",
            f"\t## 构造函数",
            f"\tfunc _init(data: Dictionary = {{}}):",
            f"\t\tif data.is_empty():",
            f"\t\t\treturn",
            ""
        ])
        
        # 生成字段赋值代码
        for field_name, field_type in field_types.items():
            gd_field_name = self.convert_to_gdscript_name(field_name)
            script_lines.append(f'\t\tif data.has("{field_name}"):')
            script_lines.append(f'\t\t\t{gd_field_name} = data["{field_name}"]')
        
        return "\n".join(script_lines)
    
    def generate_loader_class(self, sheet_name: str, field_types: Dict[str, str], output_dir: Optional[Path] = None) -> str:
        """
        生成数据加载类脚本
        
        Args:
            sheet_name (str): 表名
            field_types (Dict[str, str]): 字段类型信息
            output_dir (Path): 输出目录，用于计算相对路径
        
        Returns:
            str: 数据加载类脚本内容
        """
        data_class_name = self.get_data_class_name(sheet_name)
        loader_class_name = self.get_loader_class_name(sheet_name)
        
        # 生成正确的资源路径
        if output_dir:
            resource_path = self.generate_data_resource_path(sheet_name, output_dir)
        else:
            # 回退到默认绝对路径
            data_filename = self.get_data_class_filename(sheet_name)
            resource_path = f"res://scripts/generated/data/{data_filename}"
        
        # 查找ID字段
        id_field = self.find_id_field(field_types)
        id_type = field_types.get(id_field, "int") if id_field else "int"
        
        script_lines = [
            f"## {sheet_name}数据加载器，由Excel工具自动生成",
            f"class_name {loader_class_name}",
            "",
            f"## 引入数据类脚本",
            f'const DataScript = preload("{resource_path}")',
            "",
            f"## 数据字典和数组 (使用Variant类型避免循环依赖)",
            f"var data_dict: Dictionary[{id_type}, Variant] = {{}}",
            f"var data_array: Array[Variant] = []",
            "",
            f"## 加载数据",
            f"func load_data(json_path: String):",
            f"\tvar file = FileAccess.open(json_path, FileAccess.READ)",
            f"\tif file == null:",
            f'\t\tprint("无法打开文件: ", json_path)',
            f"\t\treturn",
            f"\t",
            f"\tvar json_string = file.get_as_text()",
            f"\tfile.close()",
            f"\t",
            f"\tvar json = JSON.new()",
            f"\tvar parse_result = json.parse(json_string)",
            f"\tif parse_result != OK:",
            f'\t\tprint("JSON解析失败: ", json.error_string)',
            f"\t\treturn",
            f"\t",
            f"\tvar json_data = json.data",
            f'\tif not json_data.has("{sheet_name}"):',
            f'\t\tprint("JSON中没有找到{sheet_name}数据")',
            f"\t\treturn",
            f"\t",
            f"\tvar records = json_data[\"{sheet_name}\"]",
            f"\tfor record in records:",
            f"\t\tvar data_item = DataScript.{data_class_name}.new(record)",
            f"\t\tdata_array.append(data_item)",
        ]
        
        if id_field:
            gd_id_field = self.convert_to_gdscript_name(id_field)
            script_lines.extend([
                f"\t\tdata_dict[data_item.{gd_id_field}] = data_item"
            ])
        
        script_lines.extend([
            "",
            f"## 根据ID获取数据",
            f"func get_by_id(id: {id_type}) -> Variant:",
            f"\treturn data_dict.get(id, null)",
            "",
            f"## 获取所有数据",
            f"func get_all() -> Array[Variant]:",
            f"\treturn data_array",
            "",
            f"## 获取数据数量",
            f"func get_count() -> int:",
            f"\treturn data_array.size()",
            "",
            f"## 创建新的数据项实例",
            f"func create_data_item(data: Dictionary) -> Variant:",
            f"\treturn DataScript.{data_class_name}.new(data)"
        ])
        
        return "\n".join(script_lines)
    
    def find_id_field(self, field_types: Dict[str, str]) -> str:
        """
        查找ID字段
        
        Args:
            field_types (Dict[str, str]): 字段类型信息
        
        Returns:
            str: ID字段名
        """
        # 常见的ID字段名
        id_candidates = ['ID', 'id', 'Id', 'key', 'Key', 'index', 'Index']
        
        for candidate in id_candidates:
            if candidate in field_types:
                return candidate
        
        # 如果没有找到，返回第一个int类型字段
        for field_name, field_type in field_types.items():
            if field_type == "int":
                return field_name
        
        # 如果都没有，返回第一个字段
        if field_types:
            return list(field_types.keys())[0]
        
        return ""
    
    def convert_to_gdscript_name(self, name: str) -> str:
        """
        将字段名转换为GDScript命名规范（snake_case）
        
        Args:
            name (str): 原始字段名
        
        Returns:
            str: GDScript字段名
        """
        # 转换为小写并处理特殊字符
        name = re.sub(r'[^a-zA-Z0-9_]', '_', name)
        name = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', name)
        name = name.lower()
        name = re.sub(r'_+', '_', name)  # 合并多个下划线
        name = name.strip('_')  # 去除首尾下划线
        
        # 确保不是关键字
        gdscript_keywords = {
            'and', 'or', 'not', 'if', 'elif', 'else', 'for', 'while', 'break', 'continue',
            'pass', 'return', 'class', 'extends', 'func', 'var', 'const', 'enum', 'signal',
            'tool', 'static', 'export', 'onready', 'setget', 'true', 'false', 'null'
        }
        
        if name in gdscript_keywords:
            name = name + '_value'
        
        return name
    
    def get_default_value(self, field_type: str) -> str:
        """
        获取类型的默认值
        
        Args:
            field_type (str): 字段类型
        
        Returns:
            str: 默认值
        """
        default_values = {
            "bool": "false",
            "int": "0",
            "float": "0.0",
            "String": '""',
            "Array": "[]",
            "Dictionary": "{}",
            "Variant": "null"
        }
        
        return default_values.get(field_type, "null")
    
    def get_data_class_name(self, sheet_name: str) -> str:
        """获取数据类名"""
        prefix = self.config.get('GDSCRIPT', 'class_name_prefix', fallback='')
        suffix = self.config.get('GDSCRIPT', 'class_name_suffix', fallback='Data')
        
        # 转换为PascalCase
        clean_name = re.sub(r'[^a-zA-Z0-9]', '_', sheet_name)
        pascal_name = ''.join(word.capitalize() for word in clean_name.split('_') if word)
        
        return f"{prefix}{pascal_name}{suffix}"
    
    def get_loader_class_name(self, sheet_name: str) -> str:
        """获取加载器类名"""
        data_class_name = self.get_data_class_name(sheet_name)
        suffix = self.config.get('GDSCRIPT', 'loader_class_suffix', fallback='Loader')
        
        # 移除Data后缀（如果存在）
        if data_class_name.endswith('Data'):
            base_name = data_class_name[:-4]
        else:
            base_name = data_class_name
        
        return f"{base_name}{suffix}"
    
    def get_data_class_filename(self, sheet_name: str) -> str:
        """获取数据类文件名"""
        class_name = self.get_data_class_name(sheet_name)
        # 转换为snake_case
        filename = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', class_name).lower()
        return f"{filename}.gd"
    
    def get_loader_class_filename(self, sheet_name: str) -> str:
        """获取加载器类文件名"""
        class_name = self.get_loader_class_name(sheet_name)
        # 转换为snake_case
        filename = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', class_name).lower()
        return f"{filename}.gd"
    
    def generate_data_resource_path(self, sheet_name: str, output_dir: Path) -> str:
        """
        生成数据类的资源路径
        
        Args:
            sheet_name (str): 表名
            output_dir (Path): 输出目录
        
        Returns:
            str: 数据类的资源路径
        """
        base_path = self.config.get('GDSCRIPT', 'base_resource_path', fallback='').strip()
        data_class_dir = self.config.get('GDSCRIPT', 'data_class_dir', fallback='data')
        data_filename = self.get_data_class_filename(sheet_name)
        
        # 优先使用配置的基础路径
        if base_path:
            # 使用配置的基础路径，忽略output_dir
            if not base_path.endswith('/'):
                base_path += '/'
            return f"{base_path}{data_class_dir}/{data_filename}"
        
        # 如果没有配置base_resource_path，则根据output_dir生成路径
        if output_dir:
            # 将输出目录转换为res://路径
            output_dir_str = str(output_dir).replace('\\', '/')
            
            # 如果输出目录已经是res://路径，直接使用
            if output_dir_str.startswith('res://'):
                return f"{output_dir_str}/{data_class_dir}/{data_filename}"
            
            # 如果是绝对Windows路径，尝试提取相对于项目的部分
            if ':' in output_dir_str:  # 判断是否为绝对路径（包含驱动器字母）
                # 尝试找到项目根目录的相对路径
                # 假设输出路径类似 "d:/godot-project/meme-dungeon-godot/scripts/xxx"
                # 我们需要提取 "scripts/xxx" 部分
                parts = output_dir_str.split('/')
                if 'meme-dungeon-godot' in parts:
                    # 找到项目名后的路径
                    project_index = parts.index('meme-dungeon-godot')
                    relative_parts = parts[project_index + 1:]
                    relative_path = '/'.join(relative_parts)
                    return f"res://{relative_path}/{data_class_dir}/{data_filename}"
            
            # 如果是相对路径，转换为res://路径
            if output_dir_str.startswith('./'):
                output_dir_str = output_dir_str[2:]
            elif not output_dir_str.startswith('/'):
                # 相对路径，直接使用
                pass
            
            return f"res://{output_dir_str}/{data_class_dir}/{data_filename}"
        else:
            # 回退到默认路径
            return f"res://scripts/generated/{data_class_dir}/{data_filename}"
    
    def generate_scripts_from_json(self, json_file: Path, output_dir: Optional[Path] = None) -> None:
        """
        从JSON文件生成GDScript脚本
        
        Args:
            json_file (Path): JSON文件路径
            output_dir (Path): 输出目录
        """
        if output_dir is None:
            output_dir = Path(self.config.get('GDSCRIPT', 'gdscript_output_dir'))
        
        try:
            # 读取JSON文件
            with open(json_file, 'r', encoding='utf-8') as f:
                json_data = json.load(f)
            
            # 分析数据结构
            sheets_structure = self.analyze_json_structure(json_data)
            
            if not sheets_structure:
                logger.warning(f"JSON文件 {json_file} 中没有找到有效的数据结构")
                return
            
            # 创建输出目录
            data_dir = output_dir / self.config.get('GDSCRIPT', 'data_class_dir', fallback='data')
            loader_dir = output_dir / self.config.get('GDSCRIPT', 'loader_class_dir', fallback='loader')
            
            data_dir.mkdir(parents=True, exist_ok=True)
            loader_dir.mkdir(parents=True, exist_ok=True)
            
            # 生成脚本文件
            for sheet_name, field_types in sheets_structure.items():
                if not field_types:  # 跳过空表
                    continue
                
                # 生成数据类脚本
                data_script = self.generate_data_class(sheet_name, field_types)
                data_filename = self.get_data_class_filename(sheet_name)
                data_file_path = data_dir / data_filename
                
                with open(data_file_path, 'w', encoding='utf-8') as f:
                    f.write(data_script)
                
                logger.info(f"生成数据类脚本: {data_file_path}")
                
                # 生成加载器类脚本
                loader_script = self.generate_loader_class(sheet_name, field_types, output_dir)
                loader_filename = self.get_loader_class_filename(sheet_name)
                loader_file_path = loader_dir / loader_filename
                
                with open(loader_file_path, 'w', encoding='utf-8') as f:
                    f.write(loader_script)
                
                logger.info(f"生成加载器类脚本: {loader_file_path}")
            
            logger.info(f"成功生成 {json_file.stem} 的GDScript脚本")
            
        except Exception as e:
            logger.error(f"生成GDScript脚本失败: {str(e)}")
            raise
    
    def batch_generate_from_directory(self, json_dir: Path, output_dir: Optional[Path] = None) -> None:
        """
        批量从目录中的JSON文件生成GDScript脚本
        
        Args:
            json_dir (Path): JSON文件目录
            output_dir (Path): 输出目录
        """
        if not json_dir.exists() or not json_dir.is_dir():
            logger.error(f"JSON目录不存在: {json_dir}")
            return
        
        json_files = list(json_dir.glob('*.json'))
        
        if not json_files:
            logger.warning(f"在目录 {json_dir} 中没有找到JSON文件")
            return
        
        logger.info(f"找到 {len(json_files)} 个JSON文件，开始批量生成GDScript...")
        
        success_count = 0
        error_count = 0
        
        for json_file in json_files:
            try:
                self.generate_scripts_from_json(json_file, output_dir)
                success_count += 1
            except Exception as e:
                error_count += 1
                logger.error(f"处理文件 {json_file} 失败: {str(e)}")
        
        logger.info(f"批量生成完成！成功: {success_count}, 失败: {error_count}")


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='GDScript自动生成工具')
    parser.add_argument('--json-dir', '-j',
                       default='../example/data',
                       help='输入JSON文件目录 (默认: ../example/data)')
    parser.add_argument('--output', '-o',
                       default='./gdscript_output',
                       help='输出GDScript文件目录 (默认: ./gdscript_output)')
    parser.add_argument('--file', '-f',
                       help='生成单个JSON文件的脚本（指定文件路径）')
    parser.add_argument('--config', '-c',
                       default='config.ini',
                       help='配置文件路径 (默认: config.ini)')
    
    args = parser.parse_args()
    
    # 创建生成器实例
    generator = GDScriptGenerator(args.config)
    
    if args.file:
        # 生成单个文件的脚本
        json_file = Path(args.file)
        if json_file.exists() and json_file.suffix.lower() == '.json':
            generator.generate_scripts_from_json(json_file, Path(args.output))
        else:
            logger.error(f"JSON文件不存在或格式不正确: {args.file}")
    else:
        # 批量生成
        generator.batch_generate_from_directory(Path(args.json_dir), Path(args.output))
    
    # 保存配置
    generator.save_config()


if __name__ == '__main__':
    main()