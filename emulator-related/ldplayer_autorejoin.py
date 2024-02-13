_A = True
import subprocess, time

adb = "C:/LDPlayer/LDPlayer9/adb.exe"
launch_times = {}
relaunch_interval = 300


def runADBCommand(command):
    try:
        return subprocess.run(f"{adb} {command}", capture_output=_A, text=_A, shell=_A)
    except Exception as e:
        print(f"Error running command '{command}': {e}")
        return


def listADB():
    r = runADBCommand("devices")
    if r and r.stdout:
        return [
            line.split("\t")[0]
            for line in r.stdout.strip().split("\n")
            if "device" in line
        ]
    else:
        return []


def closeRoblox(instance):
    print(f"Closing Roblox on {instance}...")
    runADBCommand(f"-s {instance} shell am force-stop com.roblox.client")


def launchRoblox(instance):
    print(f"Launching Roblox on {instance}...")
    runADBCommand(
        f"-s {instance} shell am start -a android.intent.action.VIEW -d roblox://placeId=8737899170"
    )
    print(f"Launched into private server using {instance}")
    launch_times[instance] = time.time()


def manageInstances():
    instances = listADB()
    for instance in instances:
        current_time = time.time()
        if (
            instance not in launch_times
            or current_time - launch_times[instance] >= relaunch_interval
        ):
            closeRoblox(instance)
            time.sleep(10)
            launchRoblox(instance)
            time.sleep(10)


runADBCommand("kill-server")
runADBCommand("start-server")
while _A:
    manageInstances()
    print("Waiting for the next relaunch cycle...")
    time.sleep(relaunch_interval)
