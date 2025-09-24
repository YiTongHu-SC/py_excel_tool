@tool
extends Control

var converter
var logger

# UI控件引用
var input_path_edit: LineEdit
var output_path_edit: LineEdit
var python_path_edit: LineEdit
var convert_button: Button
var log_output: TextEdit
var progress_bar: ProgressBar
var status_label: Label

# 设置相关
var settings_dialog: AcceptDialog

func _init():
	name = "Excel转换器"
	custom_minimum_size = Vector2(300, 400)
	# 延迟加载转换器
	call_deferred("_setup_converter")

func _setup_converter():
	if is_inside_tree():
		var ExcelConverterCore = load("res://addons/py_excel_tool/excel_converter_core.gd")
		converter = ExcelConverterCore.new()

func _ready():
	if Engine.is_editor_hint():
		_setup_ui()
		_load_settings()

func _setup_ui():
	"""设置UI界面"""
	# 创建主垂直布局
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	
	# 标题
	var title_label = Label.new()
	title_label.text = "Excel到JSON转换器"
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)
	
	main_vbox.add_child(HSeparator.new())
	
	# 路径设置区域
	var path_group = VBoxContainer.new()
	main_vbox.add_child(path_group)
	
	# Python路径
	var python_group = VBoxContainer.new()
	path_group.add_child(python_group)
	
	var python_label = Label.new()
	python_label.text = "Python路径:"
	python_group.add_child(python_label)
	
	var python_hbox = HBoxContainer.new()
	python_group.add_child(python_hbox)
	
	python_path_edit = LineEdit.new()
	python_path_edit.placeholder_text = "python (自动检测)"
	python_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	python_hbox.add_child(python_path_edit)
	
	var python_browse_btn = Button.new()
	python_browse_btn.text = "浏览"
	python_browse_btn.pressed.connect(_on_browse_python_path)
	python_hbox.add_child(python_browse_btn)
	
	# 输入路径
	var input_group = VBoxContainer.new()
	path_group.add_child(input_group)
	
	var input_label = Label.new()
	input_label.text = "Excel文件输入路径:"
	input_group.add_child(input_label)
	
	var input_hbox = HBoxContainer.new()
	input_group.add_child(input_hbox)
	
	input_path_edit = LineEdit.new()
	input_path_edit.placeholder_text = "res://addons/py_excel_tool/data/"
	input_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_hbox.add_child(input_path_edit)
	
	var input_browse_btn = Button.new()
	input_browse_btn.text = "浏览"
	input_browse_btn.pressed.connect(_on_browse_input_path)
	input_hbox.add_child(input_browse_btn)
	
	# 输出路径
	var output_group = VBoxContainer.new()
	path_group.add_child(output_group)
	
	var output_label = Label.new()
	output_label.text = "JSON文件输出路径:"
	output_group.add_child(output_label)
	
	var output_hbox = HBoxContainer.new()
	output_group.add_child(output_hbox)
	
	output_path_edit = LineEdit.new()
	output_path_edit.placeholder_text = "res://data/generated/"
	output_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output_hbox.add_child(output_path_edit)
	
	var output_browse_btn = Button.new()
	output_browse_btn.text = "浏览"
	output_browse_btn.pressed.connect(_on_browse_output_path)
	output_hbox.add_child(output_browse_btn)
	
	# 操作按钮区域
	main_vbox.add_child(HSeparator.new())
	
	var button_hbox = HBoxContainer.new()
	main_vbox.add_child(button_hbox)
	
	convert_button = Button.new()
	convert_button.text = "开始转换"
	convert_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	convert_button.pressed.connect(_on_convert_pressed)
	button_hbox.add_child(convert_button)
	
	var settings_btn = Button.new()
	settings_btn.text = "设置"
	settings_btn.pressed.connect(_on_settings_pressed)
	button_hbox.add_child(settings_btn)
	
	# 进度条
	progress_bar = ProgressBar.new()
	progress_bar.visible = false
	main_vbox.add_child(progress_bar)
	
	# 状态标签
	status_label = Label.new()
	status_label.text = "就绪"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(status_label)
	
	# 日志输出区域
	main_vbox.add_child(HSeparator.new())
	
	var log_label = Label.new()
	log_label.text = "转换日志:"
	main_vbox.add_child(log_label)
	
	log_output = TextEdit.new()
	log_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_output.editable = false
	log_output.placeholder_text = "转换日志将在此处显示..."
	main_vbox.add_child(log_output)
	
	# 清除日志按钮
	var clear_log_btn = Button.new()
	clear_log_btn.text = "清除日志"
	clear_log_btn.pressed.connect(_on_clear_log)
	main_vbox.add_child(clear_log_btn)

func _load_settings():
	"""加载设置"""
	python_path_edit.text = ProjectSettings.get_setting("excel_converter/python_path", "")
	input_path_edit.text = ProjectSettings.get_setting("excel_converter/input_path", "")
	output_path_edit.text = ProjectSettings.get_setting("excel_converter/output_path", "")

func _save_settings():
	"""保存设置"""
	ProjectSettings.set_setting("excel_converter/python_path", python_path_edit.text)
	ProjectSettings.set_setting("excel_converter/input_path", input_path_edit.text)
	ProjectSettings.set_setting("excel_converter/output_path", output_path_edit.text)
	ProjectSettings.save()

func _on_convert_pressed():
	"""转换按钮点击事件"""
	_save_settings()
	
	convert_button.disabled = true
	progress_bar.visible = true
	status_label.text = "正在转换..."
	
	_add_log("开始Excel转换...")
	
	var input_path = input_path_edit.text
	var output_path = output_path_edit.text
	
	# 在线程中执行转换
	var thread = Thread.new()
	thread.start(_convert_thread.bind([input_path, output_path]))

func _convert_thread(paths: Array):
	"""转换线程函数"""
	var input_path = paths[0]
	var output_path = paths[1]
	
	var success = converter.execute_conversion(input_path, output_path)
	
	# 回到主线程更新UI
	call_deferred("_on_conversion_finished", success)

func _on_conversion_finished(success: bool):
	"""转换完成回调"""
	convert_button.disabled = false
	progress_bar.visible = false
	
	if success:
		status_label.text = "转换成功！"
		_add_log("Excel转换成功完成！")
	else:
		status_label.text = "转换失败"
		_add_log("Excel转换失败，请检查设置和文件路径")

func _add_log(message: String):
	"""添加日志"""
	var timestamp = Time.get_datetime_string_from_system()
	var log_line = "[%s] %s\n" % [timestamp, message]
	log_output.text += log_line
	log_output.scroll_vertical = log_output.get_v_scroll_bar().max_value

func _on_clear_log():
	"""清除日志"""
	log_output.text = ""

func _on_browse_python_path():
	"""浏览Python路径"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.current_dir = OS.get_environment("PATH").split(";")[0] if OS.has_feature("windows") else "/usr/bin"
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.file_selected.connect(_on_python_path_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_python_path_selected(path: String):
	"""Python路径选择完成"""
	python_path_edit.text = path

func _on_browse_input_path():
	"""浏览输入路径"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.current_dir = ProjectSettings.globalize_path("res://")
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.dir_selected.connect(_on_input_path_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_input_path_selected(path: String):
	"""输入路径选择完成"""
	input_path_edit.text = path

func _on_browse_output_path():
	"""浏览输出路径"""
	var file_dialog = EditorFileDialog.new()
	file_dialog.current_dir = ProjectSettings.globalize_path("res://")
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.dir_selected.connect(_on_output_path_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_output_path_selected(path: String):
	"""输出路径选择完成"""
	output_path_edit.text = path

func _on_settings_pressed():
	"""设置按钮点击事件"""
	_save_settings()
	_add_log("设置已保存")