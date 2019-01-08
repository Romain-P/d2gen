package com.ankamagames.jerakine.logger
{
   public final class LogLevel
   {
      
      public static const TRACE:uint = 1;
      
      public static const DEBUG:uint = 2;
      
      public static const INFO:uint = 4;
      
      public static const WARN:uint = 8;
      
      public static const ERROR:uint = 16;
      
      public static const FATAL:uint = 32;
      
      public static const COMMANDS:uint = 64;
       
      
      public function LogLevel()
      {
         super();
      }
      
      public static function getString(level:uint) : String
      {
         switch(level)
         {
            case TRACE:
               return "TRACE";
            case DEBUG:
               return "DEBUG";
            case INFO:
               return "INFO";
            case WARN:
               return "WARN";
            case ERROR:
               return "ERROR";
            case FATAL:
               return "FATAL";
            default:
               return "UNKNOWN";
         }
      }
   }
}
