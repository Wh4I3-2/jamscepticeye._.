class_name SceneTransition
extends Resource

enum Type {
    FADE,
    LEFT_TO_RIGHT,
    RIGHT_TO_LEFT,
    TOP_TO_BOTTOM,
    BOTTOM_TO_TOP,
}

const FADE:          Type = Type.FADE
const LEFT_TO_RIGHT: Type = Type.LEFT_TO_RIGHT
const RIGHT_TO_LEFT: Type = Type.RIGHT_TO_LEFT
const TOP_TO_BOTTOM: Type = Type.TOP_TO_BOTTOM
const BOTTOM_TO_TOP: Type = Type.BOTTOM_TO_TOP

@export var time:            float
@export var type:            Type
@export var transition_type: Tween.TransitionType
@export var ease_type:       Tween.EaseType

@warning_ignore("shadowed_variable")
static func of(time: float, type: Type, transition_type: Tween.TransitionType, ease_type: Tween.EaseType) -> SceneTransition:
    var instance := SceneTransition.new()

    instance.time = time
    instance.type = type
    instance.transition_type = transition_type
    instance.ease_type = ease_type

    return instance
