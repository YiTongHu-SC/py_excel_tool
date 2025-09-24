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

@onready var browse_button: Button = $VBoxContainer/SettingsContainer/PythonGroup/PythonHBox/BrowseButton
@onready var test_button: Button = $VBoxContainer/SettingsContainer/PythonGroup/PythonHBox/TestButton
@onready var input_browse_button: Button = $VBoxContainer/SettingsContainer/PathsGroup/InputGroup/InputHBox/InputBrowseButton
@onready var output_browse_button: Button = $VBoxContainer/SettingsContainer/PathsGroup/OutputGroup/OutputHBox/OutputBrowseButton

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

func _load_settings():
	"""加载设置"""
	python_path_edit.text = ProjectSettings.get_setting("excel_converter/python_path", "")
	input_path_edit.text = ProjectSettings.get_setting("excel_converter/input_path", "res://addons/py_excel_tool/data/")
	output_path_edit.text = ProjectSettings.get_setting("excel_converter/output_path", "res://data/generated/")
	auto_convert_check.button_pressed = ProjectSettings.get_setting("excel_converter/auto_convert", false)
	show_notification_check.button_pressed = ProjectSettings.get_setting("excel_converter/show_notifications", true)
	verbose_logging_check.button_pressed = ProjectSettings.get_setting("excel_converter/verbose_logging", false)

func _save_settings():
	"""保存设置"""
	ProjectSettings.set_setting("excel_converter/python_path", python_path_edit.text)
	ProjectSettings.set_setting("excel_converter/input_path", input_path_edit.text)
	ProjectSettings.set_setting("excel_converter/output_path", output_path_edit.text)
	ProjectSettings.set_setting("excel_converter/auto_convert", auto_convert_check.button_pressed)
	ProjectSettings.set_setting("excel_converter/show_notifications", show_notification_check.button_pressed)
	ProjectSettings.set_setting("excel_converter/verbose_logging", verbose_logging_check.button_pressed)
	
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