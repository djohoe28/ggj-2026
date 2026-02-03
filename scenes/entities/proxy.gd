extends CanvasItem

@export var target_viewport_path: NodePath

var _vp: Node = null
var _proxy: CanvasItem = null

func _ready() -> void:
	_create_viewport_proxy()
	set_process(true)

func _exit_tree() -> void:
	_remove_proxy()

func _create_viewport_proxy() -> void:
	# if no viewport path provided, skip proxying
	if target_viewport_path == null:
		_vp = null
		return
	var root = get_tree().get_root()
	_vp = root.get_node_or_null(target_viewport_path)
	if not _vp:
		# viewport not found at the path — skip proxying
		_vp = null
		return

	# minimal proxy: duplicate and add to viewport, no position mapping
	_proxy = duplicate()
	if _proxy.get_script() != null:
		_proxy.set_script(null)
	_vp.add_child(_proxy)


func _process(_delta: float) -> void:
	if _proxy and _vp:
		if 'global_transform' in self:
			var local_t = _vp.get_canvas_transform().affine_inverse() * get_global_transform()
			_proxy.transform = local_t
		_proxy.visible = true

func _remove_proxy() -> void:
	# restore and free only if proxy existed
	if _proxy:
		visible = true
		_proxy.queue_free()
		_proxy = null
	_vp = null
