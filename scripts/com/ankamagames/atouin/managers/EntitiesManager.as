package com.ankamagames.atouin.managers
{
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.entities.interfaces.IInteractive;
   import com.ankamagames.jerakine.entities.interfaces.IMovable;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.enums.InteractionsEnum;
   import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class EntitiesManager
   {
      
      public static const RANDOM_ENTITIES_ID_START:Number = -1000000;
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(EntitiesManager));
      
      private static var _self:EntitiesManager;
       
      
      private var _entities:Array;
      
      private var _entitiesScheduledForDestruction:Array;
      
      private var _currentRandomEntity:Number = -1000000;
      
      public function EntitiesManager()
      {
         super();
         if(_self)
         {
            throw new SingletonError("Warning : EntitiesManager is a singleton class and shoulnd\'t be instancied directly!");
         }
         this._entities = new Array();
         this._entitiesScheduledForDestruction = new Array();
         Atouin.getInstance().options.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
      }
      
      public static function getInstance() : EntitiesManager
      {
         if(!_self)
         {
            _self = new EntitiesManager();
         }
         return _self;
      }
      
      public function initManager() : void
      {
         Atouin.getInstance().options.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
      }
      
      public function addAnimatedEntity(entityID:Number, entity:IEntity, strata:uint) : void
      {
         if(this._entities[entityID] != null)
         {
            _log.warn("Entity overwriting! Entity " + entityID + " has been replaced.");
         }
         this._entities[entityID] = entity;
         if(entity is IDisplayable)
         {
            EntitiesDisplayManager.getInstance().displayEntity(entity as IDisplayable,entity.position,strata);
         }
         if(entity is IInteractive)
         {
            this.registerInteractions(IInteractive(entity),true);
            Sprite(entity).buttonMode = IInteractive(entity).useHandCursor;
         }
      }
      
      public function getEntity(entityID:Number) : IEntity
      {
         return this._entities[entityID];
      }
      
      public function getEntityID(entity:IEntity) : Number
      {
         var i:* = null;
         for(i in this._entities)
         {
            if(entity === this._entities[i])
            {
               return parseFloat(i);
            }
         }
         return 0;
      }
      
      public function removeEntity(entityID:Number) : void
      {
         if(this._entities[entityID])
         {
            if(this._entities[entityID] is IDisplayable)
            {
               EntitiesDisplayManager.getInstance().removeEntity(this._entities[entityID] as IDisplayable);
            }
            if(this._entities[entityID] is IInteractive)
            {
               this.registerInteractions(IInteractive(this._entities[entityID]),false);
            }
            if(this._entities[entityID] is IMovable && IMovable(this._entities[entityID]).isMoving)
            {
               IMovable(this._entities[entityID]).stop(true);
            }
            delete this._entities[entityID];
            if(this._entitiesScheduledForDestruction[entityID])
            {
               delete this._entitiesScheduledForDestruction[entityID];
            }
         }
      }
      
      public function clearEntities() : void
      {
         var id:* = null;
         var i:int = 0;
         var num:int = 0;
         var entityId:Number = NaN;
         var ts:* = null;
         var entityBuffer:Array = new Array();
         for(id in this._entities)
         {
            entityBuffer.push(id);
         }
         i = -1;
         num = entityBuffer.length;
         while(++i < num)
         {
            entityId = entityBuffer[i];
            ts = this._entities[entityId] as TiphonSprite;
            this.removeEntity(entityId);
            if(ts)
            {
               ts.destroy();
            }
         }
         this._entities = new Array();
      }
      
      public function setEntitiesVisibility(visible:Boolean) : void
      {
         var id:* = null;
         var i:int = 0;
         var num:int = 0;
         var entityId:Number = NaN;
         var ts:* = null;
         var entityBuffer:Array = new Array();
         for(id in this._entities)
         {
            entityBuffer.push(id);
         }
         i = -1;
         num = entityBuffer.length;
         while(++i < num)
         {
            entityId = entityBuffer[i];
            ts = this._entities[entityId] as TiphonSprite;
            ts.visible = visible;
         }
      }
      
      public function get entities() : Array
      {
         return this._entities;
      }
      
      public function get entitiesScheduledForDestruction() : Array
      {
         return this._entitiesScheduledForDestruction;
      }
      
      public function get entitiesCount() : int
      {
         var e:* = undefined;
         var count:int = 0;
         for each(e in this._entities)
         {
            count++;
         }
         return count;
      }
      
      public function getFreeEntityId() : Number
      {
         while(true)
         {
            if(this._entities[--this._currentRandomEntity] == null)
            {
               break;
            }
            this._currentRandomEntity--;
         }
         return this._currentRandomEntity;
      }
      
      private function registerInteractions(entity:IInteractive, register:Boolean) : void
      {
         var index:int = 0;
         var interactions:uint = entity.enabledInteractions;
         while(interactions > 0)
         {
            this.registerInteraction(entity,1 << index++,register);
            interactions = interactions >> 1;
         }
      }
      
      public function registerInteraction(entity:IInteractive, interactionType:uint, enabled:Boolean) : void
      {
         var event:* = null;
         var events:Array = InteractionsEnum.getEvents(interactionType);
         for each(event in events)
         {
            if(enabled && !entity.hasEventListener(event))
            {
               entity.addEventListener(event,this.onInteraction,false,0,true);
            }
            else if(!enabled && entity.hasEventListener(event))
            {
               entity.removeEventListener(event,this.onInteraction,false);
            }
         }
      }
      
      public function getEntityOnCell(cellId:uint, oClass:* = null) : IEntity
      {
         var e:* = null;
         var i:int = 0;
         var useFilter:* = oClass != null;
         var isMultiFilter:Boolean = useFilter && oClass is Array;
         for each(e in this._entities)
         {
            if(e && e.position && e.position.cellId == cellId)
            {
               if(!isMultiFilter)
               {
                  if(!useFilter || !isMultiFilter && e is oClass)
                  {
                     return e;
                  }
               }
               else
               {
                  for(i = 0; i < (oClass as Array).length; i++)
                  {
                     if(e is oClass[i])
                     {
                        return e;
                     }
                  }
               }
               continue;
            }
         }
         return null;
      }
      
      public function getEntitiesOnCell(cellId:uint, oClass:* = null) : Array
      {
         var e:* = null;
         var i:int = 0;
         var useFilter:* = oClass != null;
         var isMultiFilter:Boolean = useFilter && oClass is Array;
         var result:* = [];
         for each(e in this._entities)
         {
            if(e && e.position && e.position.cellId == cellId)
            {
               if(!isMultiFilter)
               {
                  if(!useFilter || !isMultiFilter && e is oClass)
                  {
                     result.push(e);
                  }
               }
               else
               {
                  for(i = 0; i < (oClass as Array).length; i++)
                  {
                     if(e is oClass[i])
                     {
                        result.push(e);
                     }
                  }
               }
               continue;
            }
         }
         return result;
      }
      
      private function onInteraction(e:Event) : void
      {
         var entity:IInteractive = IInteractive(e.target);
         var clazz:Class = InteractionsEnum.getMessage(e.type);
         entity.handler.process(new clazz(entity));
      }
      
      private function onPropertyChanged(e:PropertyChangeEvent) : void
      {
         var ent:* = null;
         if(e.propertyName == "transparentOverlayMode")
         {
            for each(ent in this._entities)
            {
               if(ent is IDisplayable)
               {
                  EntitiesDisplayManager.getInstance().refreshAlphaEntity(ent as IDisplayable,ent.position);
               }
            }
         }
      }
   }
}
