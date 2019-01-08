package com.ankamagames.berilia.api
{
   import com.ankamagames.berilia.managers.SecureCenter;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.berilia.utils.errors.ApiError;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.utils.misc.CallWithParameters;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class ApiBinder
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(ApiBinder));
      
      private static var _apiClass:Array = new Array();
      
      private static var _apiInstance:Array = new Array();
      
      private static var _apiData:Array = new Array();
      
      private static var _isComplexFctCache:Dictionary = new Dictionary();
       
      
      public function ApiBinder()
      {
         super();
      }
      
      public static function addApi(name:String, apiClass:Class) : void
      {
         _apiClass[getQualifiedClassName(apiClass)] = apiClass;
      }
      
      public static function removeApi(apiClass:Class) : void
      {
         delete _apiClass[getQualifiedClassName(apiClass)];
      }
      
      public static function reset() : void
      {
         _apiInstance = [];
         _apiData = [];
      }
      
      public static function addApiData(name:String, value:*) : void
      {
         _apiData[name] = value;
      }
      
      public static function getApiData(name:String) : *
      {
         return _apiData[name];
      }
      
      public static function removeApiData(name:String) : void
      {
         _apiData[name] = null;
      }
      
      public static function initApi(target:Object, module:UiModule, sharedDefinition:ApplicationDomain = null) : String
      {
         var api:* = null;
         var metaTag:* = null;
         var metaData:* = undefined;
         var modName:* = null;
         addApiData("module",module);
         var desc:XML = DescribeTypeCache.typeDescription(target);
         for each(metaTag in desc..variable)
         {
            if(_apiClass[metaTag.@type.toString()])
            {
               api = getApiInstance(metaTag.@type.toString());
               module.apiList.push(api);
               target[metaTag.@name] = api;
            }
            else
            {
               for each(metaData in metaTag.metadata)
               {
                  if(metaData.@name == "Module")
                  {
                     if(metaData.arg.@key == "name")
                     {
                        modName = metaData.arg.@value;
                        if(!UiModuleManager.getInstance().getModules()[modName])
                        {
                           throw new ApiError("Module " + modName + " does not exist (in " + module.id + ")");
                        }
                        if(module.trusted || modName == "Ankama_Common" || modName == "Ankama_ContextMenu" || !UiModuleManager.getInstance().getModules()[modName].trusted)
                        {
                           target[metaTag.@name] = new ModuleReference(UiModule(UiModuleManager.getInstance().getModules()[modName]).mainClass,SecureCenter.ACCESS_KEY);
                           continue;
                        }
                        throw new ApiError(module.id + ", untrusted module cannot acces to trusted modules " + modName);
                     }
                     throw new ApiError(module.id + " module, unknow property \"" + metaData.arg.@key + "\" in Api tag");
                  }
               }
            }
         }
         return null;
      }
      
      private static function getApiInstance(name:String) : Object
      {
         var apiDesc:* = null;
         var instancied:Boolean = false;
         var meta:* = null;
         var api:* = null;
         var accessor:* = null;
         var metaData2:* = undefined;
         if(_apiInstance[name] && _apiInstance[name])
         {
            return _apiInstance[name];
         }
         if(_apiClass[name])
         {
            apiDesc = DescribeTypeCache.typeDescription(_apiClass[name]);
            instancied = false;
            for each(meta in apiDesc..metadata)
            {
               if(meta.@name == "InstanciedApi")
               {
                  instancied = true;
                  break;
               }
            }
            api = new (_apiClass[name] as Class)();
            for each(accessor in apiDesc..accessor)
            {
               for each(metaData2 in accessor.metadata)
               {
                  if(metaData2.@name == "ApiData")
                  {
                     api[accessor.@name] = _apiData[metaData2.arg.@value];
                     break;
                  }
               }
            }
            if(!instancied)
            {
               _apiInstance[name] = api;
            }
            return api;
         }
         _log.error("Api [" + name + "] is not avaible");
         return null;
      }
      
      private static function isComplexFct(methodDesc:XML) : Boolean
      {
         var paramType:* = null;
         var cacheKey:String = methodDesc.@declaredBy + "_" + methodDesc.@name;
         if(_isComplexFctCache[cacheKey] != null)
         {
            return _isComplexFctCache[cacheKey];
         }
         var simpleType:* = ["int","uint","Number","Boolean","String","void"];
         if(simpleType.indexOf(methodDesc.@returnType.toString()) == -1)
         {
            _isComplexFctCache[cacheKey] = false;
            return false;
         }
         for each(paramType in methodDesc..parameter..@type)
         {
            if(simpleType.indexOf(paramType) == -1)
            {
               _isComplexFctCache[cacheKey] = false;
               return false;
            }
         }
         _isComplexFctCache[cacheKey] = true;
         return true;
      }
      
      private static function createDepreciatedMethod(fct:Function, fctName:String, help:String) : Function
      {
         return function(... args):*
         {
            var e:* = new Error();
            if(e.getStackTrace())
            {
               _log.fatal(fctName + " is a deprecated api function, called at " + e.getStackTrace().split("at ")[2] + (!!help.length?help + "\n":""));
            }
            else
            {
               _log.fatal(fctName + " is a deprecated api function. No stack trace available");
            }
            return CallWithParameters.callR(fct,args);
         };
      }
   }
}
