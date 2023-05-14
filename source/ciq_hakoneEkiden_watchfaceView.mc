import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class ciq_hakoneEkiden_watchfaceView extends WatchUi.WatchFace {
	private var bgbitmap = null;
	private var fontTime = null;
	private var fontBattery = null;
	private var fontBatteryIcons = null;
	private var fontDate = null;
	private var fontSteps = null;
	private var fontStepsIcons = null;
	private var stats = null;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
		// '$.Toybox.Application.AppBase.getProperty' is deprecated
        // switch (Application.getApp().getProperty("BGMode")) {
		switch (Application.Properties.getValue("BGMode")) {
        	case 0:
        		bgbitmap = WatchUi.loadResource(Rez.Drawables.id_hakone);
        		break;
        	case 1:
        		bgbitmap = WatchUi.loadResource(Rez.Drawables.id_hakone_dt);
        		break;
        	case 2:
        		bgbitmap = WatchUi.loadResource(Rez.Drawables.id_hakone_tt);
        		break;
        	default:
        		bgbitmap = WatchUi.loadResource(Rez.Drawables.id_hakone_ep);
        }
    	    
        fontTime = WatchUi.loadResource(Rez.Fonts.time);
        fontBattery = WatchUi.loadResource(Rez.Fonts.battery);
        fontBatteryIcons = WatchUi.loadResource(Rez.Fonts.batteryIcons);
        fontDate = WatchUi.loadResource(Rez.Fonts.date);
        fontSteps = WatchUi.loadResource(Rez.Fonts.steps);
        fontStepsIcons = WatchUi.loadResource(Rez.Fonts.stepsIcons);
    }

    // Called when this View is brought to the foreground. Restore the state of this View and prepare it to be shown. This includes loading resources into memory.
    function onShow() as Void {
    }

    function onUpdate(dc) as Void {
		dc.clear();
        
        var halfwidth = dc.getWidth()/2;
        var halfheight = dc.getHeight()/2;
        
	    dc.drawBitmap(halfwidth - (bgbitmap.getWidth()/2), halfheight - (bgbitmap.getHeight()/2), bgbitmap);
	    
	    if (Application.Properties.getValue("Date")) {
		    var gregorian = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		    var date = null;
		    if (Application.Properties.getValue("DateYear") > 1) {
		    	date = Lang.format("$1$ $2$", [gregorian.day, gregorian.month.toUpper()]);
		    } else {
		    	var year = gregorian.year;
		    	if (Application.Properties.getValue("DateYear") > 0) {
				    year = year.toString().substring(2, 4);
				}
				date = Lang.format("$1$ $2$ $3$", [gregorian.day, gregorian.month.toUpper(), year]);
			}
		    //var date = Lang.format("$1$ $2$ $3$", [gregorian.day, gregorian.month.toUpper(), year]);
	    	dc.setColor(Application.Properties.getValue("DateColor"), Graphics.COLOR_TRANSPARENT);
	    	dc.drawText(halfwidth, halfheight - Math.ceil(halfheight/1.333), fontDate, date, Graphics.TEXT_JUSTIFY_CENTER);
	    }
	    
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var halfwidthoffset = halfwidth/30;
        var halfheightwithoffset = halfheight - 80;
        dc.setColor(Application.Properties.getValue("HoursColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(halfwidth - halfwidthoffset, halfheightwithoffset, fontTime, hours.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Application.Properties.getValue("MinutesColor"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(halfwidth + halfwidthoffset, halfheightwithoffset, fontTime, Lang.format("$1$", [clockTime.min.format("%02d")]), Graphics.TEXT_JUSTIFY_LEFT);
        
        var steps = ActivityMonitor.getInfo().steps;
        if (Application.Properties.getValue("Steps") && steps != null) {
        	var fontStepsbase = 13 + 1;
        	var stepswidthoffset = ((fontStepsbase*steps.toString().length())*0.5) + fontStepsbase;
        	var connecticonsoffset = 17*0.5;
        	var stepsheight = halfheight + Math.ceil(halfheight/2.25);
        	dc.setColor(Application.Properties.getValue("StepsColor"), Graphics.COLOR_TRANSPARENT);
        	dc.drawText(halfwidth - (stepswidthoffset - connecticonsoffset), stepsheight - 4, fontStepsIcons, "0", Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(halfwidth + connecticonsoffset, stepsheight, fontSteps, steps.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        if (Application.Properties.getValue("BatteryStatus")) {
        	stats = System.getSystemStats();

        	//var batterylife = Lang.format("$1$", [stats.battery.format("%01d")]);
        	var batterylife = stats.battery;
			//var batterylifex = 70.0;
			//batterylife = batterylifex.toFloat();
			var batterylifestr = batterylife.format("%01d").toString();

        	var fontBatterybase = 25 + 1;
        	var batterylifewidthoffset = ((fontBatterybase*batterylifestr.length())*0.5) + (fontBatterybase*0.5);
        	var connecticonsoffset = 26*0.5;
        	var batterylifeheight = halfheight + Math.ceil(halfheight/1.5);

			var batterycolor = Application.Properties.getValue("BatteryColor");
			var batterylifecolor = batterycolor;
			var batteryrainbowmode = Application.Properties.getValue("BatteryRainbowMode");
			if (batteryrainbowmode) {
				//var batteryrainbowcolors = [0xFF0000, 0xFF5500, 0xFFAA00, 0x00AA00, 0x00FF00, 0x00AAFF];
				var batteryrainbowcolors = [0xFF0000, 0xFF5500, 0xFFAA00, 0x00FF00, 0x00AAFF, 0xFF00FF];

				if (batteryrainbowmode == 1) {
					batteryrainbowcolors[3] = batterylifecolor;
					batteryrainbowcolors[4] = batterylifecolor;
				}

				var batteryindex = Math.floor(batterylife/20).toNumber();
				//System.println(batteryindex);
				batterycolor = batteryrainbowcolors[batteryindex];
			}
			dc.setColor(batterycolor, Graphics.COLOR_TRANSPARENT);
        	dc.drawText(halfwidth - (batterylifewidthoffset - connecticonsoffset), batterylifeheight - 6, fontBatteryIcons, "0", Graphics.TEXT_JUSTIFY_CENTER);
			dc.setColor(batterylifecolor, Graphics.COLOR_TRANSPARENT);
        	dc.drawText(halfwidth + connecticonsoffset, batterylifeheight, fontBattery, batterylifestr, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the state of this View here. This includes freeing resources from memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }
}
