@tool
extends RefCounted
class_name ExcelConverterCore

# Excel转换器核心类
var logger: EditorLogger

func _init():
	logger = EditorLogger.new()

func execute_conversion(input_path: String = "", output_path: String = ""):
	"""执行Excel转换"""
	logger.log_info("开始Excel转换...")
	
	# 获取设置
	var python_path = get_python_path()
	var script_path = get_script_path()
	var default_input = get_input_path()
	var default_output = get_output_path()
	
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
	
	# 执行Python脚本
	var output = []
	var exit_code = OS.execute(python_path, args, output, true, true)
	
	# 处理结果
	if exit_code == 0:
		logger.log_info("Excel转换成功完成！")
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
	"""获取Python路径"""
	var setting = ProjectSettings.get_setting("excel_converter/python_path", "")
	if setting == "":
		# 尝试常见的Python路径
		var possible_paths = ["python", "python3", "py"]
		for path in possible_paths:
			if test_python_path(path):
				return path
		return "python"  # 默认回退
	return setting

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

# 日志记录类
class EditorLogger:
	func log_info(message: String):
		print("[Excel转换器] " + message)
		
	func log_warning(message: String):
		print_rich("[color=yellow][Excel转换器] 警告: " + message + "[/color]")
		
	func log_error(message: String):
		print_rich("[color=red][Excel转换器] 错误: " + message + "[/color]")
		push_error("[Excel转换器] " + message)