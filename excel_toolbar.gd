@tool
extends HBoxContainer

# UI控件
@onready var convert_button: Button = $ConvertButton
@onready var quick_convert_button: Button = $QuickConvertButton  
@onready var settings_button: Button = $SettingsButton
@onready var status_label: Label = $StatusLabel

# 转换器实例
var converter

func _ready():
	if Engine.is_editor_hint():
		var ExcelConverterCore = load("res://addons/py_excel_tool/excel_converter_core.gd")
		converter = ExcelConverterCore.new()
		_connect_signals()

func _connect_signals():
	"""连接信号"""
	convert_button.pressed.connect(_on_convert_pressed)
	quick_convert_button.pressed.connect(_on_quick_convert_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_convert_pressed():
	"""普通转换按钮"""
	_update_status("开始转换...")
	var success = converter.execute_conversion()
	_update_status("转换完成" if success else "转换失败")

func _on_quick_convert_pressed():
	"""快速转换按钮 - 使用默认路径"""
	_update_status("快速转换中...")
	var input_path = ProjectSettings.get_setting("excel_converter/input_path", "res://addons/py_excel_tool/data/")
	var output_path = ProjectSettings.get_setting("excel_converter/output_path", "res://data/generated/")
	
	var success = converter.execute_conversion(input_path, output_path)
	_update_status("快速转换完成" if success else "快速转换失败")

func _on_settings_pressed():
	"""设置按钮"""
	var settings_dialog = preload("res://addons/py_excel_tool/settings_dialog.tscn").instantiate()
	EditorInterface.get_base_control().add_child(settings_dialog)
	settings_dialog.popup_centered(Vector2i(500, 350))

func _update_status(message: String):
	"""更新状态"""
	status_label.text = message
	print("[Excel转换器工具栏] " + message)