import serial
import io
import time

ser = serial.Serial('/dev/cu.usbserial-DA01OKUU', 19200)
#ser.open()

data = bytearray()
for i in range(0, 49):
    data.append(i*5)

while True:
    print ''.join(format(x, '02x') for x in data)
    ser.write(data)
    ser.write(bytearray.fromhex('ff'))
    first = data.pop(0)
    data.append(first)
    time.sleep(0.1)
