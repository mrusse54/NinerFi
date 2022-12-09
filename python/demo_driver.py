import linecache
import requests
import time


def main():

    line_num = 1
    logs = []
    while (line_num <= 5000):
        log = linecache.getline('./var/log/remote/wireless-encoded/wireless_10-02-2020.log', line_num)
        logs.append({'log': log})
        line_num += 1

    res = requests.post(
            url='http://localhost:7071/api/ParseLog',
            json={'log_batch': logs}
        )
    print(res.content)

main()