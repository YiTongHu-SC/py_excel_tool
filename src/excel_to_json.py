#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Excel到JSON批量转换工具

该脚本用于将Excel文件批量转换为JSON格式文件。
支持.xlsx和.xls格式的Excel文件。
"""

import os
import json
import pandas as pd
from pathlib import Path
import argparse
import logging
from typing import List, Dict, Any

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ExcelToJsonConverter:
    """Excel到JSON转换器类"""
    
    def __init__(self, input_dir: str, output_dir: str):
        """
        初始化转换器
        
        Args:
            input_dir (str): 输入Excel文件目录
            output_dir (str): 输出JSON文件目录
        """
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        
        # 确保输出目录存在
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 支持的Excel文件格式
        self.supported_extensions = {'.xlsx', '.xls'}
    
    def get_excel_files(self) -> List[Path]:
        """
        获取输入目录中所有Excel文件
        
        Returns:
            List[Path]: Excel文件路径列表
        """
        excel_files = []
        
        for file_path in self.input_dir.iterdir():
            if file_path.is_file() and file_path.suffix.lower() in self.supported_extensions:
                excel_files.append(file_path)
        
        return excel_files
    
    def convert_excel_to_json(self, excel_file: Path, sheet_name: str = "") -> Dict[str, Any]:
        """
        将Excel文件转换为JSON格式
        
        Args:
            excel_file (Path): Excel文件路径
            sheet_name (str, optional): 工作表名称，默认为None（第一个工作表）
        
        Returns:
            Dict[str, Any]: 转换后的JSON数据
        """
        try:
            # 读取Excel文件
            if sheet_name:
                df = pd.read_excel(excel_file, sheet_name=sheet_name)
                sheets_data = {sheet_name: df.to_dict('records')}
            else:
                # 读取所有工作表
                excel_data = pd.read_excel(excel_file, sheet_name=None)
                sheets_data = {}
                
                for sheet_name, df in excel_data.items():
                    # 处理NaN值，转换为None
                    df = df.where(pd.notnull(df), None)
                    sheets_data[sheet_name] = df.to_dict('records')
            
            return sheets_data
            
        except Exception as e:
            logger.error(f"读取Excel文件 {excel_file} 时出错: {str(e)}")
            raise
    
    def save_json(self, data: Dict[str, Any], output_file: Path) -> None:
        """
        保存JSON数据到文件
        
        Args:
            data (Dict[str, Any]): JSON数据
            output_file (Path): 输出文件路径
        """
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            logger.info(f"成功保存JSON文件: {output_file}")
            
        except Exception as e:
            logger.error(f"保存JSON文件 {output_file} 时出错: {str(e)}")
            raise
    
    def convert_single_file(self, excel_file: Path) -> None:
        """
        转换单个Excel文件
        
        Args:
            excel_file (Path): Excel文件路径
        """
        try:
            logger.info(f"开始转换文件: {excel_file}")
            
            # 转换Excel到JSON
            json_data = self.convert_excel_to_json(excel_file)
            
            # 生成输出文件名
            output_filename = excel_file.stem + '.json'
            output_file = self.output_dir / output_filename
            
            # 保存JSON文件
            self.save_json(json_data, output_file)
            
            logger.info(f"文件转换完成: {excel_file} -> {output_file}")
            
        except Exception as e:
            logger.error(f"转换文件 {excel_file} 失败: {str(e)}")
    
    def convert_all_files(self) -> None:
        """批量转换所有Excel文件"""
        excel_files = self.get_excel_files()
        
        if not excel_files:
            logger.warning(f"在目录 {self.input_dir} 中没有找到Excel文件")
            return
        
        logger.info(f"找到 {len(excel_files)} 个Excel文件，开始批量转换...")
        
        success_count = 0
        error_count = 0
        
        for excel_file in excel_files:
            try:
                self.convert_single_file(excel_file)
                success_count += 1
            except Exception as e:
                error_count += 1
                logger.error(f"转换文件 {excel_file} 失败: {str(e)}")
        
        logger.info(f"批量转换完成！成功: {success_count}, 失败: {error_count}")


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='Excel到JSON批量转换工具')
    parser.add_argument('--input', '-i', 
                       default='./excel_files',
                       help='输入Excel文件目录 (默认: ./excel_files)')
    parser.add_argument('--output', '-o',
                       default='./json_files', 
                       help='输出JSON文件目录 (默认: ./json_files)')
    parser.add_argument('--file', '-f',
                       help='转换单个文件（指定文件路径）')
    
    args = parser.parse_args()
    
    # 创建转换器实例
    converter = ExcelToJsonConverter(args.input, args.output)
    
    if args.file:
        # 转换单个文件
        file_path = Path(args.file)
        if file_path.exists() and file_path.suffix.lower() in converter.supported_extensions:
            converter.convert_single_file(file_path)
        else:
            logger.error(f"文件不存在或格式不支持: {args.file}")
    else:
        # 批量转换
        converter.convert_all_files()


if __name__ == '__main__':
    main()