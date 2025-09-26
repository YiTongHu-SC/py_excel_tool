@tool
extends AcceptDialog

# UI控件引用
@onready var python_path_edit: LineEdit = $VBoxContainer/SettingsContainer/PythonGroup/PythonHBox/PythonPathEdit
@onready var input_path_edit: LineEdit = $VBoxContainer/SettingsContainer/PathsGroup/InputGroup/InputHBox/InputPathEdit
@onready var output_path_edit: LineEdit = $VBoxContainer/SettingsContainer/PathsGroup/OutputGroup/OutputHBox/OutputPathEdit
@onready var auto_convert_check: CheckBox = $VBoxContainer/SettingsContainer/OptionsGroup/AutoConvertCheck
@onready var show_notification_check: CheckBox = $VBoxContainer/SettingsContainer/OptionsGroup/ShowNotificationCheck
@onready var verbose_logging_check: CheckBox = $VBoxContainer/SettingsContainer/OptionsGroup/VerboseLoggingCheck
@onready var status_label: Label = $VBoxContainer/StatusLabel

# GDScript生成相关控件
@onready var enable_gdscript_check: CheckBox = $VBoxContainer/SettingsContainer/GDScriptGroup/EnableGDScriptCheck
@onready var gdscript_output_edit: LineEdit = $VBoxContainer/SettingsContainer/GDScriptGroup/GDScriptOutputGroup/GDScriptOutputHBox/GDScriptOutputEdit
@onready var base_resource_path_edit: LineEdit = $VBoxContainer/SettingsContainer/GDScriptGroup/BaseResourceGroup/BaseResourceHBox/BaseResourcePathEdit

@onready var browse_button: Button = $VBoxContainer/SettingsContainer/PythonGroup/PythonHBox/BrowseButton
@onready var test_button: Button = $VBoxContainer/SettingsContainer/PythonGroup/PythonHBox/TestButton
@onready var input_browse_button: Button = $VBoxContainer/SettingsContainer/PathsGroup/InputGroup/InputHBox/InputBrowseButton
@onready var output_browse_button: Button = $VBoxContainer/SettingsContainer/PathsGroup/OutputGroup/OutputHBox/OutputBrowseButton
@onready var gdscript_output_browse_button: Button = $VBoxContainer/SettingsContainer/GDScriptGroup/GDScriptOutputGroup/GDScriptOutputHBox/GDScriptOutputBrowseButton

func _ready():
	if Engine.is_editor_hint():
		_connect_signals()
		_load_settings()

func _connect_signals():
	"""连接信号"""
	confirmed.connect(_on_confirmed)
	browse_button.pressed.connect(_on_browse_python)
	test_button.pressed.connect(_on_test_python)
	input_browse_button.pressed.connect(_on_browse_input)
	output_browse_button.pressed.connect(_on_browse_output)
	if gdscript_output_browse_button:
		gdscript_output_browse_button.pressed.connect(_on_browse_gdscript_output)
	if enable_gdscript_check:
		enable_gdscript_check.toggled.connect(_on_gdscript_enabled_toggled)

func _load_settings():
	"""加载设置"""
	# Python路径从用户本地配置加载
	python_path_edit.text = _load_python_path_from_user_config()
	# 其他设置仍然从项目设置加载
	input_path_edit.text = ProjectSettings.get_setting("excel_converter/input_path", "res://addons/py_excel_tool/data/")
	output_path_edit.text = ProjectSettings.get_setting("excel_converter/output_path", "res://data/generated/")
	auto_convert_check.button_pressed = ProjectSettings.get_setting("excel_converter/auto_convert", false)
	show_notification_check.button_pressed = ProjectSettings.get_setting("excel_converter/show_notifications", true)
	verbose_logging_check.button_pressed = ProjectSettings.get_setting("excel_converter/verbose_logging", false)
	
	# GDScript生成相关设置
	if enable_gdscript_check:
		enable_gdscript_check.button_pressed = ProjectSettings.get_setting("excel_converter/enable_gdscript_generation", false)
	if gdscript_output_edit:
		gdscript_output_edit.text = ProjectSettings.get_setting("excel_converter/gdscript_output_path", "res://scripts/generated/")
	if base_resource_path_edit:
		base_resource_path_edit.text = ProjectSettings.get_setting("excel_converter/base_resource_path", "res://scripts")
	
	_update_gdscript_ui_state()

func _save_settings():
	"""保存设置"""
	# Python路径保存到用户本地配置
	_save_python_path_to_user_config(python_path_edit.text)
	# 其他设置保存到项目设置 (python_path不再保存到项目设置)
	ProjectSettings.set_setting("excel_converter/input_path", input_path_edit.text)
	ProjectSettings.set_setting("excel_converter/output_path", output_path_edit.text)
	ProjectSettings.set_setting("excel_converter/auto_convert", auto_convert_check.button_pressed)
	ProjectSettings.set_setting("excel_converter/show_notifications", show_notification_check.button_pressed)
	ProjectSettings.set_setting("excel_converter/verbose_logging", verbose_logging_check.button_pressed)
	
	# GDScript生成相关设置
	if enable_gdscript_check:
		ProjectSettings.set_setting("excel_converter/enable_gdscript_generation", enable_gdscript_check.button_pressed)
	if gdscript_output_edit:
		ProjectSettings.set_setting("excel_converter/gdscript_output_path", gdscript_output_edit.text)
	if base_resource_path_edit:
		ProjectSettings.set_setting("excel_converter/base_resource_path", base_resource_path_edit.text)
	
	ProjectSettings.save()
	
	status_label.text = "设置已保存"
	print("[Excel转换器] 设置已保存")

func _on_confirmed():
	"""确认按钮点击事件"""
	_save_settings()

func _on_browse_python():
	"""浏览Python可执行文件"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	
	# 设置过滤器
	if OS.has_feature("windows"):
		file_dialog.add_filter("*.exe", "可执行文件")
		file_dialog.current_dir = "C:/Python39"  # 常见Python安装路径
	else:
		file_dialog.current_dir = "/usr/bin"
	
	file_dialog.file_selected.connect(_on_python_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_python_file_selected(path: String):
	"""Python文件选择完成"""
	python_path_edit.text = path
	# 移除临时添加的文件对话框
	for child in get_children():
		if child is EditorFileDialog:
			child.queue_free()

func _on_test_python():
	"""测试Python路径"""
	var python_path = python_path_edit.text
	if python_path == "":
		python_path = "python"
	
	status_label.text = "正在测试Python路径..."
	test_button.disabled = true
	
	var output = []
	var exit_code = OS.execute(python_path, ["--version"], output, true, true)
	
	if exit_code == 0:
		var version_info = ""
		if output.size() > 0:
			version_info = output[0]
		status_label.text = "Python测试成功: " + version_info
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Python测试失败，请检查路径"
		status_label.modulate = Color.RED
	
	test_button.disabled = false
	
	# 3秒后重置状态
	await get_tree().create_timer(3.0).timeout
	status_label.text = "就绪"
	status_label.modulate = Color.WHITE

func _on_browse_input():
	"""浏览输入目录"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.current_dir = "res://"
	file_dialog.dir_selected.connect(_on_input_dir_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_input_dir_selected(path: String):
	"""输入目录选择完成"""
	input_path_edit.text = path
	# 移除临时添加的文件对话框
	for child in get_children():
		if child is EditorFileDialog:
			child.queue_free()

func _on_browse_output():
	"""浏览输出目录"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.current_dir = "res://"
	file_dialog.dir_selected.connect(_on_output_dir_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_output_dir_selected(path: String):
	"""输出目录选择完成"""
	output_path_edit.text = path
	# 移除临时添加的文件对话框
	for child in get_children():
		if child is EditorFileDialog:
			child.queue_free()

func _on_gdscript_enabled_toggled(enabled: bool):
	"""GDScript生成开关切换"""
	_update_gdscript_ui_state()

func _update_gdscript_ui_state():
	"""更新GDScript相关UI的启用状态"""
	if not enable_gdscript_check:
		return
		
	var enabled = enable_gdscript_check.button_pressed
	if gdscript_output_edit:
		gdscript_output_edit.editable = enabled
	if base_resource_path_edit:
		base_resource_path_edit.editable = enabled
	if gdscript_output_browse_button:
		gdscript_output_browse_button.disabled = not enabled

func _on_browse_gdscript_output():
	"""浏览GDScript输出目录"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.current_dir = "res://"
	file_dialog.dir_selected.connect(_on_gdscript_output_dir_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_gdscript_output_dir_selected(path: String):
	"""GDScript输出目录选择完成"""
	if gdscript_output_edit:
		gdscript_output_edit.text = path
	# 移除临时添加的文件对话框
	for child in get_children():
		if child is EditorFileDialog:
			child.queue_free()

func _load_python_path_from_user_config() -> String:
	"""从用户本地配置加载Python路径"""
	var config = ConfigFile.new()
	var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
	var err = config.load(config_path)
	
	if err == OK:
		return config.get_value("user_settings", "python_path", "")
	else:
		return ""

func _save_python_path_to_user_config(python_path: String):
	"""保存Python路径到用户本地配置"""
	var config = ConfigFile.new()
	var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
	
	# 尝试加载现有配置
	config.load(config_path)
	
	# 设置Python路径
	config.set_value("user_settings", "python_path", python_path)
	
	# 保存配置
	var err = config.save(config_path)
	if err != OK:
		push_error("无法保存Python路径到用户配置，错误代码: " + str(err))