import serial
import io
import time

def setColors(color):
    data = bytearray()
    for i in range(50):
        data.append(color)
    print ''.join(format(x, '02x') for x in data)
    ser.write(data)
    ser.write(bytearray.fromhex('ff'))


ser = serial.Serial('/dev/cu.usbserial-DA01OKUU', 19200)
#ser.open()

data = bytearray()
for i in range(50):
    data.append(i*5)

setColors(5)
time.sleep(2000/1000.0)
time.sleep(40/1000.0)
setColors(215)
time.sleep(160/1000.0)
setColors(1)
time.sleep(2680/1000.0)
setColors(215)
time.sleep(160/1000.0)
setColors(1)
time.sleep(160/1000.0)
setColors(215)
time.sleep(2600/1000.0)
setColors(1)
time.sleep(800/1000.0)
setColors(215)
time.sleep(300/1000.0)
setColors(215)
time.sleep(8380/1000.0)
setColors(1)
