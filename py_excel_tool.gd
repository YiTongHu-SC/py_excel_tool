@tool
extends EditorPlugin

var dock_instance

func _enter_tree():
	# 执行python_path迁移 (从项目设置迁移到用户配置)
	_migrate_python_path()
	
	# 初始化项目设置
	_setup_project_settings()
	
	# 添加工具菜单项
	add_tool_menu_item("转换Excel文件为JSON", _on_convert_excel)
	add_tool_menu_item("转换Excel并生成GDScript", _on_convert_excel_with_gdscript)
	add_tool_menu_item("Excel转换器设置", _on_open_settings)
	add_tool_menu_item("打开Excel转换器面板", _on_open_dock)
	
	# 创建停靠面板
	dock_instance = preload("res://addons/py_excel_tool/excel_converter_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock_instance)
	
	print("[Excel转换器] 插件已加载")

func _exit_tree():
	# 移除菜单项
	remove_tool_menu_item("转换Excel文件为JSON")
	remove_tool_menu_item("转换Excel并生成GDScript")
	remove_tool_menu_item("Excel转换器设置")
	remove_tool_menu_item("打开Excel转换器面板")
	
	# 移除停靠面板
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
	
	# 注意: 通常不在插件卸载时移除项目设置，以保留用户配置
	# 如果确实需要清理，可以取消注释下面的行
	# _cleanup_project_settings()
	
	print("[Excel转换器] 插件已卸载")

func _on_convert_excel():
	"""直接执行Excel转换"""
	var converter = ExcelConverterCore.new()
	converter.execute_conversion()

func _on_convert_excel_with_gdscript():
	"""执行Excel转换并生成GDScript"""
	var converter = ExcelConverterCore.new()
	converter.execute_conversion("", "", true)

func _on_open_settings():
	"""打开设置对话框"""
	var settings_dialog = preload("res://addons/py_excel_tool/settings_dialog_new.tscn").instantiate()
	EditorInterface.get_base_control().add_child(settings_dialog)
	settings_dialog.popup_centered(Vector2i(550, 500))

func _on_open_dock():
	"""聚焦到停靠面板"""
	if dock_instance:
		dock_instance.grab_focus()

func _setup_project_settings():
	"""初始化项目设置"""
	# 基础设置 (python_path不再存储在项目设置中，改为用户本地配置)
	_add_project_setting("excel_converter/input_path", "res://addons/py_excel_tool/data/", TYPE_STRING, "默认Excel文件输入目录")
	_add_project_setting("excel_converter/output_path", "res://data/generated/", TYPE_STRING, "默认JSON文件输出目录")
	
	# 行为选项
	_add_project_setting("excel_converter/auto_convert", false, TYPE_BOOL, "文件改变时自动转换")
	_add_project_setting("excel_converter/show_notifications", true, TYPE_BOOL, "显示转换完成通知")
	_add_project_setting("excel_converter/verbose_logging", false, TYPE_BOOL, "详细日志输出")
	
	# GDScript生成相关设置
	_add_project_setting("excel_converter/enable_gdscript_generation", false, TYPE_BOOL, "启用GDScript脚本自动生成")
	_add_project_setting("excel_converter/gdscript_output_path", "res://scripts/generated/", TYPE_STRING, "GDScript输出目录")
	_add_project_setting("excel_converter/base_resource_path", "res://scripts", TYPE_STRING, "基础资源路径 (用于生成脚本内的引用路径)")
	
	# 保存项目设置
	ProjectSettings.save()
	print("[Excel转换器] 项目设置已初始化")

func _add_project_setting(name: String, default_value, type: int, hint: String = ""):
	"""添加项目设置"""
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default_value)
		
		# 设置属性信息以在项目设置界面显示
		var property_info = {
			"name": name,
			"type": type,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": hint
		}
		
		# 对于路径类型，添加目录选择提示
		if name.ends_with("_path") or name.ends_with("_directory"):
			if name.contains("python"):
				property_info.hint = PROPERTY_HINT_GLOBAL_FILE
				property_info.hint_string = "*.exe ; 可执行文件"
			else:
				property_info.hint = PROPERTY_HINT_GLOBAL_DIR
		
		ProjectSettings.add_property_info(property_info)
		print("[Excel转换器] 已添加项目设置: ", name, " = ", default_value)

func _cleanup_project_settings():
	"""清理项目设置 (通常不需要调用)"""
	var settings_to_remove = [
		"excel_converter/input_path",
		"excel_converter/output_path",
		"excel_converter/auto_convert",
		"excel_converter/show_notifications",
		"excel_converter/verbose_logging",
		"excel_converter/enable_gdscript_generation",
		"excel_converter/gdscript_output_path",
		"excel_converter/base_resource_path"
	]
	
	for setting in settings_to_remove:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.clear(setting)
	
	ProjectSettings.save()
	print("[Excel转换器] 项目设置已清理")

func _migrate_python_path():
	"""将python_path从项目设置迁移到用户配置"""
	if ProjectSettings.has_setting("excel_converter/python_path"):
		var old_python_path = ProjectSettings.get_setting("excel_converter/python_path", "")
		if old_python_path != "":
			# 保存到用户配置
			var config = ConfigFile.new()
			var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
			
			# 尝试加载现有配置
			config.load(config_path)
			
			# 设置Python路径
			config.set_value("user_settings", "python_path", old_python_path)
			
			# 保存配置
			var err = config.save(config_path)
			if err == OK:
				print("[Excel转换器] 已将python_path迁移到用户配置: ", old_python_path)
			else:
				print("[Excel转换器] ⚠️ 迁移python_path失败，错误代码: ", str(err))
		
		# 从项目设置中删除python_path
		ProjectSettings.clear("excel_converter/python_path")
		ProjectSettings.save()
		print("[Excel转换器] 已从项目设置中移除python_path")