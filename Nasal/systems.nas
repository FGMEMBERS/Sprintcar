# =====
# Written by Herbert Wagner
# =====

beacon_switch = props.globals.getNode("controls/switches/indicator-left", 2);
var beacon = aircraft.light.new( "/sim/model/lights/indicator-left", [0.8, 0.5], "/controls/lighting/indicator-left" );
beacon_switch = props.globals.getNode("controls/switches/indicator-right", 2);
var beacon = aircraft.light.new( "/sim/model/lights/indicator-right", [0.8, 0.5], "/controls/lighting/indicator-right" );


###########################################################################
var min_carrier_alt = 2;

# Do terrain modelling ourselves.
setprop("/sim/fdm/surface/override-level", 1);

terrain_survol = func {

var lat = getprop("/position/latitude-deg");
var lon = getprop("/position/longitude-deg");
var info = geodinfo(lat, lon);




 if (info != nil) {
    if (info[0] != nil){
       setprop("/fdm/jsbsim/environment/terrain-hight",info[0]);

#var terrain_hight = info[0];
#print("TERRAIN ",terrain_hight);

      
    }
    if (info[1] != nil){
      if (info[1].solid !=nil){
        setprop("/fdm/jsbsim/environment/terrain-undefined",0);
        setprop("/fdm/jsbsim/environment/terrain-solid",info[1].solid);

#var solid = info[1].solid;
#print("SOLID ",solid);

    }
      if (info[1].light_coverage !=nil)
       setprop("/fdm/jsbsim/environment/terrain-light-coverage",info[1].light_coverage);
      if (info[1].load_resistance !=nil)
       setprop("/fdm/jsbsim/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
       setprop("/fdm/jsbsim/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
       setprop("/fdm/jsbsim/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
       setprop("/fdm/jsbsim/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
       setprop("/fdm/jsbsim/environment/terrain-names",info[1].names[0]);

#unfortunately when on carrier the info[1]  is nil,  only info[0] is valid
#var terrain_name = info[1].names[0];
#print("NAME ",terrain_name);
      #if (terrain_name == "Ocean" and terrain_hight >  min_carrier_alt)
        #setprop("fdm/jsbsim/environment/terrain-oncarrier",1);
    }else{
setprop("/fdm/jsbsim/environment/terrain-undefined",1);
}
	      #debug.dump(geodinfo(lat, lon));


  }else {
    setprop("/fdm/jsbsim/environment/terrain-hight",0);
    setprop("/fdm/jsbsim/environment/terrain-solid",1);
    setprop("/fdm/jsbsim/environment/terrain-oncarrier",0);
    setprop("/fdm/jsbsim/environment/terrain-light-coverage",1);
    setprop("/fdm/jsbsim/environment/terrain-load-resistance",1e+30);
    setprop("/fdm/jsbsim/environment/terrain-friction-factor",1);
    setprop("/fdm/jsbsim/environment/terrain-bumpiness",0);
    setprop("/fdm/jsbsim/environment/terrain-rolling-friction",0.02);
    setprop("/fdm/jsbsim/environment/terrain-names","unknown");
    }

settimer (terrain_survol, 0.5);
}


terrain_survol();



setlistener("/fdm/jsbsim/environment/terrain-friction-factor", func { 
  
  if (getprop("/fdm/jsbsim/environment/terrain-friction-factor") > 0.7)
  {
          setprop("/fdm/jsbsim/environment/terrain-friction-factor", 0.8)
  }  
}
);

setlistener("/fdm/jsbsim/environment/terrain-rolling-friction", func { 
  
  if (getprop("/fdm/jsbsim/environment/terrain-rolling-friction") > 0.5)
  {
          
	  setprop("/fdm/jsbsim/environment/terrain-rolling-friction", 0.25)
  }  
}
);

##############################################################################
setlistener("/controls/flight/elevator", func (position){
    var position = position.getValue();
    # helper for braking
    var ms = getprop("/devices/status/mice/mouse/mode") or 0;
    if (ms == 1 and position < 0) {
        setprop("/controls/gear/brake-left", 1);
        setprop("/controls/gear/brake-right", 1);
    }
    var ms = getprop("/devices/status/mice/mouse/mode") or 0;
    if (ms == 1 and position > 0) {
        setprop("/controls/gear/brake-left", 0);
        setprop("/controls/gear/brake-right", 0);
    }
    
    # helper for throtte on throttle axis or elevator
    var se = getprop("/controls/engines/engine/throttle") or 0;
    if (ms == 1 and position >= 0) setprop("/controls/engines/engine/throttle", position*1);
},0,1);

####################################################################
setlistener("/fdm/jsbsim/systems/crash-detect/crashed-cmd", func { 
  
  if (getprop("/fdm/jsbsim/systems/crash-detect/crashed-cmd") > 0.95)
  {
          
	  setprop("/fdm/jsbsim/simulation/reset", 1)
  }  
}
);