class_name FractalLogger
extends RichTextLabel

enum LogLevel {
	NONE,
	DEBUG,
	INFO,
	WARN,
	ERROR,
}

const LOG_LEVEL_DISPLAY: Dictionary[LogLevel, String] = {
	LogLevel.DEBUG: "DEBUG  ",
	LogLevel.INFO:  "INFO   ",
	LogLevel.WARN:  "WARNING",
	LogLevel.ERROR: "ERROR  ",
}

const LOG_LEVEL_COLORS: Dictionary[LogLevel, String] = {
	LogLevel.DEBUG: "#6b558e",
	LogLevel.INFO:  "#acaade",
	LogLevel.WARN:  "#faa561",
	LogLevel.ERROR: "#f38ba8",
}

const LOG_LEVEL_TEXT_COLORS: Dictionary[LogLevel, String] = {
	LogLevel.DEBUG: "#6b6490",
	LogLevel.INFO:  "#8d90ba",
	LogLevel.WARN:  "#b68d79",
	LogLevel.ERROR: "#b3809d",
}

@export var logger_level: LogLevel = LogLevel.ERROR
@export var sender_length: int = 8

func empty() -> void:
	text += "\n"

func debug(message: String, sender: String = "") -> void:
	_log(LogLevel.DEBUG, message, sender)

func info(message: String, sender: String = "") -> void:
	_log(LogLevel.INFO, message, sender)

func warn(message: String, sender: String = "") -> void:
	_log(LogLevel.WARN, message, sender)

func error(message: String, sender: String = "") -> void:
	_log(LogLevel.ERROR, message, sender)

func _log(level: LogLevel, message: String, sender: String) -> void:
	if len(sender) > sender_length:
		sender = sender.substr(0, sender_length)

	for i in range(sender_length - len(sender)):
		sender = " %s" % sender

	var templated_message: String = "%s|[b]%s[/b]  " % [sender, LOG_LEVEL_DISPLAY.get(level)]
	text += "[color=%s]%s[/color][color=%s]%s[/color]\n" % [LOG_LEVEL_COLORS.get(level), templated_message, LOG_LEVEL_TEXT_COLORS.get(level), message]
