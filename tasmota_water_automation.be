import json

var LOWER_LIMIT = 135   # Water level limit, when to shut down main house pump
var UPPER_LIMIT = 26    # Water level limit, when to shut down the feeding pump
var EMPTY_LEVEL = 145   # Water level when the tank is completely empty
var FILL_LIMIT = 40     # Water level limit, when to START the feeding pump
var PRESSURE_LIMIT_L = 1000 # Pressure sensor lower limit - under limit, we shut down the feeding pump to prevent dry run
var PRESSURE_LIMIT_H = 2000 # Pressure sensor higher limit - above the limit, we shut down the feeding pump
                            #  to prevent over pressurizing of the pipes by running against the closed valve
var FEED_PUMP_CH = 1    # Channel number for the Feed pump
var MAIN_PUMP_CH = 0    # Channel number for the Main pump
var OVERRIDE_CH = 2

# Retrieves the water level sensor value in cm.
def get_SR04()
  var sensors=json.load(tasmota.read_sensors())
  return real(sensors['SR04']['Distance'])
end

# Retrieves the pressure sensor value. No units. ~ 1000 means the pump is pushing the water.
# Anything below 1000 means the pump runs dry.
def get_ADC1()
  var sensors=json.load(tasmota.read_sensors())
  return real(sensors['ANALOG']['A1'])
end

# Check the pressure at the feed pump level.
# If under the limit, switch off the pump
def check_pressure()
  print("Verifying the pressure")
  var pressurelevel = get_ADC1()
  if (pressurelevel < PRESSURE_LIMIT_L)
    tasmota.set_power(1,false)
  end
end


def fill_water(power)
  print("Switching on the Feed Pump") 
  tasmota.set_power(FEED_PUMP_CH,true)
  tasmota.set_timer(5000, check_pressure)
end

def check_fill()
  var power = tasmota.get_power()
  var waterlevel = get_SR04()
  print("Checking the water level for filling")
  if (!power[FEED_PUMP_CH] && waterlevel > FILL_LIMIT)
    fill_water(power) print("Water tank on lower limit (" , waterlevel, " cm)")
  end

end

def feed_off()
  print("Turnign off the feed pump")
  tasmota.set_power(FEED_PUMP_CH,false)
end

def daily_spin()
  print("---Daily Spin---")
  var power=tasmota.get_power()
  if (!power[FEED_PUMP_CH])
    tasmota.set_power(FEED_PUMP_CH,true)
    print("Running timer")
    tasmota.set_timer(5000,feed_off)
  end
end

def safety_check()
  var waterlevel = get_SR04()
  var pressurelevel = get_ADC1()
  var power = tasmota.get_power()
  print("---SAFETY CHECK---")
  print("Water level (cm): ", waterlevel, ", Feeding line pressure: ", pressurelevel, ", Pressure min. limit: ", PRESSURE_LIMIT_L)
  print("Feeding Pump status: ", power[FEED_PUMP_CH], ", upper level limit(cm): ", UPPER_LIMIT, ", Feeding treshold (cm): ", FILL_LIMIT )
  print("House Pump status: ", power[MAIN_PUMP_CH], ", lower level limit(cm): ", LOWER_LIMIT)

  # Turn off the feed pump when the tank level reaches the UPPER_LIMIT
  if (power[FEED_PUMP_CH] && waterlevel < UPPER_LIMIT)
    tasmota.set_power(FEED_PUMP_CH,false)
    print("Water tank full, switching off the Feed Pump")
  end

  # Turn off the feed pump, if the pressure drops below the PRESSURE_LIMIT_L to prevent the dry run
  # OR Turn off the feed pump, if the pressure is too high (water tank valve closed)
  if (power[FEED_PUMP_CH] && pressurelevel < PRESSURE_LIMIT_L || pressurelevel > PRESSURE_LIMIT_H)  
    tasmota.set_power(FEED_PUMP_CH,false)
    print("No pressure in the water pipe, switching off the Feed Pump")
  end
  
  # Turn off the House main pump, if the water level is too low. Can be overriden with button switch 3 - OVERRIDE_CH
  # waterlevel < EMPTY_LEVEL is a condition to prevent main pump from shutting down should the ultrasound sensor be submerged by overfilling the tank.
  if (power[MAIN_PUMP_CH] && !power[OVERRIDE_CH] && waterlevel > LOWER_LIMIT && waterlevel < EMPTY_LEVEL)
    tasmota.set_power(MAIN_PUMP_CH,false)
    print("Water tank empty, switching off the House Pump")
  end
end

tasmota.add_cron("*/5 * * * * *",safety_check, "safety_check")  # Every 5 seconds, do the routine safety checks to prevent dry run, over pressure
tasmota.add_cron("0 * * * *", check_fill, "check_fill")       # Every 1h, try to fill the water tank using the feed pump
tasmota.add_cron("0 1 * * *", daily_spin, "daily_spin")       # Every day at night, spin the pump for 5s in case the pump is stalled to prevent the motor to get "stick"