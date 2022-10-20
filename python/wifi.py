import re
import linecache

access_points = {}

class AccessPoint:
    def __init__(self, id):
        self.id = id
        self.count = 0
        self.devices = set()

    def push(self, device):
        if device not in self.devices:
            self.count += 1
            self.devices.add(device)

    def pop(self, device):
        if device in self.devices and self.count > 0:
            self.count -= 1
            self.devices.discard(device)

    def __str__(self):
        return f"({self.id}={self.count})"


def parse_log(str):
    entered_ap = re.search("(Assoc success) @ .{17}(.{17}).+?AP.+?(?:EXT-)?([A-Za-z]{3,}(?=\d))", str) #re.search("AP (?:EXT-)?([A-Za-z]+).+?(Assoc success) @ .{17}(.{17})", str) #re.search("(User Authentication Successful).+?MAC=(.{17}).+?AP=(?:EXT-)?([A-Za-z]+)", str)
    exited_ap = re.search("(Deauth to sta): (.{17}).+?AP.+?(?:EXT-)?([A-Za-z]{3,}(?=\d))", str) #re.search("AP (?:EXT-)?([A-Za-z]+).+?(Deauth from sta): (.{17}).+?(Reason.+)", str)

    if (entered_ap):
        ap = entered_ap[3]
        mac_address = entered_ap[2]
        if (ap not in access_points):
            access_points[ap] = AccessPoint(ap)
        access_points[ap].push(mac_address)

    elif (exited_ap):
        ap = exited_ap[3]
        mac_address = exited_ap[2]
        if (ap in access_points):
            access_points[ap].pop(mac_address)
        else:
            access_points[ap] = AccessPoint(ap)


def main():

    line_num = 1
    while (line_num <= 1000000):
        line = linecache.getline("./var/log/remote/wireless-encoded/wireless_10-02-2020.log", line_num)
        parse_log(line)

        line_num += 1
    for val in access_points.values():
        if (val.count > 0):
            print(val)

main()