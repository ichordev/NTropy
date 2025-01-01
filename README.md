# [NTropy](https://git.sleeping.town/ichordev/NTropy)

This library provides a lightweight platform-independent interface to generate cryptographically secure pseudorandom data from system sources.
NTropy is compatible with `@safe`, `@nogc` and `nothrow`, and can be compiled with BetterC compatibility.

Public methods in the source code have embedded documentation.

## Usage
Fill a buffer with cryptographically secure random data:
```d
import ntropy;

auto myBuffer = new ubyte[](32);
if(ntropy.generate(myBuffer)){
	//use myBuffer
}else{
	//error detected!
}
```

## Supported platforms
| Version identifier(s)      | Minimum version        | Implementation |
|----------------------------|------------------------|----------------|
| `linux`/`Android`          | Kernel 3.17, glibc 2.25|[`getrandom`](https://man7.org/linux/man-pages/man2/getrandom.2.html)|
| `OSX`                      | 10.10                  |[`CCRandomGenerateBytes`](https://github.com/apple-oss-distributions/CommonCrypto/blob/main/include/CommonRandom.h#L56)|
| `iOS`                      | 8.0                    |[`CCRandomGenerateBytes`](https://github.com/apple-oss-distributions/CommonCrypto/blob/main/include/CommonRandom.h#L56)|
| `TVOS`/`WatchOS`/`VisionOS`| (none)                 |[`CCRandomGenerateBytes`](https://github.com/apple-oss-distributions/CommonCrypto/blob/main/include/CommonRandom.h#L56)|
| `Windows`                  | Vista / Server 2008    |[`BCryptGenRandom`](https://learn.microsoft.com/en-us/windows/win32/api/bcrypt/nf-bcrypt-bcryptgenrandom)
| `FreeBSD`                  | 12.0                   |[`getrandom`](https://man.freebsd.org/cgi/man.cgi?query=getrandom)|
| `OpenBSD`                  | 2.1                    |[`arc4random_buf`](https://man.openbsd.org/OpenBSD-5.4/arc4random.3)|
| `NetBSD`                   | 10.0                   |[`getrandom`](https://man.netbsd.org/getrandom.2)|
| `DragonFlyBSD`             | 5.7                    |[`getrandom`](https://leaf.dragonflybsd.org/cgi/web-man?command=getrandom)|
| `Hurd`                     | (unknown)              |[`getrandom`](https://www.gnu.org/software/libc/manual/html_mono/libc.html#index-getrandom)|
| `Solaris`                  | 11.3                   |[`getrandom`](https://docs.oracle.com/cd/E88353_01/html/E37841/getrandom-2.html)|
| `AIX`                      | (unknown)              |[`/dev/urandom`](https://www.ibm.com/docs/en/aix/7.3?topic=files-random-urandom-devices)|
| `Haiku`                    | R1/beta5               |[`arc4random_buf`](https://www.haiku-os.org/get-haiku/r1beta5/release-notes)|
| `Cygwin`                   | 2.7.0                  |[`getrandom`](https://cygwin.com/cygwin-ug-net/ov-new.html#ov-new2.7)|

Not all platforms have been tested. Pull requests to add new platforms, lower minimum system versions, or fix bugs are welcome.

## BetterC compatibility

If you are using dub, then by default the library will compile without BetterC. To enable BetterC compatibility, select the `yesBC` configuration in your dub recipe.

## See also

- [csprng-d](https://github.com/JonathanWilbur/csprng-d) inspired this project. It is a similar library but not as lightweight, and isn't actively maintained.
- [getrandom](https://crates.io/crates/getrandom) for Rust, whose documentation inspired this README.
