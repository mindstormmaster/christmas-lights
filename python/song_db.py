import serial
import io
import time
import MySQLdb


def playSong(id, name, delay, db):
    data = bytearray()
    for i in range(10):
        data.append(0)

    cursor = db.cursor()
    query = ("SELECT id, song_id, timestamp FROM keyframes WHERE song_id = %s order by timestamp")
    cursor.execute(query, [id])

    currenttime = -4.0;
    for (id, song_id, timestamp) in cursor:
        for i in range(10):
            data[i] = 0

        led_cursor = db.cursor()
        query = ("SELECT id, keyframe_id, led_index, value FROM keyframe_leds WHERE keyframe_id = %s")
        led_cursor.execute(query, [id])
        for (id, keyframe_id, led_index, value) in led_cursor:
            data[led_index-1] = value
            for i in range(10):
                data[i] = value

        led_cursor.close()

        delay = timestamp - currenttime - 4;
        currenttime = timestamp
        time.sleep(delay/1000.0)
        ser.write(data)
        ser.write(bytearray.fromhex('ff'))
        print format(currenttime, '06d')+':  '+''.join(format(x, '02x') for x in data)
    cursor.close()


ser = serial.Serial('/dev/cu.usbserial-DA01OKUU', 38400)
#ser = serial.Serial('/dev/ttyUSB0', 19200)
#ser.open()

db = MySQLdb.connect(host='127.0.0.1', port=8306, user='root', passwd='rootpass', db='sequencer')
cursor = db.cursor()

query = ("SELECT id, name, delay FROM songs WHERE name = %s")

name = "lovedrug.mp3"

cursor.execute(query, [name])

for (id, name, delay) in cursor:
    time.sleep(400/1000.0)
    playSong(id, name, delay, db)

cursor.close()
db.close()
