/+
+               Copyright 2025 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module ntropy;

private{
	//Use getrandom
	enum useGetrandom = (){
		version(linux) return true;
		else version(Android) return true; //<—— redundant due to `version(linux)`?
		else version(FreeBSD) return true;
		else version(NetBSD) return true;
		else version(DragonFlyBSD) return true;
		else version(Solaris) return true;
		else version(Hurd) return true;
		else return false;
	}();
	
	//Use the CommonCrypto functionality embedded into `libSystem`.
	enum useCommonCrypto = (){
		version(OSX) return true; //At least macOS 10.10
		else version(iOS) return true; //At least iOS 8.0
		else version(TVOS) return true;
		else version(WatchOS) return true;
		else version(VisionOS) return true;
		else return false;
	}();
	
	//Use `Bcrypt.h` from the Win32 API.
	enum useBcrypt = (){
		version(Windows) return true; //At least Windows Vista or Windows Server 2008.
		else return false;
	}();
	
	//Use `/dev/urandom`.
	enum useDevURandom = (){
		version(OpenBSD) return true;
		else version(Haiku) return true;
		else version(AIX) return true;
		else return false;
	}();
	
	static if(useGetrandom){
		extern(C) ptrdiff_t getrandom(void* buf, size_t buflen, uint flags) nothrow @nogc;
	}else static if(useCommonCrypto){
		alias CCRNGStatus = int;
		enum kCCSuccess = 0;
		
		extern(C) CCRNGStatus CCRandomGenerateBytes(void* bytes, size_t count) nothrow @nogc;
	}else static if(useBcrypt){
		import core.sys.windows.subauth: STATUS_SUCCESS;
		import core.sys.windows.ntdef: NTSTATUS;
		
		enum BCRYPT_USE_SYSTEM_PREFERRED_RNG = 0x00000002;
		
		pragma(lib, "bcrypt");
		extern(C) NTSTATUS BCryptGenRandom(void* hAlgorithm, ubyte* pbBuffer, ulong cbBuffer, ulong dwFlags) nothrow @nogc;
	}
}

/**
Generates data with a cryptographically secure pseudorandom number generator.
*/
void[] generate(return scope void[] buf) nothrow @nogc @safe{
	if(buf.length){
		static if(useGetrandom){
			auto len = (() @trusted => getrandom(&buf[0], buf.length, 0))();
			version(Solaris){
				if(len != 0) return buf[0..len];
			}else{
				if(len != -1) return buf[0..len];
			}
			import core.stdc.errno;
			assert(errno == EAGAIN);
			return buf[0..0];
		}else static if(useCommonCrypto){
			auto status = (() @trusted => CCRandomGenerateBytes(&buf[0], buf.length))();
			assert(status == kCCSuccess);
			return buf;
		}else static if(useBcrypt){
			auto status = (() @trusted => BCryptGenRandom(null, cast(ubyte*)&buf[0], buf.length, BCRYPT_USE_SYSTEM_PREFERRED_RNG))();
			assert(status == STATUS_SUCCESS);
			return buf;
		}else static if(useDevURandom){
			import core.stdc.stdio;
			auto random = (() @trusted => fopen("/dev/urandom", "r"))();
			if(random){
				scope(exit) fclose(random);
				
				auto len = fread(&buf[0], 1, buf.length, random);
				if(len == buf.length){
					return buf;
				}
				assert(feof(random)); //Reaching EOF is expected, other errors are not.
				return buf[0..len];
			}else{
				//TODO: somehow assert that the error isn't caused by the file not existing.
				return buf[0..0];
			}
		}else static assert(0, "Unsupported platform! Please submit a pull request to add support for your platform");
	}else return null;
}
unittest{
	foreach(_; 0..256)
		assert(generate(new ubyte[](256))[] != generate(new ubyte[](256))[]);
}
