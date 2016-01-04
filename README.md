# shell-utility
Some small tools for shell.

1. Locker
2. WFC (Workflow controller)

## Installation
Use "dot" to include utility.sh in your custom script.
```bash
. utility.sh
```

## Usage
### Locker
Use locker to avoid cronjob conflict. See example:

test.sh:
```bash
#!/bin/bash
lock_it
echo "Start testing"
sleep 1h
echo "End testing"
unlock_it
```
Result:
```
$ bash test.sh
Successfully lock: test.sh.lock
$ bash test.sh
Previous process exists! can't acquire lock!
```
### WFC
This tool provides convenient to control workflow for bash. While we want to execute some dependent jobs, we need some mechanism to check result of each jobs. 
Like:
```bash
$command1
if [ "$?" -ne 0  ]; then # Check result of command1
    ...
    $command2
fi
```
It shows a lot of redundant scope in code. We can save this duplicated script by simple function likes below. It also automatically records all execution results into log.

Revised version with wfc tool:
```bash
wfc "$command1"
wfc "$command2" # If it gets an incorrect result in command1, then command2 will not be executed.
```

## License
BSD License
