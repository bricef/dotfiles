import java.security.MessageDigest;
import java.util.Arrays;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.IvParameterSpec;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.SecureRandom;

public class AES {
  static String IV = "AAAAAAAAAAAAAAAA";
  static String plaintext = "test text 123";
  static String encryptionKey = "0123456789abcdef";

  public static byte[] padBytes(byte[] str, int blocksize){
    byte[] barr;
    if (str.length > blocksize){
      int padbytes = str.length % blocksize ;
      barr = new byte[str.length + (blocksize-padbytes)];
    }else{
      barr = new byte[blocksize];
    }
    System.arraycopy(str, 0, barr, 0, str.length);
    for (int i = str.length; i < barr.length; i++){
      barr[i]=0;
    }
    return barr;
  }

  public static byte[] genIV(int len) throws Exception{
    byte[] arr = new byte[len];
    SecureRandom prng = SecureRandom.getInstance("SHA1PRNG");
    prng.nextBytes(arr);
    return arr;
  }

  public static void printBytes(String preamble, byte[] arr){
    System.out.print(preamble + "0x ");
    for (int i=0; i<arr.length; i++){
        System.out.printf("%02x ", arr[i]);
    }
    System.out.println("");
  }
  
  public static void main(String [] args) {
    try {
      
      System.out.println("==Java==");
      System.out.println("plain:   " + plaintext);
      
      byte[] padded = padBytes(plaintext.getBytes(), 16);
//      printBytes("bytes:   ", padded);
     
//      byte[] iv = genIV(16);
      printBytes("IV:      ", IV.getBytes());

      byte[] cipher = encrypt(new String(padded), encryptionKey);
      printBytes("cipher:  ",cipher);

      String decrypted = decrypt(cipher, encryptionKey);

      System.out.println("decrypt: " + decrypted);

    } catch (Exception e) {
      e.printStackTrace();
    } 
  }

  public static byte[] encrypt(String plainText, String encryptionKey) throws Exception {
    Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding", "SunJCE");
    SecretKeySpec key = new SecretKeySpec(encryptionKey.getBytes("UTF-8"), "AES");
    cipher.init(Cipher.ENCRYPT_MODE, key,new IvParameterSpec(IV.getBytes("UTF-8")));
    return cipher.doFinal(plainText.getBytes("UTF-8"));
  }

  public static String decrypt(byte[] cipherText, String encryptionKey) throws Exception{
    Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding", "SunJCE");
    SecretKeySpec key = new SecretKeySpec(encryptionKey.getBytes("UTF-8"), "AES");
    cipher.init(Cipher.DECRYPT_MODE, key,new IvParameterSpec(IV.getBytes("UTF-8")));
    return new String(cipher.doFinal(cipherText),"UTF-8");
  }
}


