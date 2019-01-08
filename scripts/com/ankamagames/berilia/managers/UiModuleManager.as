package com.ankamagames.berilia.managers
{
   import by.blooddy.crypto.MD5;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.api.ApiBinder;
   import com.ankamagames.berilia.components.TextureBase;
   import com.ankamagames.berilia.types.data.PreCompiledUiModule;
   import com.ankamagames.berilia.types.data.UiData;
   import com.ankamagames.berilia.types.data.UiGroup;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.berilia.types.event.ParsingErrorEvent;
   import com.ankamagames.berilia.types.event.ParsorEvent;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.types.messages.AllModulesLoadedMessage;
   import com.ankamagames.berilia.types.messages.AllUiXmlParsedMessage;
   import com.ankamagames.berilia.types.messages.ModuleLoadedMessage;
   import com.ankamagames.berilia.types.messages.ModuleRessourceLoadFailedMessage;
   import com.ankamagames.berilia.types.messages.UiXmlParsedErrorMessage;
   import com.ankamagames.berilia.types.messages.UiXmlParsedMessage;
   import com.ankamagames.berilia.types.shortcut.Shortcut;
   import com.ankamagames.berilia.types.shortcut.ShortcutCategory;
   import com.ankamagames.berilia.types.uiDefinition.UiDefinition;
   import com.ankamagames.berilia.uiRender.XmlParsor;
   import com.ankamagames.berilia.utils.ModProtocol;
   import com.ankamagames.berilia.utils.UriCacheFactory;
   import com.ankamagames.berilia.utils.errors.UntrustedApiCallError;
   import com.ankamagames.dofus.logic.game.fight.steps.FightExchangePositionsStep;
   import com.ankamagames.dofus.logic.game.roleplay.types.Fight;
   import com.ankamagames.dofus.logic.game.roleplay.types.FightTeam;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamMemberInformations;
   import com.ankamagames.jerakine.JerakineConstants;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.jerakine.newCache.ICache;
   import com.ankamagames.jerakine.newCache.garbage.LruGarbageCollector;
   import com.ankamagames.jerakine.newCache.impl.Cache;
   import com.ankamagames.jerakine.pools.Pool;
   import com.ankamagames.jerakine.pools.PoolableSound;
   import com.ankamagames.jerakine.resources.ResourceType;
   import com.ankamagames.jerakine.resources.adapters.impl.TxtAdapter;
   import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
   import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
   import com.ankamagames.jerakine.resources.events.ResourceLoaderProgressEvent;
   import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
   import com.ankamagames.jerakine.resources.protocols.ProtocolFactory;
   import com.ankamagames.jerakine.sequencer.CallbackStep;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.jerakine.utils.display.EnterFrameDispatcher;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.jerakine.utils.files.FileUtils;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import com.ankamagames.jerakine.utils.system.AirScanner;
   import com.ankamagames.tiphon.display.TiphonAnimation;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import com.ankamagames.tiphon.events.TiphonEvent;
   import com.ankamagames.tiphon.types.ScriptedAnimation;
   import com.hurlant.util.Memory;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class UiModuleManager
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(UiModuleManager));
      
      private static const _lastModulesToUnload:Array = ["Ankama_GameUiCore","Ankama_Common","Ankama_Tooltips","Ankama_ContextMenu"];
      
      private static var _self:UiModuleManager;
       
      
      private var _loader:IResourceLoader;
      
      private var _uiLoader:IResourceLoader;
      
      private var _scriptNum:uint;
      
      private var _modules:Array;
      
      private var _preprocessorIndex:Dictionary;
      
      private var _uiFiles:Array;
      
      private var _regImport:RegExp;
      
      private var _versions:Array;
      
      private var _clearUi:Array;
      
      private var _uiFileToLoad:uint;
      
      private var _moduleCount:uint = 0;
      
      private var _cacheLoader:IResourceLoader;
      
      private var _unparsedXml:Array;
      
      private var _unparsedXmlCount:uint;
      
      private var _unparsedXmlTotalCount:uint;
      
      private var _modulesRoot:File;
      
      private var _modulesPaths:Dictionary;
      
      private var _modulesHashs:Dictionary;
      
      private var _resetState:Boolean;
      
      private var _parserAvaibleCount:uint = 2;
      
      private var _unInitializedModules:Array;
      
      private var _bytesToLoad:Array;
      
      private var _moduleLoaders:Dictionary;
      
      private var _loadingModule:Dictionary;
      
      private var _disabledModules:Array;
      
      private var _timeOutFrameNumber:int;
      
      private var _filter:Array;
      
      private var _filterInclude:Boolean;
      
      public var isDevMode:Boolean = false;
      
      private var _moduleScriptLoadedRef:Dictionary;
      
      private var _uiLoaded:Dictionary;
      
      private var _trustedModuleScripts:Array;
      
      public function UiModuleManager()
      {
         this._regImport = /<Import *url *= *"([^"]*)/g;
         this._modulesHashs = new Dictionary();
         this._bytesToLoad = new Array();
         this._moduleScriptLoadedRef = new Dictionary();
         this._uiLoaded = new Dictionary();
         super();
         if(_self)
         {
            throw new SingletonError();
         }
         this._loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._loader.addEventListener(ResourceErrorEvent.ERROR,this.onLoadError,false,0,true);
         this._loader.addEventListener(ResourceLoadedEvent.LOADED,this.onLoad,false,0,true);
         this._uiLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._uiLoader.addEventListener(ResourceErrorEvent.ERROR,this.onUiLoadError,false,0,true);
         this._uiLoader.addEventListener(ResourceLoadedEvent.LOADED,this.onUiLoaded,false,0,true);
         this._cacheLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._moduleLoaders = new Dictionary();
      }
      
      public static function getInstance() : UiModuleManager
      {
         if(!_self)
         {
            _self = new UiModuleManager();
         }
         return _self;
      }
      
      public function get unInitializedModules() : Array
      {
         return this._unInitializedModules;
      }
      
      public function get moduleCount() : uint
      {
         return this._moduleCount;
      }
      
      public function get unparsedXmlCount() : uint
      {
         return this._unparsedXmlCount;
      }
      
      public function get unparsedXmlTotalCount() : uint
      {
         return this._unparsedXmlTotalCount;
      }
      
      public function get ready() : Boolean
      {
         return this._moduleCount > 0;
      }
      
      public function get modulesHashs() : Dictionary
      {
         return this._modulesHashs;
      }
      
      public function init(filter:Array, filterInclude:Boolean) : void
      {
         var uri:* = null;
         var file:* = null;
         this._filter = filter;
         this._filterInclude = filterInclude;
         this._resetState = false;
         this._modules = new Array();
         this._preprocessorIndex = new Dictionary(true);
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._versions = new Array();
         this._clearUi = new Array();
         this._uiFiles = new Array();
         this._modulesPaths = new Dictionary();
         this._unInitializedModules = new Array();
         this._loadingModule = new Dictionary();
         this._disabledModules = [];
         ProtocolFactory.addProtocol("mod",ModProtocol);
         var uiRoot:String = LangManager.getInstance().getEntry("config.mod.path");
         if(uiRoot.substr(0,2) != "\\\\" && uiRoot.substr(1,2) != ":/")
         {
            this._modulesRoot = new File(File.applicationDirectory.nativePath + File.separator + uiRoot);
         }
         else
         {
            this._modulesRoot = new File(uiRoot);
         }
         if(Berilia.getInstance().checkModuleAuthority)
         {
            uri = new Uri(this._modulesRoot.nativePath + "/hash.metas");
            this._loader.load(uri);
         }
         BindsManager.getInstance().initialize();
         if(this._modulesRoot.exists)
         {
            for each(file in this._modulesRoot.getDirectoryListing())
            {
               if(!(!file.isDirectory || file.name.charAt(0) == "."))
               {
                  if(filter.indexOf(file.name) != -1 == filterInclude)
                  {
                     this.loadModule(file.name);
                  }
               }
            }
            return;
         }
         ErrorManager.addError("Impossible de trouver le dossier contenant les modules (url: " + LangManager.getInstance().getEntry("config.mod.path") + ")");
      }
      
      public function lightInit(moduleList:Vector.<UiModule>) : void
      {
         var m:* = null;
         this._resetState = false;
         this._modules = new Array();
         this._modulesPaths = new Dictionary();
         for each(m in moduleList)
         {
            this._modules[m.id] = m;
            this._modulesPaths[m.id] = m.rootPath;
         }
      }
      
      public function getModules() : Array
      {
         return this._modules;
      }
      
      public function getModule(name:String, includeUnInitialized:Boolean = false) : UiModule
      {
         var module:* = null;
         if(this._modules)
         {
            module = this._modules[name];
         }
         if(!module && includeUnInitialized && this._unInitializedModules)
         {
            module = this._unInitializedModules[name];
         }
         return module;
      }
      
      public function get disabledModules() : Array
      {
         return this._disabledModules;
      }
      
      public function reset() : void
      {
         var module:* = null;
         var i:int = 0;
         _log.warn("Reset des modules");
         this._resetState = true;
         if(this._loader)
         {
            this._loader.cancel();
         }
         if(this._cacheLoader)
         {
            this._cacheLoader.cancel();
         }
         if(this._uiLoader)
         {
            this._uiLoader.cancel();
         }
         TooltipManager.clearCache();
         for each(module in this._modules)
         {
            if(_lastModulesToUnload.indexOf(module.id) == -1)
            {
               this.unloadModule(module.id);
            }
         }
         for(i = 0; i < _lastModulesToUnload.length; )
         {
            if(this._modules[_lastModulesToUnload[i]])
            {
               this.unloadModule(_lastModulesToUnload[i]);
            }
            i++;
         }
         Shortcut.reset();
         Berilia.getInstance().reset();
         ApiBinder.reset();
         UiPerformanceManager.getInstance().reset();
         TextureBase.clearCache();
         KernelEventsManager.getInstance().initialize();
         this._modules = [];
         this._uiFileToLoad = 0;
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._parserAvaibleCount = 2;
         this._modulesPaths = new Dictionary();
      }
      
      public function getModulePath(moduleName:String) : String
      {
         return this._modulesPaths[moduleName];
      }
      
      public function loadModule(id:String) : void
      {
         var dmFile:* = null;
         var uri:* = null;
         var modulePath:* = null;
         var len:int = 0;
         var substr:* = null;
         this.unloadModule(id);
         var targetedModuleFolder:File = this._modulesRoot.resolvePath(id);
         if(targetedModuleFolder.exists)
         {
            dmFile = this.searchDmFile(targetedModuleFolder);
            if(dmFile)
            {
               this._moduleCount++;
               this._scriptNum++;
               if(dmFile.nativePath.indexOf("app:/") == 0)
               {
                  len = 5;
                  substr = dmFile.nativePath.substring(len,dmFile.url.length);
                  uri = new Uri(substr);
                  modulePath = substr.substr(0,substr.lastIndexOf("/"));
               }
               else
               {
                  uri = new Uri(dmFile.nativePath);
                  modulePath = dmFile.parent.nativePath;
               }
               uri.tag = dmFile;
               this._modulesPaths[id] = modulePath;
               this._loader.load(uri);
            }
            else
            {
               _log.error("Cannot found .dm or .d2ui file in " + targetedModuleFolder.url);
            }
         }
      }
      
      public function unloadModule(id:String) : void
      {
         var uiCtr:UiRootContainer = null;
         var ui:String = null;
         var group:UiGroup = null;
         var variables:Array = null;
         var varName:String = null;
         var apiList:Vector.<Object> = null;
         var api:Object = null;
         if(this._modules == null)
         {
            return;
         }
         var m:UiModule = this._modules[id];
         if(!m)
         {
            return;
         }
         var moduleUiInstances:Array = [];
         for each(uiCtr in Berilia.getInstance().uiList)
         {
            if(uiCtr.uiModule == m)
            {
               moduleUiInstances.push(uiCtr.name);
            }
         }
         for each(ui in moduleUiInstances)
         {
            Berilia.getInstance().unloadUi(ui);
         }
         for each(group in m.groups)
         {
            UiGroupManager.getInstance().removeGroup(group.name);
         }
         variables = DescribeTypeCache.getVariables(m.mainClass,true);
         for each(varName in variables)
         {
            if(m.mainClass[varName] is Object)
            {
               m.mainClass[varName] = null;
            }
         }
         m.destroy();
         apiList = m.apiList;
         while(apiList.length)
         {
            api = apiList.shift();
            if(api && api.hasOwnProperty("destroy"))
            {
               try
               {
                  api["destroy"]();
               }
               catch(e:UntrustedApiCallError)
               {
                  api["destroy"](SecureCenter.ACCESS_KEY);
                  continue;
               }
            }
         }
         if(m.mainClass && m.mainClass.hasOwnProperty("unload"))
         {
            m.mainClass["unload"]();
         }
         BindsManager.getInstance().removeAllEventListeners("__module_" + m.id);
         KernelEventsManager.getInstance().removeAllEventListeners("__module_" + m.id);
         delete this._modules[id];
         this._disabledModules[id] = m;
      }
      
      private function launchModule() : void
      {
         var module:* = null;
         var missingName:* = null;
         var missingModule:* = null;
         var notLoaded:* = null;
         var m:* = null;
         var ts:* = 0;
         var modules:Array = new Array();
         for each(module in this._unInitializedModules)
         {
            if(module.trusted)
            {
               modules.unshift(module);
            }
            else
            {
               modules.push(module);
            }
         }
         while(modules.length > 0)
         {
            notLoaded = new Array();
            for each(m in modules)
            {
               ApiBinder.addApiData("currentUi",null);
               missingName = ApiBinder.initApi(m.mainClass,m);
               if(missingName)
               {
                  missingModule = m;
                  notLoaded.push(m);
               }
               else if(m.mainClass)
               {
                  delete this._unInitializedModules[m.id];
                  ts = uint(getTimer());
                  ErrorManager.tryFunction(m.mainClass.main,null,"Une erreur est survenue lors de l\'appel à la fonction main() du module " + m.id);
               }
               else
               {
                  _log.error("Impossible d\'instancier la classe principale du module " + m.id);
               }
            }
            if(notLoaded.length == modules.length)
            {
               ErrorManager.addError("Le module " + missingModule.id + " demande une référence vers un module inexistant : " + missingName);
            }
            modules = notLoaded;
         }
         Berilia.getInstance().handler.process(new AllModulesLoadedMessage());
      }
      
      private function launchUiCheck() : void
      {
         this._uiFileToLoad = this._uiFiles.length;
         if(this._uiFiles.length)
         {
            this._uiLoader.load(this._uiFiles,null,TxtAdapter);
         }
         else
         {
            this.onAllUiChecked(null);
         }
      }
      
      private function processCachedFiles(files:Array) : void
      {
         var uri:* = null;
         var file:* = null;
         var c:* = null;
         for each(file in files)
         {
            switch(file.fileType.toLowerCase())
            {
               case "css":
                  CssManager.getInstance().load(file.uri);
                  continue;
               case "jpg":
               case "png":
                  uri = new Uri(FileUtils.getFilePath(file.normalizedUri));
                  c = UriCacheFactory.getCacheFromUri(uri);
                  if(!c)
                  {
                     c = UriCacheFactory.init(uri.uri,new Cache(files.length,new LruGarbageCollector()));
                  }
                  this._cacheLoader.load(file,c);
                  continue;
               default:
                  _log.error("Impossible de mettre en cache le fichier " + file.uri + ", le type n\'est pas supporté (uniquement css, jpg et png)");
                  continue;
            }
         }
      }
      
      private function onLoadError(e:ResourceErrorEvent) : void
      {
         _log.error("onLoadError() - " + e.errorMsg);
         if(e.uri.fileType != "metas")
         {
            Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(e.uri.tag,e.uri));
         }
         switch(e.uri.fileType.toLowerCase())
         {
            case "swfs":
               ErrorManager.addError("Impossible de charger le fichier " + e.uri + " (" + e.errorMsg + ")");
               if(!--this._scriptNum)
               {
                  this.launchUiCheck();
                  break;
               }
               break;
            case "metas":
               break;
            default:
               ErrorManager.addError("Impossible de charger le fichier " + e.uri + " (" + e.errorMsg + ")");
         }
      }
      
      private function onUiLoadError(e:ResourceErrorEvent) : void
      {
         ErrorManager.addError("Impossible de charger le fichier d\'interface " + e.uri + " (" + e.errorMsg + ")");
         Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(e.uri.tag,e.uri));
         this._uiFileToLoad--;
      }
      
      private function onLoad(e:ResourceLoadedEvent) : void
      {
         if(this._resetState)
         {
            return;
         }
         switch(e.uri.fileType.toLowerCase())
         {
            case "swf":
            case "swfs":
               this.onScriptLoad(e);
               break;
            case "d2ui":
            case "dm":
               this.onDMLoad(e);
               break;
            case "xml":
               this.onShortcutLoad(e);
               break;
            case "metas":
               this.onHashLoaded(e);
         }
      }
      
      private function onDMLoad(e:ResourceLoadedEvent) : void
      {
         var um:* = null;
         var uiUri:* = null;
         var currentFile:* = null;
         var path:* = null;
         var scriptClass:* = null;
         var moduleLoader:* = null;
         var lc:* = null;
         var scriptBytes:* = null;
         var shortcutsUri:* = null;
         var ui:* = null;
         var dirFiles:* = null;
         var dirFile:* = null;
         if(e.resourceType == ResourceType.RESOURCE_XML)
         {
            um = UiModule.createFromXml(e.resource as XML,FileUtils.getFilePath(e.uri.path),File(e.uri.tag).parent.name);
         }
         else
         {
            um = PreCompiledUiModule.fromRaw(e.resource,FileUtils.getFilePath(e.uri.path),File(e.uri.tag).parent.name);
         }
         this._unInitializedModules[um.id] = um;
         if(um.script)
         {
            scriptClass = this._trustedModuleScripts[um.id.toUpperCase()];
            if(scriptClass)
            {
               moduleLoader = new Loader();
               moduleLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,ErrorManager.onUncaughtError,false,0,true);
               this._moduleScriptLoadedRef[moduleLoader] = um;
               um.trusted = true;
               lc = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
               AirScanner.allowByteCodeExecution(lc,true);
               moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
               scriptBytes = new scriptClass() as ByteArray;
               if(!um.shortcuts)
               {
                  moduleLoader.loadBytes(scriptBytes,lc);
               }
               else
               {
                  this._bytesToLoad[um.id] = {
                     "moduleLoader":moduleLoader,
                     "scriptBytes":scriptBytes,
                     "lc":lc
                  };
               }
            }
            else
            {
               _log.error("Script from module " + um.id + " has not been embedded, module failed to load");
               this._moduleCount--;
               this._scriptNum--;
               um.trusted = false;
               return;
            }
         }
         if(!um.enable)
         {
            _log.fatal("Le module " + um.id + " est désactivé");
            this._moduleCount--;
            this._scriptNum--;
            this._disabledModules[um.id] = um;
            return;
         }
         if(um.shortcuts)
         {
            shortcutsUri = new Uri(um.shortcuts);
            shortcutsUri.tag = um.id;
            this._loader.load(shortcutsUri);
         }
         if(um.trusted)
         {
            this._loadingModule[um] = um.id;
            var files:Array = new Array();
            if(!(um is PreCompiledUiModule))
            {
               for each(ui in um.uis)
               {
                  if(ui.file)
                  {
                     uiUri = new Uri(ui.file);
                     uiUri.tag = {
                        "mod":um.id,
                        "base":ui.file
                     };
                     this._uiFiles.push(uiUri);
                  }
               }
            }
            var root:File = this._modulesRoot.resolvePath(um.id);
            files = new Array();
            for each(path in um.cachedFiles)
            {
               currentFile = root.resolvePath(path);
               if(currentFile.exists)
               {
                  if(!currentFile.isDirectory)
                  {
                     files.push(new Uri("mod://" + um.id + "/" + path));
                  }
                  else
                  {
                     dirFiles = currentFile.getDirectoryListing();
                     for each(dirFile in dirFiles)
                     {
                        if(!dirFile.isDirectory)
                        {
                           files.push(new Uri("mod://" + um.id + "/" + path + "/" + FileUtils.getFileName(dirFile.url)));
                        }
                     }
                  }
               }
            }
            this.processCachedFiles(files);
            return;
         }
         this._moduleCount--;
         this._scriptNum--;
         ErrorManager.addError("Failed to load custom module " + um.author + "_" + um.name + ", because the local HTTP server is not available.");
      }
      
      private function onScriptLoadFail(e:IOErrorEvent, uiModule:UiModule) : void
      {
         _log.error("Le script du module " + uiModule.id + " est introuvable");
         if(!--this._scriptNum)
         {
            this.launchUiCheck();
         }
      }
      
      private function onScriptLoad(e:ResourceLoadedEvent) : void
      {
         var uiModule:UiModule = this._unInitializedModules[e.uri.tag];
         var moduleLoader:Loader = new Loader();
         moduleLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,ErrorManager.onUncaughtError,false,0,true);
         this._moduleScriptLoadedRef[moduleLoader] = uiModule;
         var lc:LoaderContext = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
         AirScanner.allowByteCodeExecution(lc,true);
         moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
         moduleLoader.loadBytes(e.resource as ByteArray,lc);
      }
      
      private function onModuleScriptLoaded(e:Event, uiModule:UiModule = null) : void
      {
         var l:Loader = LoaderInfo(e.target).loader;
         l.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
         if(!uiModule)
         {
            uiModule = this._moduleScriptLoadedRef[l];
         }
         delete this._loadingModule[uiModule];
         _log.trace("Load script " + uiModule.id + ", " + (this._moduleCount - this._scriptNum + 1) + "/" + this._moduleCount);
         uiModule.loader = l;
         uiModule.applicationDomain = l.contentLoaderInfo.applicationDomain;
         uiModule.mainClass = l.content;
         this._modules[uiModule.id] = uiModule;
         delete this._disabledModules[uiModule.id];
         Berilia.getInstance().handler.process(new ModuleLoadedMessage(uiModule.id));
         if(!--this._scriptNum)
         {
            this.launchUiCheck();
         }
      }
      
      private function onShortcutLoad(e:ResourceLoadedEvent) : void
      {
         var category:* = null;
         var obj:* = undefined;
         var cat:* = null;
         var permanent:Boolean = false;
         var visible:Boolean = false;
         var required:Boolean = false;
         var holdKeys:Boolean = false;
         var shortcut:* = null;
         var shortcutsXml:XML = e.resource;
         for each(category in shortcutsXml..category)
         {
            cat = ShortcutCategory.create(category.@name,LangManager.getInstance().replaceKey(category.@description));
            for each(shortcut in category..shortcut)
            {
               if(!shortcut.@name || !shortcut.@name.toString().length)
               {
                  ErrorManager.addError("Le fichier de raccourci est mal formé, il manque la priopriété name dans le fichier " + e.uri);
                  return;
               }
               permanent = false;
               if(shortcut.@permanent && shortcut.@permanent == "true")
               {
                  permanent = true;
               }
               visible = true;
               if(shortcut.@visible && shortcut.@visible == "false")
               {
                  visible = false;
               }
               required = false;
               if(shortcut.@required && shortcut.@required == "true")
               {
                  required = true;
               }
               holdKeys = false;
               if(shortcut.@holdKeys && shortcut.@holdKeys == "true")
               {
                  holdKeys = true;
               }
               new Shortcut(shortcut.@name,shortcut.@textfieldEnabled == "true",LangManager.getInstance().replaceKey(shortcut.toString()),cat,!permanent,visible,required,holdKeys,LangManager.getInstance().replaceKey(shortcut.@tooltipContent),shortcut.@admin == "true");
            }
         }
         obj = this._bytesToLoad[e.uri.tag];
         if(obj)
         {
            obj.moduleLoader.loadBytes(obj.scriptBytes,obj.lc);
            delete this._bytesToLoad[e.uri.tag];
         }
      }
      
      private function onHashLoaded(e:ResourceLoadedEvent) : void
      {
         var file:* = null;
         for each(file in e.resource..file)
         {
            this._modulesHashs[file.@name.toString()] = file.toString();
         }
      }
      
      private function onAllUiChecked(e:ResourceLoaderProgressEvent) : void
      {
         var module:* = null;
         var url:* = null;
         var ui:* = null;
         var uiDataList:Array = new Array();
         for each(module in this._unInitializedModules)
         {
            for each(ui in module.uis)
            {
               uiDataList[UiData(ui).file] = ui;
            }
         }
         this._unparsedXml = [];
         for(url in this._clearUi)
         {
            UiRenderManager.getInstance().clearCacheFromId(url);
            UiRenderManager.getInstance().setUiVersion(url,this._clearUi[url]);
            if(uiDataList[url])
            {
               this._unparsedXml.push(uiDataList[url]);
            }
         }
         this._unparsedXmlCount = this._unparsedXmlTotalCount = this._unparsedXml.length;
         this.parseNextXml();
      }
      
      private function parseNextXml() : void
      {
         var uiData:* = null;
         var xmlParsor:* = null;
         this._unparsedXmlCount = this._unparsedXml.length;
         if(this._unparsedXml.length)
         {
            if(this._parserAvaibleCount)
            {
               this._parserAvaibleCount--;
               uiData = this._unparsedXml.shift() as UiData;
               xmlParsor = new XmlParsor();
               xmlParsor.rootPath = uiData.module.rootPath;
               xmlParsor.addEventListener(Event.COMPLETE,this.onXmlParsed,false,0,true);
               xmlParsor.addEventListener(ParsingErrorEvent.ERROR,this.onXmlParsingError);
               xmlParsor.processFile(uiData.file);
            }
         }
         else
         {
            BindsManager.getInstance().checkBinds();
            Berilia.getInstance().handler.process(new AllUiXmlParsedMessage());
            this.launchModule();
         }
      }
      
      private function onXmlParsed(e:ParsorEvent) : void
      {
         if(e.uiDefinition)
         {
            e.uiDefinition.name = XmlParsor(e.target).url;
            UiRenderManager.getInstance().setUiDefinition(e.uiDefinition);
            Berilia.getInstance().handler.process(new UiXmlParsedMessage(e.uiDefinition.name));
         }
         this._parserAvaibleCount++;
         this.parseNextXml();
      }
      
      private function onXmlParsingError(e:ParsingErrorEvent) : void
      {
         Berilia.getInstance().handler.process(new UiXmlParsedErrorMessage(e.url,e.msg));
      }
      
      private function onUiLoaded(e:ResourceLoadedEvent) : void
      {
         var res:* = null;
         var filePath:* = null;
         var modName:* = null;
         var templateUri:* = null;
         if(this._resetState)
         {
            return;
         }
         var uriPos:int = this._uiFiles.indexOf(e.uri);
         this._uiFiles.splice(this._uiFiles.indexOf(e.uri),1);
         var mod:UiModule = this._unInitializedModules[e.uri.tag.mod];
         var base:String = e.uri.tag.base;
         var md5:String = this._versions[e.uri.uri] != null?this._versions[e.uri.uri]:MD5.hash(e.resource as String);
         var versionOk:Boolean = md5 == UiRenderManager.getInstance().getUiVersion(e.uri.uri);
         if(!versionOk)
         {
            this._clearUi[e.uri.uri] = md5;
            if(e.uri.tag.template)
            {
               this._clearUi[e.uri.tag.base] = this._versions[e.uri.tag.base];
            }
         }
         this._versions[e.uri.uri] = md5;
         for(var xml:String = e.resource as String; res = this._regImport.exec(xml); )
         {
            filePath = LangManager.getInstance().replaceKey(res[1]);
            if(filePath.indexOf("mod://") != -1)
            {
               modName = filePath.substr(6,filePath.indexOf("/",6) - 6);
               filePath = this._modulesPaths[modName] + filePath.substr(6 + modName.length);
            }
            else if(filePath.indexOf(":") == -1 && filePath.indexOf("ui/Ankama_Common") == -1)
            {
               filePath = mod.rootPath + filePath;
            }
            if(this._clearUi[filePath])
            {
               this._clearUi[e.uri.uri] = md5;
               this._clearUi[base] = this._versions[base];
            }
            else if(!this._uiLoaded[filePath])
            {
               this._uiLoaded[filePath] = true;
               this._uiFileToLoad++;
               templateUri = new Uri(filePath);
               templateUri.tag = {
                  "mod":mod.id,
                  "base":base,
                  "template":true
               };
               this._uiLoader.load(templateUri,null,TxtAdapter);
            }
         }
         if(!--this._uiFileToLoad)
         {
            this.onAllUiChecked(null);
         }
      }
      
      private function searchDmFile(rootPath:File) : File
      {
         var file:* = null;
         var dm:* = null;
         if(rootPath.nativePath.indexOf(".svn") != -1)
         {
            return null;
         }
         var files:Array = rootPath.getDirectoryListing();
         for each(file in files)
         {
            if(!file.isDirectory && file.extension)
            {
               if(file.extension.toLowerCase() == "d2ui")
               {
                  return file;
               }
               if(!dm && file.extension.toLowerCase() == "dm")
               {
                  dm = file;
               }
            }
         }
         if(dm)
         {
            return dm;
         }
         for each(file in files)
         {
            if(file.isDirectory)
            {
               dm = this.searchDmFile(file);
               if(dm)
               {
                  break;
               }
            }
         }
         return dm;
      }
      
      public function get trustedModuleScripts() : Array
      {
         return this._trustedModuleScripts;
      }
      
      public function set trustedModuleScripts(v:Array) : void
      {
         this._trustedModuleScripts = v;
      }
   }
}
