extends Node2D

var enemies = []
var mutex
var thread


# The thread will start here.
func _ready():
	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(self, "_thread_function")


# Increment the value from the thread, too.
func _thread_function(userdata):
	while true:
		mutex.lock()
		enemies = self.get_children()
		mutex.unlock()
		for enemy in enemies:
			if enemy.visible: enemy.behavior.run(1)

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread.wait_to_finish()
