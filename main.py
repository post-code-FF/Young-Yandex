import psutil, json

def process_info():
    proc = psutil.Process()
    proc_info = {
        "pid":proc.pid,
        "name":proc.name(),
        "exe":proc.exe(),
        "memory_rss":str(round(proc.memory_info().rss / (1024 ** 2), 2)) + "Мб",
        "num_fds":proc.num_fds()
    }
    return proc_info

def hardware_info():
    with open("/proc/cpuinfo") as f:
        for line in f:
            if "model name" in line:
                cpu_model =  line.strip().split(":")[1].strip()
                break

    mem = psutil.virtual_memory().total / (1024 ** 3)

    usage = psutil.disk_usage('/')

    return {
        "cpu_model": cpu_model,
        "ram_total_gb": str(round(mem, 2)) + "Гб",
        "disk": {
            "total_gb":str(round(usage.total / (1024 ** 3), 2)) + "Гб",
            "used_gb":str(round(usage.used / (1024 ** 3), 2)) + "Гб",
            "free_gb": str(round(usage.free / (1024 ** 3), 2)) + "Гб",
            "percent_used": str(usage.percent) + "%"
        }
    }

print(json.dumps(process_info(), indent=4, ensure_ascii=False) + "\n")
print(json.dumps(hardware_info(),indent=4, ensure_ascii=False))

