#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * MCrypt API available online:
 * http://linux.die.net/man/3/mcrypt
 */
#include <mcrypt.h>

#include <math.h>
#include <stdint.h>
#include <stdlib.h>


/*
 * We need a library for random number generation for the IVs
 */
#ifndef _WIN32
#include <openssl/rand.h>
#else
#include <Ntsecapi.h>
#endif

int encrypt(
    void* buffer,
    int buffer_len, 
    uint8_t* IV, 
    uint8_t* key,
    int key_len 
){
  MCRYPT td = mcrypt_module_open("rijndael-128", NULL, "cbc", NULL);
  int blocksize = mcrypt_enc_get_block_size(td);
  if( buffer_len % blocksize != 0 ){return 1;}

  mcrypt_generic_init(td, key, key_len, IV);
  mcrypt_generic(td, buffer, buffer_len);
  mcrypt_generic_deinit (td);
  mcrypt_module_close(td);
  
  return 0;
}

int decrypt(
    void* buffer,
    int buffer_len,
    uint8_t* IV, 
    uint8_t* key,
    int key_len 
){
  MCRYPT td = mcrypt_module_open("rijndael-128", NULL, "cbc", NULL);
  int blocksize = mcrypt_enc_get_block_size(td);
  if( buffer_len % blocksize != 0 ){return 1;}
  
  mcrypt_generic_init(td, key, key_len, IV);
  mdecrypt_generic(td, buffer, buffer_len);
  mcrypt_generic_deinit (td);
  mcrypt_module_close(td);
  
  return 0;
}



int genIV(
  void* buffer,
  int buffer_len
){
  /* 
   * Note that we propagate the return code from the library called.
   */
#ifndef _WIN32
  return RAND_bytes(buffer, buffer_len); 
#else
  return RtlGenRandom(buffer, buffer_len);
#endif
}


void display(uint8_t* ciphertext, int len){
  int v;
  printf("0x ");
  for (v=0; v<len; v++){
    printf("%02x ", ciphertext[v]);
  }
  printf("\n");
}

void* padBuffer(void* buf, int buflen, int blocklen){
  void* barr;
  int barrlen;

  if(buflen > blocklen){
    barrlen = buflen + (blocklen-(buflen%blocklen));
  }else{
    barrlen = blocklen;
  }

  barr = malloc(barrlen);
  memset(barr, 0, barrlen);
  memcpy(barr, buf, buflen);

  return barr;

}

int main()
{
  MCRYPT td, td2;
  char * plaintext = "test text 123";
  char* IV = "AAAAAAAAAAAAAAAA";
  int ivlen = 16;
  char *key = "0123456789abcdef";
  int keysize = 16; /* 128 bits */
  char* buffer;
  int buffer_len = 16;

  //IV = calloc(1, ivlen);
  
  buffer = calloc(1, buffer_len);
  strncpy(buffer, plaintext, buffer_len);

/*
  if(!genIV(IV, ivlen)){
    printf("Error generating random IV. Aborting\n");
    exit(1);
  }
*/
  printf("==C==\n");
  printf("plain:   %s\n", plaintext);
  
  printf("IV:      "); display(IV , ivlen);

  encrypt(buffer, buffer_len, IV, key, keysize); 
  
  printf("cipher:  "); display(buffer , buffer_len);
  
  decrypt(buffer, buffer_len, IV, key, keysize);
  
  printf("decrypt: %s\n", buffer);
  return 0;
}

