/******* UC4 setup for NTMI:

- top 4 knobs  		change slots volume / relative
- top 4 hat-buttons toggle sound slots on/off

- lower 4 knobs:
--					scroll thru presets
-- 					if hat held down, scroll thru sounds

- 8 sliders: 		influx!

- xfader:           masterVol via limDrive

- bot buts 1 2 3:	rand, prev, next influx preset
- bot but  5:		snapshot presets
- bot buts 6 7 8:	rand, prev, next MasterFX preset

- ( bot but  4 still unused ;-)


***********/
// to switch encoders to relative: on the device, select grp1,
// then go into edit mode: hold \shift, press \edit_setup
// select enc1 on knob 1, change ctlmode to Ccr2,
// hold until running bars go away -> all encoders are now relative

MKtlDesc.loadDescs;
g.uc4.free; g.uc4 = MKtl(\uc4, "*uc4_pg");

// modify labels:
g.uc4.elAt(\pgKn1, \kn, (0..3)).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
g.uc4.elAt(\pgKn1, \pbt, (0..3)).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

g.uc4.elAt(\pgKn1, \kn, (4..7)).do { |el, i| el.elemDesc.label = "select".format(i+1) };
g.uc4.elAt(\pgKn1, \pbt, (4..7)).do { |el, i| el.elemDesc.label = "^-pre v-snd".format(i+1) };

g.uc4.elAt(\pgSl1, \sl).do { |sl, i| sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs };

g.uc4.elAt(\xfader).elemDesc.label = "Main Vol";

g.uc4.elAt(\pgSl1, \bt, 0).elemDesc.label = "rand inph";
g.uc4.elAt(\pgSl1, \bt, 1).elemDesc.label = "prev inph";
g.uc4.elAt(\pgSl1, \bt, 2).elemDesc.label = "next inph";

g.uc4.elAt(\pgSl1, \bt, 3).elemDesc.label = "noch nix";
g.uc4.elAt(\pgSl1, \bt, 4).elemDesc.label = "snap pre!";

g.uc4.elAt(\pgSl1, \bt, 5).elemDesc.label = "rand MFX";
g.uc4.elAt(\pgSl1, \bt, 6).elemDesc.label = "prev MFX";
g.uc4.elAt(\pgSl1, \bt, 7).elemDesc.label = "next MFX";

// g.makeGui.uc4 = { g.uc4.gui };

// add a spec to uc4, for relative use:
// ccr2 is from 58 ... 63 down / 65 .. 70 up,
// so use this for good resolution on gui elements
g.uc4.addSpec(\knRel, [56, 72, \lin, 1, 64]);
g.uc4.elAt(\pgKn1, \kn).do(_.deviceSpec_(g.uc4.getSpec(\knRel)));

/// top 4 knobs change slots volume
g.uc4.elAt(\pgKn1, \kn, (0..3)).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		MFdef(\stepVol).(ndef, ((el.deviceValue - 64) * 0.1));
		el.deviceValue = 64;
	};
};

/// top 4 buttons toggle sound slots on/off

g.uc4.elAt(\pgKn1, \pbt, (0..3)).do { |el, i|
	el.action = { |el|
		if (el.value > 0) { q.slots.toggleAt(i) }
	};
};

// xfader is master volume before limiter
g.uc4.elAt('xfader').action = { |xf|
	// 	s.volume.volume_(\svol.asSpec.map(xf.value))
	q.mFX.pxChain.proxy.setUni(\limDrive, xf.value);
};


// normal: select next setting
// hat down: select next sound
g.uc4.elAt(\pgKn1, \kn, (4..7)).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - 64);

		if (g.uc4.elAt(\pgKn1, \pbt, (4..7)[i]).isOn) {
			// next sound
			q.slots.stepNext(i, relStep);
		} {
			// next preset
			q.stepNdefPreInf(ndef, relStep);
		};
		el.deviceValue = 64;
	}
};

// bt5, snapshots presets of all currently playing sounds
g.uc4.elAt(\pgSl1, \bt, 4).action = { |el|
	if (el.isOn) {
		MFdef(\snapshot).value;
	}
};

////////// sliders (hard-)set or SoftSet inphlux:
if (q.inphlux.respondsTo(\get).not) {
	"///////// sliders hard-set influx directly ".postln;
	g.uc4.elAt(\pgSl1, \sl).do { |sl, i|
		sl.action = { |sl|
			var name = q.inphlux.inNames[i];
			q.inphlux.set(name, sl.value.unibi)
		};
	}
} {
	///////// BETTER: SoftSet, works with current Influx update
	"//// sliders SoftSet influx ".postln;
	g.uc4.elAt(\pgSl1, \sl).do { |sl, i|
		sl.action = { |sl|
			var name = q.inphlux.inNames[i];
			SoftSet(q.inphlux, name, sl.value.unibi, lastVal: sl.prevValue.unibi);
		};
	}
};

// Left 3 bottom buttons: inphPre rand, -1, +1
g.uc4.elAt(\pgSl1, \bt, [0, 1, 2]).do { |el, i|
	el.action = { |el| if (el.value > 0) {
		MFdef(\stepInphWPre).([nil, -1, 1]@i)
	} }
};

// Right 3 bottom buttons: masterfx preset rand, -1, +1
g.uc4.elAt(\pgSl1, \bt, [5, 6, 7]).do { |el, i|
	el.action = { |el| if (el.value > 0) {
		MFdef(\mastaPreStep).([nil, -1, 1]@i)
	} }
};
