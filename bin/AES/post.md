<p><markdown>
Following a [question on stackoverflow](http://stackoverflow.com/questions/10247896/aes-rijndael-encrypt-between-c-and-java/), I though I might go into more detail about how to use AES encryption in C and Java

### What Is AES?

AES is the **A**dvanced **E**ncryption **S**tandard. It is an encryption algorithm selected after a [long, thorough and open competition](http://en.wikipedia.org/wiki/Advanced_Encryption_Standard_process) held by the US NIST.

It is a [block cipher](http://en.wikipedia.org/wiki/Block_cipher) that operates on blocks of 128 bits. The Algorithm name is Rijndael, and you will sometimes see people referring to AES as Rijndael-128. 

### Basic operation of block ciphers

In essence, block ciphers take two inputs: 1. a key, and 2. a plaintext block. They turn these into a ciphertext block. The complications occur because messages are often much larger than single blocks, (128 bits is shorter than this sentence, for example). 

When the message is longer than the block size, a **Mode of Operation** must be chosen for the cipher. Wikipedia has [a very clear overview](http://en.wikipedia.org/wiki/Block_cipher_modes_of_operation) of the major modes of operation. A more in depth discussion can be found in Chapter 9 of Bruce Schneier's [Applied Cryptography](http://www.schneier.com/book-applied.html).

The simplest would be to encrypt every block with the same key. This is called "Electronic Code-Book" mode or ECB. 

![](http://upload.wikimedia.org/wikipedia/commons/c/c4/Ecb_encryption.png)

However, there are serious security problems with doing this. Namely, identical plaintext blocks will encrypt to identical ciphertext blocks. This means that any patterns in the data will be immediately visible to an attacker. To mitigate this, we use a mode of operation that is primed with an Initialisation Vector (IV) and where the encryption step of a given block depends on a preceding step. 

The Mode I will use is called Cipher Block Chaining, and makes a given block depend on a previous step by [XORing](http://en.wikipedia.org/wiki/Bitwise_operation#XOR) the previous encrypted block with the plaintext before encryption:

![](http://upload.wikimedia.org/wikipedia/commons/d/d3/Cbc_encryption.png)

### Goals

The goals for the post are to:

1. Encrypt/Decrypt a string with AES in both Java and C using a given key and Initialisation Vector.

2. Decrypt a variable length string with AES in both Java and C.

3. Be able to generate a random Initialisation Vector in either languages

4. Encrypt a plaintext with C and decrypt it with Java

5. Encrypt a plaintext with Java and decrypt it with C

### What will be ignored

There are many important issues that will be completely ignored. These are:

1. Error handling. I will not check if something goes wrong, such as a missing file or library return codes. Note that this is quite important. If the underlying cryptography library encounter an error, the security of the following steps may be severely compromised. This is done for clarity, as peppering the encryption code/decryption code with error handling would make it quite opaque

1. Error correction in case of data corruption/loss/etc... 

1. Authentication. (Making sure you're talking to the right person). This is vitally important in real life, but will be completely ignored. 

1. Practical matters such as how to compile the code, or how to download and install the required libraries.


### Goal 1

In Java, we can use the `javax.crypto` standard library functions and classes, whiich are documented [in the usual place](http://docs.oracle.com/javase/7/docs/api/javax/crypto/package-summary.html):

https://gist.github.com/2437994

In C, we can use the [libmcrypt](http://sourceforge.net/projects/mcrypt/files/Libmcrypt/) functions to achieve similar things. The best source of documentation for Libmcrypt are the header files. You can also find the API documented [online](http://linux.die.net/man/3/mcrypt):

https://gist.github.com/2438023

Some things to note about these examples: 

 * In the C case, note how the input buffer is overwritten by the ciphertext. 
 * In both cases, the library called can experience errors, and that these are not handled by the code. That's up to you.
 * Most importantly, both these functions will expect their input to already be padded to the correct length. (An integer multiple of the blocksize.)

### A note on Padding

As mentioned above, the functions described expect an input that will be the a multiple of the blocksize. In order to make the input string fit nicely into a block, we will have to pad it appropriately.

For simplicity, I will describe how to null-pad the plaintext to make it fit into a fixed number of blocks. It should be noted that there are many other padding schemes. [This page](http://www.di-mgt.com.au/cryptopad.html) has well described examples of the major padding schemes.

In fact, null padding doesn't work with some inputs that may have null bytes. For example, executables or binary file formats. These problems aside, let's write a function that will pad a string to a given length in Java:

https://gist.github.com/2438865

And in C:

https://gist.github.com/2438900

We'll therefore have to use these functions before encrypting our byte streams.

### Goal 2

Once the encryption function has been written, the decryption function is really more of the same. In Java:

https://gist.github.com/2438921

And in C:

https://gist.github.com/2438927

### Goal 3

In order to encrypt our plaintext, the CBC mode of operation will require an Initialisation Vector. This should be a randomly generated block of the same size as the encryption block.

In Java: 

https://gist.github.com/2463908

Things get a little more complicated in C. Libmcrypt doesn't provide a good randomness source, we could use `rand()` from the standard library, but that comes with many subtle problems that could trip up the process and open us up to attacks. In particular, if the program is to be called more than once a second (which is a very reasonable rates, as these things go), then using the naive `time(NULL)` as a seed would lead to repeated IVs, which would destroy our security. We therefore use [libopenssl](http://www.openssl.org/)'s random number generator instead, which will provide cryptographically secure random numbers.

On Linux and the Unixes, this is not a problem. We have a good quality entropy pool available to seed the random generator at `/dev/random`. In fact, libopenssl will self-initialise if it is run on such systems, we just have to verify that the library has collected enough entropy before using. This is all covered in much greater detail in the [libopenssl docs](http://www.openssl.org/docs/crypto/RAND_add.html).

On Windows, the standard way of accessing entropy is the Crypto API (CAPI), which is closed-source. Using it requires that you trust Microsoft's implementation of the entropy pool. (Would I personally bet the contents of my bank account on the quality of CAPI? Yes. I might be more worried about the life of a loved one though.) 

If you do, CAPI provides `CryptGenRandom()` which will get you some random bytes as needed. The windows APIs also provide a simpler version `RtlGenRandom()`, which does not require initialising a cryptographic context. You can find out more from the respective [msdn](http://msdn.microsoft.com/en-us/library/aa379942.aspx) [pages](http://msdn.microsoft.com/en-us/library/windows/desktop/aa387694.aspx) and [Wikipedia](http://en.wikipedia.org/wiki/CryptGenRandom).

To the code!

https://gist.github.com/2464895


### Goal 4





</markdown></p>
