@tool
extends EditorPlugin

var dock_instance

func _enter_tree():
	# 添加工具菜单项
	add_tool_menu_item("转换Excel文件为JSON", _on_convert_excel)
	add_tool_menu_item("Excel转换器设置", _on_open_settings)
	add_tool_menu_item("打开Excel转换器面板", _on_open_dock)
	
	# 创建停靠面板
	dock_instance = preload("res://addons/py_excel_tool/excel_converter_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock_instance)
	
	print("[Excel转换器] 插件已加载")

func _exit_tree():
	# 移除菜单项
	remove_tool_menu_item("转换Excel文件为JSON")
	remove_tool_menu_item("Excel转换器设置")
	remove_tool_menu_item("打开Excel转换器面板")
	
	# 移除停靠面板
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
	
	print("[Excel转换器] 插件已卸载")

func _on_convert_excel():
	"""直接执行Excel转换"""
	var converter = ExcelConverterCore.new()
	converter.execute_conversion()

func _on_open_settings():
	"""打开设置对话框"""
	var settings_dialog = preload("res://addons/py_excel_tool/settings_dialog.tscn").instantiate()
	EditorInterface.get_base_control().add_child(settings_dialog)
	settings_dialog.popup_centered(Vector2i(400, 300))

func _on_open_dock():
	"""聚焦到停靠面板"""
	if dock_instance:
		dock_instance.grab_focus()