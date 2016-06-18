module d.sync.lock;

import sdc.intrinsics;

struct Lock {
private:
	import d.sync.atomic;
	Atomic!ubyte val;
	
	enum LockBit = 0x01;
	enum ParkBit = 0x02;
	
public:
	void lock() {
		// No operation done after the lock is taken can be reordered before.
		if (likely(val.casWeak(0, LockBit, MemoryOrder.Acquire))) {
			return;
		}
		
		lockSlow();
	}
	
	void unlock() {
		// No operation done before the lock is freed can be reordered after.
		if (likely(val.casWeak(LockBit, 0, MemoryOrder.Release))) {
			return;
		}
		
		unlockSlow();
	}
	
private:
	void lockSlow() {
		// Trusting WTF::Lock on that one...
		enum SpinLimit = 40;
		
		uint spinCount = 0;
		
		while (true) {
			// FIXME: We may be able to get this from the CAS operations
			// if we get intrinsics right.
			auto b = val.load();
			
			// If the lock if free, we take weither someone is parked or not.
			if (!(b & LockBit)) {
				if (val.casWeak(b, b | LockBit)) {
					// We got the lock, VICTORY !
					return;
				}
			}
			
			// If nobody's parked, ...
			if (!(b & ParkBit)) {
				// First, try to spin a bit.
				if (spinCount < SpinLimit) {
					spinCount++;
					// FIXME: shed_yield();
					continue;
				}
				
				// We've waited long enough, let's try to park.
				if (!val.casWeak(LockBit, LockBit | ParkBit)) {
					continue;
				}
			}
			
			// Alright, let's park.
			// ParkingLot::compareAndPark(&var, LockBit | ParkBit);
			assert(0, "Parking is not supported at this stage");
			
			// Ok we are awake ! Let's try to acquire that lock again !
		}
	}
	
	void unlockSlow() {
		while(true) {
			// FIXME: We may be able to get this from the CAS operations
			// if we get intrinsics right.
			auto b = val.load(MemoryOrder.SeqCst);
			assert(b | LockBit, "Lock is not locked");
			
			if (b == LockBit) {
				// Nobody is parked, just unlock.
				if (val.casWeak(LockBit, 0, MemoryOrder.SeqCst)) {
					return;
				}
				
				continue;
			}
			
			// As it turns out, someone is parked, free them.
			assert(b == LockBit | ParkBit, "Unexpected lock value");
			/+
			ParkingLot::unparkOne(&val, (result) {
				assert(val.load() == LockBit | ParkBit, "Unexpected lock value");
				val.store(result.moar ? ParkBit : 0);
			});
			// +/
			assert(0, "Parkign not supported");
			
			// At this point, we should be free to go.
			// return;
		}
	}
}
