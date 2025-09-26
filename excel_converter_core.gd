@tool
extends RefCounted
class_name ExcelConverterCore

# Excel转换器核心类
var logger: EditorLogger

func _init():
	logger = EditorLogger.new()

func execute_conversion(input_path: String = "", output_path: String = "", generate_gdscript: bool = false):
	"""执行Excel转换"""
	logger.log_info("开始Excel转换...")
	logger.log_info("当前python路径: %s" % get_python_path())
	
	# 获取设置
	var python_path = get_python_path()
	var script_path = get_script_path()
	var default_input = get_input_path()
	var default_output = get_output_path()
	var enable_gdscript = generate_gdscript or get_enable_gdscript_generation()
	var gdscript_output = get_gdscript_output_path()
	
	# 使用传入的路径或默认路径
	var final_input = input_path if input_path != "" else default_input
	var final_output = output_path if output_path != "" else default_output
	
	# 构建命令参数
	var args = [script_path]
	if final_input != "":
		args.append("--input")
		args.append(final_input)
	if final_output != "":
		args.append("--output")
		args.append(final_output)
	
	# 添加GDScript生成参数
	if enable_gdscript:
		args.append("--generate-gdscript")
		if gdscript_output != "":
			args.append("--gdscript-output")
			args.append(gdscript_output)
		logger.log_info("已启用GDScript脚本生成")
	
	# 更新配置文件中的base_resource_path
	if enable_gdscript:
		update_python_config()
	
	# 执行Python脚本
	var output = []
	var exit_code = OS.execute(python_path, args, output, true, true)
	
	# 处理结果
	if exit_code == 0:
		logger.log_info("Excel转换成功完成！")
		if enable_gdscript:
			logger.log_info("GDScript脚本生成完成！")
		if output.size() > 0:
			for line in output:
				logger.log_info(line)
	else:
		logger.log_error("Excel转换失败，退出代码: " + str(exit_code))
		if output.size() > 0:
			for line in output:
				logger.log_error(line)
	
	return exit_code == 0

func get_python_path() -> String:
	"""获取Python路径 (从用户本地配置获取，不使用项目设置)"""
	# 尝试从用户配置文件获取
	var config = ConfigFile.new()
	var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
	var err = config.load(config_path)
	
	var python_path = ""
	if err == OK:
		python_path = config.get_value("user_settings", "python_path", "")
	
	if python_path == "":
		# 尝试常见的Python路径
		var possible_paths = ["python", "python3", "py"]
		for path in possible_paths:
			if test_python_path(path):
				# 保存找到的路径到用户配置
				save_python_path(path)
				return path
		return "python"  # 默认回退
	else:
		# 验证保存的路径是否仍然有效
		if test_python_path(python_path):
			return python_path
		else:
			# 路径无效，重新检测
			logger.log_warning("保存的Python路径无效，重新检测...")
			var possible_paths = ["python", "python3", "py"]
			for path in possible_paths:
				if test_python_path(path):
					save_python_path(path)
					return path
			return "python"
	
func save_python_path(python_path: String):
	"""保存Python路径到用户本地配置"""
	var config = ConfigFile.new()
	var config_path = OS.get_user_data_dir() + "/excel_converter_user_config.cfg"
	
	# 尝试加载现有配置
	config.load(config_path)
	
	# 设置Python路径
	config.set_value("user_settings", "python_path", python_path)
	
	# 保存配置
	var err = config.save(config_path)
	if err == OK:
		logger.log_info("Python路径已保存到用户配置: " + python_path)
	else:
		logger.log_error("无法保存Python路径到用户配置，错误代码: " + str(err))

func test_python_path(path: String) -> bool:
	"""测试Python路径是否有效"""
	var output = []
	var exit_code = OS.execute(path, ["--version"], output, true, true)
	return exit_code == 0

func get_script_path() -> String:
	"""获取Python脚本路径"""
	var base_path = ProjectSettings.globalize_path("res://addons/py_excel_tool/src/")
	return base_path + "excel_to_json.py"

func get_input_path() -> String:
	"""获取默认输入路径"""
	var setting = ProjectSettings.get_setting("excel_converter/input_path", "")
	if setting == "":
		return ProjectSettings.globalize_path("res://addons/py_excel_tool/data/")
	return ProjectSettings.globalize_path(setting)

func get_output_path() -> String:
	"""获取默认输出路径"""
	var setting = ProjectSettings.get_setting("excel_converter/output_path", "")
	if setting == "":
		return ProjectSettings.globalize_path("res://data/generated/")
	return ProjectSettings.globalize_path(setting)

func get_enable_gdscript_generation() -> bool:
	"""获取是否启用GDScript生成"""
	return ProjectSettings.get_setting("excel_converter/enable_gdscript_generation", false)

func get_gdscript_output_path() -> String:
	"""获取GDScript输出路径"""
	var setting = ProjectSettings.get_setting("excel_converter/gdscript_output_path", "")
	if setting == "":
		return ProjectSettings.globalize_path("res://scripts/generated/")
	return ProjectSettings.globalize_path(setting)

func get_base_resource_path() -> String:
	"""获取基础资源路径配置"""
	return ProjectSettings.get_setting("excel_converter/base_resource_path", "res://scripts")

func update_python_config():
	"""更新Python配置文件中的base_resource_path"""
	var config_path = ProjectSettings.globalize_path("res://addons/py_excel_tool/src/config.ini")
	var base_path = get_base_resource_path()
	
	# 读取配置文件
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		logger.log_warning("无法打开配置文件: " + config_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# 更新base_resource_path配置
	var lines = content.split("\n")
	var updated_lines = []
	var base_path_updated = false
	
	for line in lines:
		if line.strip_edges().begins_with("base_resource_path"):
			updated_lines.append("base_resource_path = " + base_path)
			base_path_updated = true
			logger.log_info("更新base_resource_path为: " + base_path)
		else:
			updated_lines.append(line)
	
	# 如果没有找到base_resource_path配置，在[GDSCRIPT]节后添加
	if not base_path_updated:
		var gdscript_section_index = -1
		for i in range(updated_lines.size()):
			if updated_lines[i].strip_edges() == "[GDSCRIPT]":
				gdscript_section_index = i
				break
		
		if gdscript_section_index >= 0:
			updated_lines.insert(gdscript_section_index + 1, "base_resource_path = " + base_path)
			logger.log_info("添加base_resource_path配置: " + base_path)
	
	# 写回配置文件
	file = FileAccess.open(config_path, FileAccess.WRITE)
	if file == null:
		logger.log_error("无法写入配置文件: " + config_path)
		return
	
	file.store_string("\n".join(updated_lines))
	file.close()

# 日志记录类
class EditorLogger:
	func log_info(message: String):
		print("[Excel转换器] " + message)
		
	func log_warning(message: String):
		print_rich("[color=yellow][Excel转换器] 警告: " + message + "[/color]")
		
	func log_error(message: String):
		print_rich("[color=red][Excel转换器] 错误: " + message + "[/color]")
		push_error("[Excel转换器] " + message)