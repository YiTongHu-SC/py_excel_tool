extends EditorScript

# Excel转换器功能测试脚本
# 在Godot编辑器中运行: 工具 -> 执行脚本

func _run():
	print("=== Excel转换器插件功能测试 ===")
	
	# 测试ExcelConverterCore
	test_converter_core()
	
	# 测试配置读取
	test_settings()
	
	print("=== 测试完成 ===")

func test_converter_core():
	print("\n1. 测试ExcelConverterCore...")
	
	var converter = ExcelConverterCore.new()
	
	# 测试路径获取
	print("Python路径: ", converter.get_python_path())
	print("脚本路径: ", converter.get_script_path())
	print("输入路径: ", converter.get_input_path())
	print("输出路径: ", converter.get_output_path())
	
	# 测试GDScript相关设置
	print("启用GDScript生成: ", converter.get_enable_gdscript_generation())
	print("GDScript输出路径: ", converter.get_gdscript_output_path())
	print("基础资源路径: ", converter.get_base_resource_path())

func test_settings():
	print("\n2. 测试项目设置...")
	
	# 显示当前所有Excel转换器相关设置
	var settings = [
		"excel_converter/python_path",
		"excel_converter/input_path",
		"excel_converter/output_path",
		"excel_converter/enable_gdscript_generation",
		"excel_converter/gdscript_output_path",
		"excel_converter/base_resource_path",
		"excel_converter/auto_convert",
		"excel_converter/show_notifications",
		"excel_converter/verbose_logging"
	]
	
	for setting in settings:
		var value = ProjectSettings.get_setting(setting, "未设置")
		print("  ", setting, ": ", value)
	
	# 测试设置默认值
	print("\n  测试设置默认值...")
	if not ProjectSettings.has_setting("excel_converter/enable_gdscript_generation"):
		ProjectSettings.set_setting("excel_converter/enable_gdscript_generation", false)
		print("  已设置默认值: enable_gdscript_generation = false")
	
	if not ProjectSettings.has_setting("excel_converter/gdscript_output_path"):
		ProjectSettings.set_setting("excel_converter/gdscript_output_path", "res://scripts/generated/")
		print("  已设置默认值: gdscript_output_path = res://scripts/generated/")
	
	if not ProjectSettings.has_setting("excel_converter/base_resource_path"):
		ProjectSettings.set_setting("excel_converter/base_resource_path", "res://scripts")
		print("  已设置默认值: base_resource_path = res://scripts")
	
	ProjectSettings.save()
	print("  设置已保存到项目文件")