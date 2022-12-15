import linecache
import requests
import re


def main():

    line_num = 355000
    logs = []

    while (line_num <= 1500000):
        log = linecache.getline('./var/log/remote/wireless-encoded/wireless_10-02-2020.log', line_num)

        entered_ap = re.search("<\s(?:[0-9]{1,3}\.){3}[0-9]{1,3}>\s\s(Assoc success) @ .{17}(.{17}).+?AP.+?(?:EXT-)?((?:[A-Za-z]){3,}[^\s]+)", log)
        exited_ap = re.search("<\s(?:[0-9]{1,3}\.){3}[0-9]{1,3}>\s\s(Deauth to sta): (.{17}).+?AP.+?(?:EXT-)?((?:[A-Za-z]){3,}[^\s]+)", log)

        if (entered_ap or exited_ap):
            logs.append({'log': log})

        if (len(logs) == 500):
            res = requests.post(
                url='http://localhost:7071/api/ParseLog',
                json={'log_batch': logs}
            )
            print(res.content)
            logs.clear()
        
        line_num += 1


main()