//
/*
slotmachine has 4 slots with playable objects
We assume these are all Ndefs for now.
When an object is added,
- the old one stops, and is removed from influx,
- and the new one plays and is attached to influx.


NdefMixer(s, 24);
q.ndefs;
q.slots.actives;
q.slots.playAt(0)
q.slots.stopAt(0)

q.slots.playAt(1)
q.slots.stopAt(1)

q.slots.playAt(3)
q.slots.stepNext(3)



q.slots.addActive(4, \x)
q.slots.addActive(3, Ndef(\kiteHi))

q.slots.chooseNext(0);

q.inphlux.action.activeNames;
q.inphlux.action.disable(q.inphlux.action.activeNames.copy);

*/

q.slots = q.slots ? ();
q.slots.actives = q.ndefs;
q.slots.playAt = { |sl, index|
	var obj = q.slots.actives[index];
	"% plays now.\n".postf(obj);
	obj.play;
	q.inphlux.attachMapped(obj);
};
q.slots.stopAt = { |sl, index|
	var obj = q.slots.actives[index];
	"% stops now.\n".postf(obj);
	obj.stop;
	try { q.inphlux.removeMapped(obj.key) };
};

q.slots.checkIndex = { |sl, index|
	var res = index.isNumber and: { index.inclusivelyBetween(0, q.slots.actives.lastIndex) };
	if (res.not) { "slots index must be between 0 and 3".postln };
	res;
};

q.slots.addActive = { |sl, index, obj|
	case
	{ obj.isNil } { "addActive: cannot add nil".postln }
	{ q.slots.checkIndex(index) } {
		// all is well
		q.slots.stopAt(index);
		q.slots.actives.put(index, obj);
		q.slots.playAt(index);
		q.slots.updateChoices;
	}
};

q.slots.updateChoices = {
	q.slots.choices = q.slots.actives.collect { |ndef, i|
		q.allSoundNames.reject { |name|
			var takenKeys = q.slots.actives.collect(_.key);
			takenKeys.remove(ndef.key);
			takenKeys.includes(name)
		}
	}
};

q.slots.chooseNext = { |sl, index|
	if (q.slots.checkIndex(index)) {
		var candidates = q.slots.choices[index];
		var nextname = candidates.choose;
		"next  sound in slot % : % \n".postf(index, nextname);
		// ndef is dogy here, hmmm
		q.slots.addActive(index, Ndef(nextname));
	};
};

q.slots.stepNext = { |sl, index, incr = 1|
	if (q.slots.checkIndex(index)) {
		var candidates = q.slots.choices[index];
		var myindex = candidates.indexOf(q.slots.actives[index].key);
		var nextindex = myindex + incr;
		var nextname = candidates[nextindex];
		"next  sound in slot % : % \n".postf(index, nextname);
		// ndef is dogy here, hmmm
		q.slots.addActive(index, Ndef(nextname));
	};
};