@tool
extends EditorScript

# 测试用户配置功能的脚本

func _run():
	print("=== 测试用户配置功能 ===")
	
	# 测试ExcelConverterCore的Python路径获取
	var converter = ExcelConverterCore.new()
	var python_path = converter.get_python_path()
	print("从ExcelConverterCore获取的Python路径: ", python_path)
	
	# 测试配置文件位置
	var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
	print("用户配置文件路径: ", config_path)
	
	# 检查配置文件是否存在
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file:
		print("用户配置文件已存在")
		var content = file.get_as_text()
		file.close()
		print("配置文件内容:")
		print(content)
	else:
		print("用户配置文件不存在，将在首次保存时创建")
	
	# 检查项目设置中是否还有python_path
	if ProjectSettings.has_setting("excel_converter/python_path"):
		print("⚠️ 项目设置中仍然存在python_path: ", ProjectSettings.get_setting("excel_converter/python_path"))
	else:
		print("✅ 项目设置中已正确移除python_path")
	
	print("=== 测试完成 ===")