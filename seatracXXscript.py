import sqlite3
import urllib2
import socket

import time
import random

import datetime

import sys

import platform

if platform.system() == "Windows":
    class bcolors:
        HEADER = ''
        OKBLUE = ''
        OKGREEN = ''
        WARNING = ''
        FAIL = ''
        ENDC = ''
        BOLD = ''
        UNDERLINE = ''

else:
    class bcolors:
        HEADER = '\033[95m'
        OKBLUE = '\033[94m'
        OKGREEN = '\033[92m'
        WARNING = '\033[93m'
        FAIL = '\033[91m'
        ENDC = '\033[0m'
        BOLD = '\033[1m'
        UNDERLINE = '\033[4m'


# URL of where the Arduino is hosted
base_url = "http://seatrac03.dyndns-web.com:664/"
# Timeout period for each connection, otherwise the connection is closed and we create a new one
timeout_value = 5
# File where the data is stored (in the working directory)
database_file = 'data.db'

# List of sensors to check. This corresponds to both URL/sensorname, and the table name in the database
sensors = [
    "temperature",
    "humidity",
    "heat",
    "temperature2",
    "ultraviolet",
    "infrared",
    "visible",
    "pressure"
]

while(True):
    print bcolors.HEADER + "=== Fetching Sensors ===" + bcolors.ENDC

    i = 0
    while(i < len(sensors)):

        print "Fetching Sensor : " + bcolors.OKBLUE + sensors[i] + bcolors.ENDC

        try:
            random_number_str = str(random.randint(0,99999))
            sensor_value = urllib2.urlopen(base_url + sensors[i]  + "?random=" + random_number_str, timeout=timeout_value).read()
            sensor_value = sensor_value.strip(' \t\n\r')

            print "Value           : " + bcolors.OKGREEN + sensor_value + bcolors.ENDC

            con = None
            con = sqlite3.connect(database_file)

            j = 0
            while(j < 3):
                try:
                    with con:

                        sys.stdout.write("Saving........... ")
                        sys.stdout.flush()

                        cur = con.cursor()
                        timestamp = datetime.datetime.now()
                        # print str(timestamp)
                        # print("INSERT INTO "+ sensors[i] +" VALUES(" + str(timestamp) + ", " + sensor_value +")")
                        cur.execute("INSERT INTO " + sensors[i] + " VALUES(\"" + str(timestamp) + "\", " + sensor_value + ")")
                        print bcolors.OKGREEN + "Saved" + bcolors.ENDC
                        break
                except Exception as error:
                    print bcolors.WARNING + str(error) + bcolors.ENDC
                    j += 1
            
            if( j == 3):
                print bcolors.FAIL + "=== DATA NOT SAVED ===" + bcolors.ENDC

        except socket.timeout, err:
            print bcolors.FAIL + "Timeout" + bcolors.ENDC
            i -= 1
        except urllib2.URLError, err:
            print bcolors.FAIL + "URL Error" + bcolors.ENDC
            print(err.reason)
            i -= 1
        except Exception as err:
            print err
            i -= 1
        finally:
            try:
                sf.close()
            except NameError: 
                pass
        time.sleep(2)

        i += 1

    print bcolors.HEADER + "=== Sensors Fetched, Sleeping ===" + bcolors.ENDC

    time.sleep(30)
