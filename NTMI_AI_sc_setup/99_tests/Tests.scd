
Tdef('zz_tests', {
	var postOK = false;
	var failCount = 0;
	t = { |func, failmess, passmess, dt = 0.1|
		if (func.value) {
			if (postOK) { (passmess ? "").postln }
		} {
			failCount = failCount + 1;
			"*** FAIL: % \n".postf(failmess);
			"code: % \n".postf(func.cs);
			try { dt.wait };
		};
	};

	"Tdef('zz_tests') runs.".postln;

	"--- GENERAL SANITY ---".postln;
	// Tdef('xoscSim').stop;
	t.({ s.serverRunning }, "server not running.", "server ok.");
	t.({ MKtl.all[\xosc].notNil }, "xosc not present.", "xosc ok.");
	t.({ MKtl.all['nanoKtl'].notNil }, "nanoKtl not present.", "nanoKtl ok.");
	t.({ MasterFX.all[s.name].notNil }, "MasterFX missing.", "MasterFX ok.");
	t.({ q.inphlux.isKindOf(Influx) }, "q.inphlux not OK.", "inphlux ok.");

	t.({ q.process.allNames.size >= 20 }, "less than 20 sounds?", "sounds ok.");
	t.({ q.osc.timeSinceLast < 1.0 }, "xosc not sending.", "xosc ok.");

	"\n --- SLOTS ---".postln;
	t.({ q.slots.actives.size == 4 }, "q.slots.actives have wrong size", "4 slots ok.");
	t.({ q.slots.test }, "q.slots and choices are wrong", "slots and choices ok.");

	t.({
		var prevSlots = q.slots.actives.copy;
		q.slots.addActive(4, Ndef(q.slots.choices[0].choose));
		prevSlots == prevSlots
	}, "q.slots.addActive failed to protect for index", "q.slots.addActive ok.");

	t.({
		var prevSlots = q.slots.actives.copy;
		q.slots.addActive(0, (key: \xyz));
		prevSlots == prevSlots
	}, "q.slots.addActive failed to protect for illegal obj", "q.slots.addActive ok.");

	t.({
		var index = 0;
		var prevSlots = q.slots.actives.copy.postcs;
		var choices = q.slots.choices[index].copy;
		choices.remove(q.slots.actives[index].key);
		q.slots.addActive(0, p[choices.choose.postln]);
		q.slots.actives.postcs;
		prevSlots[0] != q.slots.actives[0];
	}, "q.slots.addActive failed to change ndef", "q.slots.addActive changed ok.");

	"\n --- XOSC Play BUTTONS ---".postln;
	[0, 1, 2, 3].do { |i|
		t.({
			x.elAt(\sw, 0).valueAction_(0);
			q.slots.actives[0].monitor.isPlaying;
		}, "xosc on/off button failed", "xosc on/off buttons OK.");
	};

	"\n --- XOSC Stop BUTTONS ---".postln;
	[0, 1, 2, 3].do { |i|
		t.({
			x.elAt(\sw, i).valueAction_(1);
			q.slots.actives[0].monitor.isPlaying.not;
		}, "xosc on/off button failed", "xosc on/off buttons OK.");
	};


	"\n --- XOSC MODE BUTTON ---".postln;
	t.({
		var prevMode = q.inph.mode;
		x.elAt(\sw, 4).valueAction_(0);
		prevMode != q.inph.mode;
	}, "xosc mode switch broken", "xosc mode but OK.");

	// and toggle back
	t.({
		var prevMode = q.inph.mode;
		x.elAt(\sw, 4).valueAction_(0);
		prevMode != q.inph.mode;
	}, "xosc mode switch broken", "xosc mode but OK.");

	"\n --- XOSC preset step BUTTONS ---".postln;
	// buttons 6 and 7 step ndef presets and inphlux weights presets down/up
	t.({
		var prevNdefPreIndex = NdefPreset(q.ndefs[3]).currIndex;
		x.elAt(\sw, \4).valueAction_(0);
		x.elAt(\sw, \6).valueAction_(0);
		prevNdefPreIndex != NdefPreset(q.ndefs[3]).currIndex;
	}, "xosc ndef preset switch not working", "xosc preset but OK.");

	0.2.wait;

	// buttons 6 and 7 step ndef presets and inphlux weights presets down/up
	t.({
		var prevInphWeightsKey = q.inphlux.presets.findKeyForValue(q.inphlux.weights);
		var postSwitchKey;
		x.elAt(\sw, \7).valueAction_(0);
		0.02.wait;
		postSwitchKey = q.inphlux.presets.findKeyForValue(q.inphlux.weights);
		"prev key: % new key: %\n".postf(prevInphWeightsKey, postSwitchKey);
		prevInphWeightsKey != postSwitchKey;
	}, "xosc influx preset switch not working", "xosc preset but OK.");


}).stop.play;