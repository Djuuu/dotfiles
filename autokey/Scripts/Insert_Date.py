# output = system.exec_command("date "+%Y-%m-%d"")
# keyboard.send_keys(output)

commandstr="date '+%Y-%m-%d'"
output = system.exec_command(commandstr)
keyboard.send_keys(output)
