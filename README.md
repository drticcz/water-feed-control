# Water Feed Control Module

This is an ESP32 & Tasmota based modular system to control the feeding water pump that is delivering water from the remote public water pipe source to your house reservoir in case the pressure in the public pipe is not high enough or unstable.

# Block Diagrams
![High Level Diagram] (water_feed_high_level)
![Detailed diagram] (Water_feed_detailed.png)

# Electronic Modules Used

* 220-24V AC-DC power source
* DC-DC converter (24V->5V)
* DC-DC converter (5V->12V)

* ESP32 dev board

* XDB305 Pressure sensor 0-0.6Mpa, 4-20mA
* SR04 Ultrasound water level sensor

* 4-20mA Current to Voltage converter (AA684)
* Logic level shifter
* Two channel 3.3V relay module


## XDB305 Pressure to current table

| Pressure (bar) | Voltage |
| -------- | ------- |
| 6 | 2,7 |
| 5,5 | 2,6 |
| 5 | 2,3 |
| 4,5 | 2,15 |
| 4 | 1,8 |
| 3,5 | 1,58 |
| 3 | 1,3 |
| 2,5 | 1,1 |
| 2 | 0,88 |
| 1 | 0,45 |


## AA684 Current to Voltage Module
(Translated from Chinese)
### Instructions for use:

1. Supply voltage 7-36V (if the output is below 10V, the supply voltage must be greater than 12V)
1. After power on, the D2 light should be on, otherwise check the line connection. Board with reverse protection, the reverse is not burning.
1. When the current input is the minimum value (0mA or 4mA), adjust the ZERO potentiometer so that VOUT is at its minimum (0.0V or other)
1. When the current input is maximum (20mA), adjust the SPAN potentiometer so that VOUT is at its maximum (3.3V or 5V or 10V, with a minimum of 2.5V when the input is 4-20ma).


### According to your needs, select the appropriate range by jumper cap:


#### 4--20ma:   

* 0--2.5V Range: J1 1,2 feet short, 3,4 feet short
* 0--3.3V Range: J1 1,2 feet off, 3,4 feet off
* 0--5.0V Range: J1 1,2 feet shorted, 3,4 feet shorted
* 0--10.0V Range: J1 1,2 feet short, 3,4 feet off


#### 0--20ma:   

* 0--3.3V Range: J1 1,2 feet shorted, 3,4 feet shorted
* 0--5.0V Range: J1 1,2 feet shorted, 3,4 feet shorted
* 0--10.0V Range: J1 1,2 feet short, 3,4 feet off


# Sources

