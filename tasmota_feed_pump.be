var LOWER_LIMIT = 125
var UPPER_LIMIT = 26
var FILL_LIMIT = 60

def check_lower_level()
  

end

def check_water_levels()
  import json
  var sensors=json.load(tasmota.read_sensors())
  var d = real(sensors['SR04']['Distance'])
  print("DST: ", d)

  var power = tasmota.get_power()
  print("Feeding Pump status: ",power[1], ", configured upper limit: ", UPPER_LIMIT)
  print("House Pump status: ",power[0], ", configured upper limit: ", LOWER_LIMIT)

  if (power[1] && d < UPPER_LIMIT) tasmota.set_power(1,false) print("Water tank full, switching off the Feed Pump") end
  if (power[0] && d > UPPER_LIMIT) tasmota.set_power(1,false) print("Water tank empty, switching off the House Pump") end


end

#tasmota.add_cron("*/5 * * * * *",check_level,"check_level")