# output = system.exec_command("date "+%Y-%m-%d"")
# keyboard.send_keys(output)

commandstr="date '+%H-%M-%S'"
output = system.exec_command("date '+%H:%M:%S'")
keyboard.send_keys(output)
