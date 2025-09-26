# example/game_data_loader/data_loader_example.gd
## 示例数据加载类，由Excel工具自动生成
class_name GameDataLoader

## 引入数据类
const TestExampleData = preload("res://path/to/test_example_data.gd")
var test_example_data_dict :Dictionary[int, TestExampleData] = {}

## 加载数据
func load_data():
	## 这里处理具体的数据加载逻辑
	pass
