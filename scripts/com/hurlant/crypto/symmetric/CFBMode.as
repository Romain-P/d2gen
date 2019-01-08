package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFBMode extends IVMode implements IMode
   {
       
      
      public function CFBMode(key:ISymmetricKey, padding:IPad = null)
      {
         super(key,null);
      }
      
      public function encrypt(src:ByteArray) : void
      {
         var chunk:* = 0;
         var j:int = 0;
         var l:uint = src.length;
         var vector:ByteArray = getIV4e();
         for(var i:* = 0; i < src.length; i = uint(i + blockSize))
         {
            key.encrypt(vector);
            chunk = uint(i + blockSize < l?uint(blockSize):uint(l - i));
            for(j = 0; j < chunk; j++)
            {
               src[i + j] = src[i + j] ^ vector[j];
            }
            vector.position = 0;
            vector.writeBytes(src,i,chunk);
         }
      }
      
      public function decrypt(src:ByteArray) : void
      {
         var chunk:* = 0;
         var j:int = 0;
         var l:uint = src.length;
         var vector:ByteArray = getIV4d();
         var tmp:ByteArray = new ByteArray();
         for(var i:* = 0; i < src.length; i = uint(i + blockSize))
         {
            key.encrypt(vector);
            chunk = uint(i + blockSize < l?uint(blockSize):uint(l - i));
            tmp.position = 0;
            tmp.writeBytes(src,i,chunk);
            for(j = 0; j < chunk; j++)
            {
               src[i + j] = src[i + j] ^ vector[j];
            }
            vector.position = 0;
            vector.writeBytes(tmp);
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb";
      }
   }
}
