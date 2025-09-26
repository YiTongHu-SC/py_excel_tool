extends EditorScript

# 项目设置验证脚本
# 在Godot编辑器中运行: 工具 -> 执行脚本

func _run():
	print("=== Excel转换器项目设置验证 ===")
	
	# 验证所有应该存在的项目设置
	var expected_settings = [
		"excel_converter/python_path",
		"excel_converter/input_path", 
		"excel_converter/output_path",
		"excel_converter/auto_convert",
		"excel_converter/show_notifications",
		"excel_converter/verbose_logging",
		"excel_converter/enable_gdscript_generation",
		"excel_converter/gdscript_output_path",
		"excel_converter/base_resource_path"
	]
	
	print("\n检查项目设置存在性:")
	var missing_count = 0
	for setting in expected_settings:
		var exists = ProjectSettings.has_setting(setting)
		var value = ProjectSettings.get_setting(setting, "不存在")
		var status = "✓" if exists else "✗"
		print("  ", status, " ", setting, " = ", value)
		if not exists:
			missing_count += 1
	
	if missing_count > 0:
		print("\n发现 ", missing_count, " 个缺失的设置。")
		print("建议操作:")
		print("1. 确保插件已正确启用")
		print("2. 禁用插件后重新启用")
		print("3. 或手动运行设置初始化函数")
		
		print("\n正在尝试手动初始化设置...")
		_setup_project_settings()
	else:
		print("\n✓ 所有项目设置都已正确配置!")
	
	print("\n=== 验证完成 ===")

func _setup_project_settings():
	"""手动设置项目配置"""
	_add_project_setting("excel_converter/python_path", "", TYPE_STRING, "Python可执行文件路径")
	_add_project_setting("excel_converter/input_path", "res://addons/py_excel_tool/data/", TYPE_STRING, "Excel输入目录")
	_add_project_setting("excel_converter/output_path", "res://data/generated/", TYPE_STRING, "JSON输出目录")
	_add_project_setting("excel_converter/auto_convert", false, TYPE_BOOL, "自动转换")
	_add_project_setting("excel_converter/show_notifications", true, TYPE_BOOL, "显示通知")
	_add_project_setting("excel_converter/verbose_logging", false, TYPE_BOOL, "详细日志")
	_add_project_setting("excel_converter/enable_gdscript_generation", false, TYPE_BOOL, "启用GDScript生成")
	_add_project_setting("excel_converter/gdscript_output_path", "res://scripts/generated/", TYPE_STRING, "GDScript输出目录")
	_add_project_setting("excel_converter/base_resource_path", "res://scripts", TYPE_STRING, "基础资源路径")
	
	ProjectSettings.save()
	print("项目设置已手动初始化并保存")

func _add_project_setting(name: String, default_value, type: int, hint: String = ""):
	"""添加单个项目设置"""
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default_value)
		
		var property_info = {
			"name": name,
			"type": type,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": hint
		}
		
		# 为路径设置添加文件/目录选择器
		if name.ends_with("_path") or name.ends_with("_directory"):
			if name.contains("python"):
				property_info.hint = PROPERTY_HINT_GLOBAL_FILE
				if OS.has_feature("windows"):
					property_info.hint_string = "*.exe ; 可执行文件"
			else:
				property_info.hint = PROPERTY_HINT_GLOBAL_DIR
		
		ProjectSettings.add_property_info(property_info)
		print("✓ 已添加设置: ", name, " = ", default_value)
	else:
		print("- 设置已存在: ", name)