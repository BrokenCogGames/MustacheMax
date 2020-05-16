extends CanvasLayer

var current_time = 0
var start_time = 0
var running = false
var last_tick = 0

enum TimeFormat {
	FORMAT_HOURS   = 1 << 0,
	FORMAT_MINUTES = 1 << 1,
	FORMAT_SECONDS = 1 << 2,
	FORMAT_MILLISECONDS = 1 << 3
}

func _ready():
	$TimerLbl.visible = GameController.speed_run_clock_enabled

func format_time(time, format = TimeFormat.FORMAT_MINUTES | TimeFormat.FORMAT_SECONDS | TimeFormat.FORMAT_MILLISECONDS, digit_format = "%02d"):
	var digits = []
	
	if format & TimeFormat.FORMAT_HOURS:
		var hours = digit_format % [time / 3600000]
		digits.append(hours)

	if format & TimeFormat.FORMAT_MINUTES:
		var minutes = digit_format % [floor((time / 1000) / 60)]
		digits.append(minutes)

	if format & TimeFormat.FORMAT_SECONDS:
		var seconds = digit_format % [(time / 1000) % 60]
		digits.append(seconds)
		
	if format & TimeFormat.FORMAT_MILLISECONDS:
		var milliseconds = digit_format % [(int(ceil(time)) % 1000) / 10]
		digits.append(milliseconds)
		
	var formatted = String()
	var colon = ":"

	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)

	return formatted

func start():
	start_time = OS.get_ticks_msec()
	running = true
	
func stop():
	running = false
	
func _process(delta):
	if running:
		if OS.get_ticks_msec() > last_tick:
			last_tick = OS.get_ticks_msec()
			$TimerLbl.text = format_time(last_tick - start_time)
