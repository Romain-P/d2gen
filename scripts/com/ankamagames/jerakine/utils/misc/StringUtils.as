package com.ankamagames.jerakine.utils.misc
{
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class StringUtils
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(StringUtils));
      
      private static var pattern:Vector.<RegExp>;
      
      private static var patternReplace:Vector.<String>;
      
      private static var accents:String = "ŠŒŽšœžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜŸÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿþ";
       
      
      public function StringUtils()
      {
         super();
      }
      
      public static function cleanString(s:String) : String
      {
         s = s.split("&").join("&amp;");
         s = s.split("<").join("&lt;");
         s = s.split(">").join("&gt;");
         return s;
      }
      
      public static function convertLatinToUtf(str:String) : String
      {
         var b:ByteArray = new ByteArray();
         b.writeMultiByte(decodeURI(str),"iso-8859-1");
         b.position = 0;
         return b.readUTFBytes(b.length);
      }
      
      public static function fill(str:String, len:uint, char:String, before:Boolean = true) : String
      {
         if(!char || !char.length)
         {
            return str;
         }
         while(str.length != len)
         {
            if(before)
            {
               str = char + str;
            }
            else
            {
               str = str + char;
            }
         }
         return str;
      }
      
      public static function formatArray(data:Array, header:Array = null) : String
      {
         var row:* = undefined;
         var i:* = undefined;
         var lenIndex:* = undefined;
         var headerLine:* = null;
         var headerSubLine:* = null;
         var line:* = null;
         var str:* = null;
         var colSep:String = " | ";
         var headerColSep:String = "-+-";
         var spaces:String = "                                                                                                               ";
         var headerSep:String = "---------------------------------------------------------------------------------------------------------------";
         var length:* = [];
         var result:* = [];
         for each(row in data)
         {
            for(i in row)
            {
               lenIndex = !!header?header[i]:i;
               length[lenIndex] = !!isNaN(length[lenIndex])?String(row[i]).length:Math.max(length[lenIndex],String(row[i]).length);
            }
         }
         if(i is String || header)
         {
            headerLine = [];
            headerSubLine = [];
            row = !!header?header:row;
            for(i in row)
            {
               lenIndex = !!header?header[i]:i;
               length[lenIndex] = !!isNaN(length[lenIndex])?lenIndex.length:Math.max(length[lenIndex],lenIndex.length);
               headerLine.push(lenIndex + spaces.substr(0,length[lenIndex] - lenIndex.length));
               headerSubLine.push(headerSep.substr(0,length[lenIndex]));
            }
            result.push(headerLine.join(colSep));
            result.push(headerSubLine.join(headerColSep));
         }
         for each(row in data)
         {
            line = [];
            for(i in row)
            {
               str = row[i];
               lenIndex = !!header?header[i]:i;
               line.push(str + spaces.substr(0,length[lenIndex] - String(str).length));
            }
            result.push(line.join(colSep));
         }
         return result.join("\n");
      }
      
      public static function replace(src:String, pattern:* = null, replacement:* = null) : String
      {
         var i:int = 0;
         var r:* = null;
         if(!pattern)
         {
            return src;
         }
         if(!replacement)
         {
            if(pattern is Array)
            {
               replacement = new Array(pattern.length);
            }
            else
            {
               return src.split(pattern).join("");
            }
         }
         if(!(pattern is Array))
         {
            return src.split(pattern).join(replacement);
         }
         var patternLength:Number = pattern.length;
         var result:String = src;
         if(replacement is Array)
         {
            for(i = 0; i < patternLength; i++)
            {
               r = "";
               if(replacement.length > i)
               {
                  r = replacement[i];
               }
               result = result.split(pattern[i]).join(r);
            }
         }
         else
         {
            for(i = 0; i < patternLength; )
            {
               result = result.split(pattern[i]).join(replacement);
               i++;
            }
         }
         return result;
      }
      
      public static function concatSameString(pString:String, pStringToConcat:String) : String
      {
         var firstIndex:int = pString.indexOf(pStringToConcat);
         var previousIndex:int = 0;
         for(var currentIndex:int = firstIndex; currentIndex != -1; )
         {
            previousIndex = currentIndex;
            currentIndex = pString.indexOf(pStringToConcat,previousIndex + 1);
            if(currentIndex == firstIndex)
            {
               break;
            }
            if(currentIndex == previousIndex + pStringToConcat.length)
            {
               pString = pString.substring(0,currentIndex) + pString.substring(currentIndex + pStringToConcat.length);
               currentIndex = currentIndex - pStringToConcat.length;
            }
         }
         return pString;
      }
      
      public static function getDelimitedText(pText:String, pFirstDelimiter:String, pSecondDelimiter:String, pIncludeDelimiter:Boolean = false) : Vector.<String>
      {
         var delimitedText:* = null;
         var firstPart:* = null;
         var secondPart:* = null;
         var returnedArray:Vector.<String> = new Vector.<String>();
         var exit:Boolean = false;
         for(var text:String = pText; !exit; )
         {
            delimitedText = getSingleDelimitedText(text,pFirstDelimiter,pSecondDelimiter,pIncludeDelimiter);
            if(delimitedText == "")
            {
               exit = true;
            }
            else
            {
               returnedArray.push(delimitedText);
               if(!pIncludeDelimiter)
               {
                  delimitedText = pFirstDelimiter + delimitedText + pSecondDelimiter;
               }
               for(firstPart = text.slice(0,text.indexOf(delimitedText)); firstPart.indexOf(pFirstDelimiter) != -1; )
               {
                  firstPart = firstPart.replace(pFirstDelimiter,"");
               }
               secondPart = text.slice(text.indexOf(delimitedText) + delimitedText.length);
               text = firstPart + secondPart;
            }
         }
         return returnedArray;
      }
      
      public static function getAllIndexOf(pStringLookFor:String, pWholeString:String) : Array
      {
         var nextIndex:int = 0;
         var returnedArray:Array = new Array();
         var exit:Boolean = false;
         for(var currentIndex:* = 0; !exit; )
         {
            nextIndex = pWholeString.indexOf(pStringLookFor,currentIndex);
            if(nextIndex < currentIndex)
            {
               exit = true;
            }
            else
            {
               returnedArray.push(nextIndex);
               currentIndex = uint(nextIndex + pStringLookFor.length);
            }
         }
         return returnedArray;
      }
      
      public static function noAccent(source:String) : String
      {
         if(pattern == null || patternReplace == null)
         {
            initPattern();
         }
         return decomposeUnicode(source);
      }
      
      private static function initPattern() : void
      {
         pattern = new Vector.<RegExp>(29,true);
         pattern[0] = /Š/g;
         pattern[1] = /Œ/g;
         pattern[2] = /Ž/g;
         pattern[3] = /š/g;
         pattern[4] = /œ/g;
         pattern[5] = /ž/g;
         pattern[6] = /[ÀÁÂÃÄÅ]/g;
         pattern[7] = /Æ/g;
         pattern[8] = /Ç/g;
         pattern[9] = /[ÈÉÊË]/g;
         pattern[10] = /[ÌÍÎÏ]/g;
         pattern[11] = /Ð/g;
         pattern[12] = /Ñ/g;
         pattern[13] = /[ÒÓÔÕÖØ]/g;
         pattern[14] = /[ÙÚÛÜ]/g;
         pattern[15] = /[ŸÝ]/g;
         pattern[16] = /Þ/g;
         pattern[17] = /ß/g;
         pattern[18] = /[àáâãäå]/g;
         pattern[19] = /æ/g;
         pattern[20] = /ç/g;
         pattern[21] = /[èéêë]/g;
         pattern[22] = /[ìíîï]/g;
         pattern[23] = /ð/g;
         pattern[24] = /ñ/g;
         pattern[25] = /[òóôõöø]/g;
         pattern[26] = /[ùúûü]/g;
         pattern[27] = /[ýÿ]/g;
         pattern[28] = /þ/g;
         patternReplace = new Vector.<String>(29,true);
         patternReplace[0] = "S";
         patternReplace[1] = "Oe";
         patternReplace[2] = "Z";
         patternReplace[3] = "s";
         patternReplace[4] = "oe";
         patternReplace[5] = "z";
         patternReplace[6] = "A";
         patternReplace[7] = "Ae";
         patternReplace[8] = "C";
         patternReplace[9] = "E";
         patternReplace[10] = "I";
         patternReplace[11] = "D";
         patternReplace[12] = "N";
         patternReplace[13] = "O";
         patternReplace[14] = "U";
         patternReplace[15] = "Y";
         patternReplace[16] = "Th";
         patternReplace[17] = "ss";
         patternReplace[18] = "a";
         patternReplace[19] = "ae";
         patternReplace[20] = "c";
         patternReplace[21] = "e";
         patternReplace[22] = "i";
         patternReplace[23] = "d";
         patternReplace[24] = "n";
         patternReplace[25] = "o";
         patternReplace[26] = "u";
         patternReplace[27] = "y";
         patternReplace[28] = "th";
      }
      
      private static function decomposeUnicode(str:String) : String
      {
         var i:int = 0;
         var j:int = 0;
         var len:int = str.length > accents.length?int(accents.length):int(str.length);
         var left:String = len == accents.length?str:accents;
         var right:String = len == accents.length?accents:str;
         for(i = 0; i < len; )
         {
            if(left.indexOf(right.charAt(i)) != -1)
            {
               for(j = 0; j < pattern.length; j++)
               {
                  str = str.replace(pattern[j],patternReplace[j]);
               }
               return str;
            }
            i++;
         }
         return str;
      }
      
      private static function getSingleDelimitedText(pStringEntry:String, pFirstDelimiter:String, pSecondDelimiter:String, pIncludeDelimiter:Boolean = false) : String
      {
         var firstDelimiterIndex:int = 0;
         var nextFirstDelimiterIndex:int = 0;
         var nextSecondDelimiterIndex:int = 0;
         var numFirstDelimiter:* = 0;
         var numSecondDelimiter:* = 0;
         var diff:int = 0;
         var delimitedContent:String = "";
         var currentIndex:* = 0;
         var secondDelimiterToSkip:* = 0;
         var exit:Boolean = false;
         firstDelimiterIndex = pStringEntry.indexOf(pFirstDelimiter,currentIndex);
         if(firstDelimiterIndex == -1)
         {
            return "";
         }
         for(currentIndex = uint(firstDelimiterIndex + pFirstDelimiter.length); !exit; )
         {
            nextFirstDelimiterIndex = pStringEntry.indexOf(pFirstDelimiter,currentIndex);
            nextSecondDelimiterIndex = pStringEntry.indexOf(pSecondDelimiter,currentIndex);
            if(nextSecondDelimiterIndex == -1)
            {
               exit = true;
            }
            if(nextFirstDelimiterIndex < nextSecondDelimiterIndex && nextFirstDelimiterIndex != -1)
            {
               secondDelimiterToSkip = uint(secondDelimiterToSkip + getAllIndexOf(pFirstDelimiter,pStringEntry.slice(nextFirstDelimiterIndex + pFirstDelimiter.length,nextSecondDelimiterIndex)).length);
               currentIndex = uint(nextSecondDelimiterIndex + pFirstDelimiter.length);
            }
            else if(secondDelimiterToSkip > 1)
            {
               currentIndex = uint(nextSecondDelimiterIndex + pSecondDelimiter.length);
               secondDelimiterToSkip--;
            }
            else
            {
               delimitedContent = pStringEntry.slice(firstDelimiterIndex,nextSecondDelimiterIndex + pSecondDelimiter.length);
               exit = true;
            }
         }
         if(delimitedContent != "")
         {
            if(!pIncludeDelimiter)
            {
               delimitedContent = delimitedContent.slice(pFirstDelimiter.length);
               delimitedContent = delimitedContent.slice(0,delimitedContent.length - pSecondDelimiter.length);
            }
            else
            {
               numFirstDelimiter = uint(getAllIndexOf(pFirstDelimiter,delimitedContent).length);
               numSecondDelimiter = uint(getAllIndexOf(pSecondDelimiter,delimitedContent).length);
               diff = numFirstDelimiter - numSecondDelimiter;
               if(diff > 0)
               {
                  while(diff > 0)
                  {
                     firstDelimiterIndex = delimitedContent.indexOf(pFirstDelimiter);
                     nextFirstDelimiterIndex = delimitedContent.indexOf(pFirstDelimiter,firstDelimiterIndex + pFirstDelimiter.length);
                     delimitedContent = delimitedContent.slice(nextFirstDelimiterIndex);
                     diff--;
                  }
               }
               else if(diff < 0)
               {
                  while(diff < 0)
                  {
                     delimitedContent = delimitedContent.slice(0,delimitedContent.lastIndexOf(pSecondDelimiter));
                     diff++;
                  }
               }
            }
         }
         return delimitedContent;
      }
      
      public static function kamasToString(kamas:Number, unit:String = "-") : String
      {
         if(unit == "-")
         {
            unit = I18n.getUiText("ui.common.short.kama",[]);
         }
         var kamaString:String = formateIntToString(kamas);
         if(unit == "")
         {
            return kamaString;
         }
         return kamaString + " " + unit;
      }
      
      public static function stringToKamas(string:String, unit:String = "-") : Number
      {
         var str2:* = null;
         var tmp:String = string;
         do
         {
            str2 = tmp;
            tmp = str2.replace(I18n.getUiText("ui.common.numberSeparator"),"");
         }
         while(str2 != tmp);
         
         do
         {
            str2 = tmp;
            tmp = str2.replace(" ","");
         }
         while(str2 != tmp);
         
         if(unit == "-")
         {
            unit = I18n.getUiText("ui.common.short.kama",[]);
         }
         if(str2.substr(str2.length - unit.length) == unit)
         {
            str2 = str2.substr(0,str2.length - unit.length);
         }
         var numberResult:* = Number(Number(str2));
         if(!numberResult || isNaN(numberResult))
         {
            numberResult = 0;
         }
         return numberResult;
      }
      
      public static function formateIntToString(val:Number, precision:int = 2) : String
      {
         var resultStrWithoutDecimal:* = null;
         var decimal:Number = NaN;
         var decimalStr:* = null;
         var numx3:int = 0;
         var str:String = "";
         var modulo:* = 1000;
         var numberSeparator:String = I18n.getUiText("ui.common.numberSeparator");
         var decimalNumber:Boolean = false;
         var valWithoutDecimal:Number = Math.floor(val);
         if(val != valWithoutDecimal)
         {
            decimalNumber = true;
            decimal = val - valWithoutDecimal;
            decimalStr = decimal.toFixed(precision);
         }
         while(valWithoutDecimal / modulo >= 1)
         {
            numx3 = int(valWithoutDecimal % modulo / (modulo / 1000));
            if(numx3 < 10)
            {
               str = "00" + numx3 + numberSeparator + str;
            }
            else if(numx3 < 100)
            {
               str = "0" + numx3 + numberSeparator + str;
            }
            else
            {
               str = numx3 + numberSeparator + str;
            }
            modulo = Number(modulo * 1000);
         }
         str = int(valWithoutDecimal % modulo / (modulo / 1000)) + numberSeparator + str;
         var f:* = str.charAt(str.length - 1);
         if(str.charAt(str.length - 1) == numberSeparator)
         {
            resultStrWithoutDecimal = str.substr(0,str.length - 1);
         }
         else
         {
            resultStrWithoutDecimal = str;
         }
         if(decimalNumber)
         {
            str = resultStrWithoutDecimal + decimalStr.slice(1);
            return str;
         }
         return resultStrWithoutDecimal;
      }
      
      public static function unescapeAllowedChar(original:String) : String
      {
         var unescapedString:String = unescape(original);
         unescapedString = unescapedString.split(">").join("&gt;");
         unescapedString = unescapedString.split("<").join("&lt;");
         unescapedString = unescapedString.split("&").join("&amp;");
         unescapedString = unescapedString.split("\"").join("&#34;");
         return unescapedString;
      }
   }
}
