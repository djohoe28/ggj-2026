extends Resource
class_name TweenProperties

@export var duration: float
@export var ease_type: Tween.EaseType
@export var transition_type: Tween.TransitionType

func _init(p_duration: float = 0.15, p_ease_type: Tween.EaseType = Tween.EASE_OUT, p_transition_type: Tween.TransitionType = Tween.TRANS_QUINT) -> void:
	duration = p_duration
	ease_type = p_ease_type
	transition_type = p_transition_type