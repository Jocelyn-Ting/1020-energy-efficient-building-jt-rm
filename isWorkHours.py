import numpy as np
import math

# ISWORKHOURS Outputs true if t is between 9am and 5pm on a weekday
#   t is day of the year, we assume that the year starts on a monday

def isWorkHours(t):
    w = []
    for time in t:
        evalT=math.floor(time)%7<6 and time%1 > 0.375 and time%1 < 0.7083
        w.append(evalT)
    return w