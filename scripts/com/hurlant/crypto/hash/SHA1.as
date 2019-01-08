package com.hurlant.crypto.hash
{
   public class SHA1 extends SHABase implements IHash
   {
      
      public static const HASH_SIZE:int = 20;
       
      
      public function SHA1()
      {
         super();
      }
      
      override public function getHashSize() : uint
      {
         return HASH_SIZE;
      }
      
      override protected function core(x:Array, len:uint) : Array
      {
         var olda:* = 0;
         var oldb:* = 0;
         var oldc:* = 0;
         var oldd:* = 0;
         var olde:* = 0;
         var j:int = 0;
         var t:* = 0;
         x[len >> 5] = x[len >> 5] | 128 << 24 - len % 32;
         x[(len + 64 >> 9 << 4) + 15] = len;
         var w:* = [];
         var a:* = 1732584193;
         var b:* = 4023233417;
         var c:* = 2562383102;
         var d:* = 271733878;
         var e:* = 3285377520;
         for(var i:* = 0; i < x.length; i = uint(i + 16))
         {
            olda = uint(a);
            oldb = uint(b);
            oldc = uint(c);
            oldd = uint(d);
            olde = uint(e);
            for(j = 0; j < 80; j++)
            {
               if(j < 16)
               {
                  w[j] = x[i + j] || false;
               }
               else
               {
                  w[j] = this.rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16],1);
               }
               t = uint(this.rol(a,5) + this.ft(j,b,c,d) + e + w[j] + this.kt(j));
               e = uint(d);
               d = uint(c);
               c = uint(this.rol(b,30));
               b = uint(a);
               a = uint(t);
            }
            a = uint(a + olda);
            b = uint(b + oldb);
            c = uint(c + oldc);
            d = uint(d + oldd);
            e = uint(e + olde);
         }
         return [a,b,c,d,e];
      }
      
      private function rol(num:uint, cnt:uint) : uint
      {
         return num << cnt | num >>> 32 - cnt;
      }
      
      private function ft(t:uint, b:uint, c:uint, d:uint) : uint
      {
         if(t < 20)
         {
            return b & c | ~b & d;
         }
         if(t < 40)
         {
            return b ^ c ^ d;
         }
         if(t < 60)
         {
            return b & c | b & d | c & d;
         }
         return b ^ c ^ d;
      }
      
      private function kt(t:uint) : uint
      {
         return t < 20?1518500249:t < 40?1859775393:t < 60?2400959708:uint(3395469782);
      }
      
      override public function toString() : String
      {
         return "sha1";
      }
   }
}
