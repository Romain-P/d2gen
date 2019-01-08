package com.ankamagames.jerakine.types
{
   import com.ankamagames.jerakine.enum.OperatingSystem;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.jerakine.utils.crypto.CRC32;
   import com.ankamagames.jerakine.utils.system.SystemManager;
   import flash.errors.IllegalOperationError;
   import flash.filesystem.File;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class Uri
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Uri));
      
      private static var _useSecureURI:Boolean = false;
      
      private static var _appPath:String;
      
      private static var _unescapeAppPath:String = unescape(File.applicationDirectory.nativePath);
      
      private static var _unescapeThemePath:String;
      
      private static var _osIsWindows:Boolean = SystemManager.getSingleton().os == OperatingSystem.WINDOWS;
       
      
      private var _protocol:String;
      
      private var _path:String;
      
      private var _subpath:String;
      
      private var _tag;
      
      private var _sum:String;
      
      private var _loaderContext:LoaderContext;
      
      private var _secureMode:Boolean;
      
      public function Uri(uri:String = null, secureMode:Boolean = true)
      {
         super();
         this._secureMode = secureMode;
         this.parseUri(uri);
      }
      
      public static function enableSecureURI() : void
      {
         _useSecureURI = true;
      }
      
      public static function set unescapeThemePath(v:String) : void
      {
         _unescapeThemePath = v;
      }
      
      public static function checkAbsolutePath(path:String) : Boolean
      {
         if(!_appPath)
         {
            _appPath = new Uri(File.applicationDirectory.nativePath).path;
         }
         return path.indexOf(_appPath) != -1;
      }
      
      public function get protocol() : String
      {
         return this._protocol;
      }
      
      public function set protocol(value:String) : void
      {
         this._protocol = value;
         this._sum = "";
      }
      
      public function get path() : String
      {
         if(_osIsWindows)
         {
            return this._path;
         }
         if(this._path && this._path.charAt(0) == "/" && this._path.charAt(1) != "/")
         {
            return "/" + this._path;
         }
         return this._path;
      }
      
      public function set path(value:String) : void
      {
         this._path = value.replace(/\\/g,"/");
         if(_osIsWindows)
         {
            this._path = this._path.replace(/^\/+/,"\\\\");
            this._path = this._path.replace("//","/");
         }
         this._sum = "";
      }
      
      public function get subPath() : String
      {
         return this._subpath;
      }
      
      public function set subPath(value:String) : void
      {
         this._subpath = !!value?value.substr(0,1) == "/"?value.substr(1):value:null;
         this._sum = "";
      }
      
      public function get uri() : String
      {
         return this.toString();
      }
      
      public function set uri(value:String) : void
      {
         this.parseUri(value);
      }
      
      public function get tag() : *
      {
         return this._tag;
      }
      
      public function set tag(value:*) : void
      {
         this._tag = value;
      }
      
      public function get loaderContext() : LoaderContext
      {
         return this._loaderContext;
      }
      
      public function set loaderContext(value:LoaderContext) : void
      {
         this._loaderContext = value;
      }
      
      public function get fileType() : String
      {
         var pointPos:int = 0;
         var paramPos:int = 0;
         if(!this._subpath || this._subpath.length == 0 || this._subpath.indexOf(".") == -1)
         {
            pointPos = this._path.lastIndexOf(".");
            paramPos = this._path.indexOf("?");
            return this._path.substr(pointPos + 1,paramPos != -1?Number(paramPos - pointPos - 1):Number(int.MAX_VALUE));
         }
         return this._subpath.substr(this._subpath.lastIndexOf(".") + 1,this._subpath.indexOf("?") != -1?Number(this._subpath.indexOf("?")):Number(int.MAX_VALUE));
      }
      
      public function get fileName() : String
      {
         if(!this._subpath || this._subpath.length == 0)
         {
            return this._path.substr(this._path.lastIndexOf("/") + 1);
         }
         return this._subpath.substr(this._subpath.lastIndexOf("/") + 1);
      }
      
      public function get normalizedUri() : String
      {
         switch(this._protocol)
         {
            case "http":
            case "https":
            case "file":
            case "zip":
            case "upd":
            case "mod":
            case "theme":
            case "d2p":
            case "d2pOld":
            case "pak":
            case "pak2":
               return this.replaceChar(this.uri,"\\","/");
            default:
               throw new IllegalOperationError("Unsupported protocol " + this._protocol + " for normalization.");
         }
      }
      
      public function get normalizedUriWithoutSubPath() : String
      {
         switch(this._protocol)
         {
            case "http":
            case "https":
            case "file":
            case "zip":
            case "upd":
            case "mod":
            case "theme":
            case "d2p":
            case "d2pOld":
            case "pak":
            case "pak2":
               return this.replaceChar(this.toString(false),"\\","/");
            default:
               throw new IllegalOperationError("Unsupported protocol " + this._protocol + " for normalization.");
         }
      }
      
      public function isSecure() : Boolean
      {
         var currentFile:* = null;
         var stack:* = null;
         try
         {
            currentFile = File.applicationDirectory.resolvePath(unescape(this._path));
            stack = _unescapeAppPath;
            while(unescape(currentFile.nativePath) != _unescapeAppPath)
            {
               currentFile = currentFile.parent;
               if(!currentFile)
               {
                  if(_unescapeThemePath)
                  {
                     currentFile = File.applicationDirectory.resolvePath(unescape(this._path));
                     stack = _unescapeThemePath;
                     while(unescape(currentFile.nativePath) != _unescapeThemePath)
                     {
                        currentFile = currentFile.parent;
                        if(currentFile)
                        {
                           stack = stack + (" -> " + unescape(currentFile.nativePath));
                           continue;
                        }
                     }
                     return true;
                  }
               }
               else
               {
                  stack = stack + (" -> " + unescape(currentFile.nativePath));
                  continue;
               }
            }
            return true;
         }
         catch(e:Error)
         {
         }
         _log.debug("URI not secure: " + _unescapeAppPath + "\nDetails: " + stack);
         return false;
      }
      
      public function toString(withSubPath:Boolean = true) : String
      {
         return this._protocol + "://" + this.path + (withSubPath && this._subpath && this._subpath.length > 0?"|" + this._subpath:"");
      }
      
      public function toSum() : String
      {
         if(this._sum.length > 0)
         {
            return this._sum;
         }
         var crc:CRC32 = new CRC32();
         var buf:ByteArray = new ByteArray();
         buf.writeUTF(this.normalizedUri);
         crc.update(buf);
         return this._sum = crc.getValue().toString(16);
      }
      
      public function toFile() : File
      {
         var uiRoot:* = null;
         var tmp:String = unescape(this._path);
         if(_osIsWindows && (tmp.indexOf("\\\\") == 0 || tmp.charAt(1) == ":"))
         {
            return new File(tmp);
         }
         if(!_osIsWindows && tmp.charAt(0) == "/")
         {
            return new File("/" + tmp);
         }
         if(this._protocol == "mod")
         {
            uiRoot = LangManager.getInstance().getEntry("config.mod.path");
            if(uiRoot.substr(0,2) != "\\\\" && uiRoot.substr(1,2) != ":/")
            {
               return new File(File.applicationDirectory.nativePath + File.separator + uiRoot + File.separator + tmp);
            }
            return new File(uiRoot + File.separator + tmp);
         }
         return new File(File.applicationDirectory.nativePath + File.separator + tmp);
      }
      
      private function parseUri(uri:String) : void
      {
         var pathWithoutProtocol:* = null;
         if(!uri)
         {
            return;
         }
         var strSplitResults:Array = uri.split("://");
         if(strSplitResults.length > 1)
         {
            this._protocol = strSplitResults[strSplitResults.length - 2];
            pathWithoutProtocol = strSplitResults[strSplitResults.length - 1];
         }
         else
         {
            this._protocol = "file";
            pathWithoutProtocol = uri;
         }
         strSplitResults = pathWithoutProtocol.split("|",2);
         this.path = strSplitResults[0];
         if(strSplitResults.length > 1 && strSplitResults[1])
         {
            this._subpath = strSplitResults[1].replace(/^\/*/,"");
         }
         else
         {
            this._subpath = null;
         }
         if(this._secureMode && _useSecureURI && this._protocol == "file" && !this.isSecure())
         {
            throw new ArgumentError("\'" + uri + "\' is a unsecure URI.");
         }
      }
      
      private function replaceChar(str:String, search:String, replace:String) : String
      {
         return str.split(search).join(replace);
      }
   }
}
