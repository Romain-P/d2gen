package com.ankamagames.jerakine.utils.crypto
{
   public class AdvancedMd5
   {
      
      public static const HEX_FORMAT_LOWERCASE:uint = 0;
      
      public static const HEX_FORMAT_UPPERCASE:uint = 1;
      
      public static const BASE64_PAD_CHARACTER_DEFAULT_COMPLIANCE:String = "";
      
      public static const BASE64_PAD_CHARACTER_RFC_COMPLIANCE:String = "=";
      
      public static var hexcase:uint = 0;
      
      public static var b64pad:String = "";
       
      
      public function AdvancedMd5()
      {
         super();
      }
      
      public static function encrypt(string:String) : String
      {
         return hex_md5(string);
      }
      
      public static function hex_md5(string:String) : String
      {
         return rstr2hex(rstr_md5(str2rstr_utf8(string)));
      }
      
      public static function b64_md5(string:String) : String
      {
         return rstr2b64(rstr_md5(str2rstr_utf8(string)));
      }
      
      public static function any_md5(string:String, encoding:String) : String
      {
         return rstr2any(rstr_md5(str2rstr_utf8(string)),encoding);
      }
      
      public static function hex_hmac_md5(key:String, data:String) : String
      {
         return rstr2hex(rstr_hmac_md5(str2rstr_utf8(key),str2rstr_utf8(data)));
      }
      
      public static function b64_hmac_md5(key:String, data:String) : String
      {
         return rstr2b64(rstr_hmac_md5(str2rstr_utf8(key),str2rstr_utf8(data)));
      }
      
      public static function any_hmac_md5(key:String, data:String, encoding:String) : String
      {
         return rstr2any(rstr_hmac_md5(str2rstr_utf8(key),str2rstr_utf8(data)),encoding);
      }
      
      public static function md5_vm_test() : Boolean
      {
         return hex_md5("abc") == "900150983cd24fb0d6963f7d28e17f72";
      }
      
      public static function rstr_md5(string:String) : String
      {
         return binl2rstr(binl_md5(rstr2binl(string),string.length * 8));
      }
      
      public static function rstr_hmac_md5(key:String, data:String) : String
      {
         var bkey:Array = rstr2binl(key);
         if(bkey.length > 16)
         {
            bkey = binl_md5(bkey,key.length * 8);
         }
         var ipad:Array = new Array(16);
         var opad:Array = new Array(16);
         for(var i:* = 0; i < 16; i++)
         {
            ipad[i] = bkey[i] ^ 909522486;
            opad[i] = bkey[i] ^ 1549556828;
         }
         var hash:Array = binl_md5(ipad.concat(rstr2binl(data)),512 + data.length * 8);
         return binl2rstr(binl_md5(opad.concat(hash),640));
      }
      
      public static function rstr2hex(input:String) : String
      {
         var x:Number = NaN;
         var hex_tab:String = !!hexcase?"0123456789ABCDEF":"0123456789abcdef";
         var output:String = "";
         for(var i:* = 0; i < input.length; i++)
         {
            x = input.charCodeAt(i);
            output = output + (hex_tab.charAt(x >>> 4 & 15) + hex_tab.charAt(x & 15));
         }
         return output;
      }
      
      public static function rstr2b64(input:String) : String
      {
         var triplet:Number = NaN;
         var j:* = NaN;
         var tab:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
         var output:String = "";
         var len:Number = input.length;
         for(var i:* = 0; i < len; i = Number(i + 3))
         {
            triplet = input.charCodeAt(i) << 16 | (i + 1 < len?input.charCodeAt(i + 1) << 8:0) | (i + 2 < len?input.charCodeAt(i + 2):0);
            for(j = 0; j < 4; j++)
            {
               if(i * 8 + j * 6 > input.length * 8)
               {
                  output = output + b64pad;
               }
               else
               {
                  output = output + tab.charAt(triplet >>> 6 * (3 - j) & 63);
               }
            }
         }
         return output;
      }
      
      public static function rstr2any(input:String, encoding:String) : String
      {
         var i:* = NaN;
         var q:Number = NaN;
         var x:* = NaN;
         var quotient:* = null;
         var divisor:Number = encoding.length;
         var remainders:* = [];
         var dividend:Array = new Array(input.length / 2);
         for(i = 0; i < dividend.length; i++)
         {
            dividend[i] = input.charCodeAt(i * 2) << 8 | input.charCodeAt(i * 2 + 1);
         }
         while(dividend.length > 0)
         {
            quotient = [];
            x = 0;
            for(i = 0; i < dividend.length; )
            {
               x = Number((x << 16) + dividend[i]);
               q = Math.floor(x / divisor);
               x = Number(x - q * divisor);
               if(quotient.length > 0 || q > 0)
               {
                  quotient[quotient.length] = q;
               }
               i++;
            }
            remainders[remainders.length] = x;
            dividend = quotient;
         }
         var output:String = "";
         for(i = Number(remainders.length - 1); i >= 0; i--)
         {
            output = output + encoding.charAt(remainders[i]);
         }
         return output;
      }
      
      public static function str2rstr_utf8(input:String) : String
      {
         var x:Number = NaN;
         var y:Number = NaN;
         var output:String = "";
         for(var i:* = -1; ++i < input.length; )
         {
            x = input.charCodeAt(i);
            y = i + 1 < input.length?Number(input.charCodeAt(i + 1)):Number(0);
            if(55296 <= x && x <= 56319 && 56320 <= y && y <= 57343)
            {
               x = 65536 + ((x & 1023) << 10) + (y & 1023);
               i++;
            }
            if(x <= 127)
            {
               output = output + String.fromCharCode(x);
            }
            else if(x <= 2047)
            {
               output = output + String.fromCharCode(192 | x >>> 6 & 31,128 | x & 63);
            }
            else if(x <= 65535)
            {
               output = output + String.fromCharCode(224 | x >>> 12 & 15,128 | x >>> 6 & 63,128 | x & 63);
            }
            else if(x <= 2097151)
            {
               output = output + String.fromCharCode(240 | x >>> 18 & 7,128 | x >>> 12 & 63,128 | x >>> 6 & 63,128 | x & 63);
            }
         }
         return output;
      }
      
      public static function str2rstr_utf16le(input:String) : String
      {
         var output:String = "";
         for(var i:* = 0; i < input.length; i++)
         {
            output = output + String.fromCharCode(input.charCodeAt(i) & 255,input.charCodeAt(i) >>> 8 & 255);
         }
         return output;
      }
      
      public static function str2rstr_utf16be(input:String) : String
      {
         var output:String = "";
         for(var i:* = 0; i < input.length; i++)
         {
            output = output + String.fromCharCode(input.charCodeAt(i) >>> 8 & 255,input.charCodeAt(i) & 255);
         }
         return output;
      }
      
      public static function rstr2binl(input:String) : Array
      {
         var output:Array = new Array(input.length >> 2);
         for(var i:* = 0; i < output.length; i++)
         {
            output[i] = 0;
         }
         for(i = 0; i < input.length * 8; i = Number(i + 8))
         {
            output[i >> 5] = output[i >> 5] | (input.charCodeAt(i / 8) & 255) << i % 32;
         }
         return output;
      }
      
      public static function binl2rstr(input:Array) : String
      {
         var output:String = "";
         for(var i:* = 0; i < input.length * 32; i = Number(i + 8))
         {
            output = output + String.fromCharCode(input[i >> 5] >>> i % 32 & 255);
         }
         return output;
      }
      
      public static function binl_md5(x:Array, len:Number) : Array
      {
         var olda:Number = NaN;
         var oldb:Number = NaN;
         var oldc:Number = NaN;
         var oldd:Number = NaN;
         x[len >> 5] = x[len >> 5] | 128 << len % 32;
         x[(len + 64 >>> 9 << 4) + 14] = len;
         var a:* = 1732584193;
         var b:* = -271733879;
         var c:* = -1732584194;
         var d:* = 271733878;
         for(var i:* = 0; i < x.length; i = Number(i + 16))
         {
            olda = a;
            oldb = b;
            oldc = c;
            oldd = d;
            a = Number(md5_ff(a,b,c,d,x[i + 0],7,-680876936));
            d = Number(md5_ff(d,a,b,c,x[i + 1],12,-389564586));
            c = Number(md5_ff(c,d,a,b,x[i + 2],17,606105819));
            b = Number(md5_ff(b,c,d,a,x[i + 3],22,-1044525330));
            a = Number(md5_ff(a,b,c,d,x[i + 4],7,-176418897));
            d = Number(md5_ff(d,a,b,c,x[i + 5],12,1200080426));
            c = Number(md5_ff(c,d,a,b,x[i + 6],17,-1473231341));
            b = Number(md5_ff(b,c,d,a,x[i + 7],22,-45705983));
            a = Number(md5_ff(a,b,c,d,x[i + 8],7,1770035416));
            d = Number(md5_ff(d,a,b,c,x[i + 9],12,-1958414417));
            c = Number(md5_ff(c,d,a,b,x[i + 10],17,-42063));
            b = Number(md5_ff(b,c,d,a,x[i + 11],22,-1990404162));
            a = Number(md5_ff(a,b,c,d,x[i + 12],7,1804603682));
            d = Number(md5_ff(d,a,b,c,x[i + 13],12,-40341101));
            c = Number(md5_ff(c,d,a,b,x[i + 14],17,-1502002290));
            b = Number(md5_ff(b,c,d,a,x[i + 15],22,1236535329));
            a = Number(md5_gg(a,b,c,d,x[i + 1],5,-165796510));
            d = Number(md5_gg(d,a,b,c,x[i + 6],9,-1069501632));
            c = Number(md5_gg(c,d,a,b,x[i + 11],14,643717713));
            b = Number(md5_gg(b,c,d,a,x[i + 0],20,-373897302));
            a = Number(md5_gg(a,b,c,d,x[i + 5],5,-701558691));
            d = Number(md5_gg(d,a,b,c,x[i + 10],9,38016083));
            c = Number(md5_gg(c,d,a,b,x[i + 15],14,-660478335));
            b = Number(md5_gg(b,c,d,a,x[i + 4],20,-405537848));
            a = Number(md5_gg(a,b,c,d,x[i + 9],5,568446438));
            d = Number(md5_gg(d,a,b,c,x[i + 14],9,-1019803690));
            c = Number(md5_gg(c,d,a,b,x[i + 3],14,-187363961));
            b = Number(md5_gg(b,c,d,a,x[i + 8],20,1163531501));
            a = Number(md5_gg(a,b,c,d,x[i + 13],5,-1444681467));
            d = Number(md5_gg(d,a,b,c,x[i + 2],9,-51403784));
            c = Number(md5_gg(c,d,a,b,x[i + 7],14,1735328473));
            b = Number(md5_gg(b,c,d,a,x[i + 12],20,-1926607734));
            a = Number(md5_hh(a,b,c,d,x[i + 5],4,-378558));
            d = Number(md5_hh(d,a,b,c,x[i + 8],11,-2022574463));
            c = Number(md5_hh(c,d,a,b,x[i + 11],16,1839030562));
            b = Number(md5_hh(b,c,d,a,x[i + 14],23,-35309556));
            a = Number(md5_hh(a,b,c,d,x[i + 1],4,-1530992060));
            d = Number(md5_hh(d,a,b,c,x[i + 4],11,1272893353));
            c = Number(md5_hh(c,d,a,b,x[i + 7],16,-155497632));
            b = Number(md5_hh(b,c,d,a,x[i + 10],23,-1094730640));
            a = Number(md5_hh(a,b,c,d,x[i + 13],4,681279174));
            d = Number(md5_hh(d,a,b,c,x[i + 0],11,-358537222));
            c = Number(md5_hh(c,d,a,b,x[i + 3],16,-722521979));
            b = Number(md5_hh(b,c,d,a,x[i + 6],23,76029189));
            a = Number(md5_hh(a,b,c,d,x[i + 9],4,-640364487));
            d = Number(md5_hh(d,a,b,c,x[i + 12],11,-421815835));
            c = Number(md5_hh(c,d,a,b,x[i + 15],16,530742520));
            b = Number(md5_hh(b,c,d,a,x[i + 2],23,-995338651));
            a = Number(md5_ii(a,b,c,d,x[i + 0],6,-198630844));
            d = Number(md5_ii(d,a,b,c,x[i + 7],10,1126891415));
            c = Number(md5_ii(c,d,a,b,x[i + 14],15,-1416354905));
            b = Number(md5_ii(b,c,d,a,x[i + 5],21,-57434055));
            a = Number(md5_ii(a,b,c,d,x[i + 12],6,1700485571));
            d = Number(md5_ii(d,a,b,c,x[i + 3],10,-1894986606));
            c = Number(md5_ii(c,d,a,b,x[i + 10],15,-1051523));
            b = Number(md5_ii(b,c,d,a,x[i + 1],21,-2054922799));
            a = Number(md5_ii(a,b,c,d,x[i + 8],6,1873313359));
            d = Number(md5_ii(d,a,b,c,x[i + 15],10,-30611744));
            c = Number(md5_ii(c,d,a,b,x[i + 6],15,-1560198380));
            b = Number(md5_ii(b,c,d,a,x[i + 13],21,1309151649));
            a = Number(md5_ii(a,b,c,d,x[i + 4],6,-145523070));
            d = Number(md5_ii(d,a,b,c,x[i + 11],10,-1120210379));
            c = Number(md5_ii(c,d,a,b,x[i + 2],15,718787259));
            b = Number(md5_ii(b,c,d,a,x[i + 9],21,-343485551));
            a = Number(safe_add(a,olda));
            b = Number(safe_add(b,oldb));
            c = Number(safe_add(c,oldc));
            d = Number(safe_add(d,oldd));
         }
         return [a,b,c,d];
      }
      
      public static function md5_cmn(q:Number, a:Number, b:Number, x:Number, s:Number, t:Number) : Number
      {
         return safe_add(bit_rol(safe_add(safe_add(a,q),safe_add(x,t)),s),b);
      }
      
      public static function md5_ff(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number) : Number
      {
         return md5_cmn(b & c | ~b & d,a,b,x,s,t);
      }
      
      public static function md5_gg(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number) : Number
      {
         return md5_cmn(b & d | c & ~d,a,b,x,s,t);
      }
      
      public static function md5_hh(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number) : Number
      {
         return md5_cmn(b ^ c ^ d,a,b,x,s,t);
      }
      
      public static function md5_ii(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number) : Number
      {
         return md5_cmn(c ^ (b | ~d),a,b,x,s,t);
      }
      
      public static function safe_add(x:Number, y:Number) : Number
      {
         var lsw:Number = (x & 65535) + (y & 65535);
         var msw:Number = (x >> 16) + (y >> 16) + (lsw >> 16);
         return msw << 16 | lsw & 65535;
      }
      
      public static function bit_rol(num:Number, cnt:Number) : Number
      {
         return num << cnt | num >>> 32 - cnt;
      }
   }
}
