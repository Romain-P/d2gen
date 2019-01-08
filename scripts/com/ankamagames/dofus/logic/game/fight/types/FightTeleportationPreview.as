package com.ankamagames.dofus.logic.game.fight.types
{
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.atouin.data.map.CellData;
   import com.ankamagames.atouin.enums.PlacementStrataEnums;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.dofus.internalDatacenter.DataEnum;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellDamagesManager;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdEnum;
   import com.ankamagames.dofus.logic.game.fight.miscs.CarrierAnimationModifier;
   import com.ankamagames.dofus.logic.game.fight.miscs.CarrierSubEntityBehaviour;
   import com.ankamagames.dofus.logic.game.fight.miscs.TeleportationUtil;
   import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
   import com.ankamagames.dofus.network.enums.TeamEnum;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCharacterInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.types.entities.AnimStatiqueSubEntityBehavior;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.types.entities.RiderBehavior;
   import com.ankamagames.dofus.types.enums.AnimationEnum;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.utils.display.Rectangle2;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import com.ankamagames.tiphon.types.IAnimationModifier;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class FightTeleportationPreview
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(FightTeleportationPreview));
       
      
      private var _currentSpell:SpellWrapper;
      
      private var _fightTeleportationCasterPos:MapPoint;
      
      private var _portalsExit:MapPoint;
      
      private var _previews:Vector.<AnimatedCharacter>;
      
      private var _teleFraggedEntities:Vector.<AnimatedCharacter>;
      
      private var _previewIdEntityIdAssoc:Dictionary;
      
      private var _fightTeleportations:Vector.<FightTeleportation>;
      
      private var _previewsPositions:Dictionary;
      
      public function FightTeleportationPreview(pSpellW:SpellWrapper, pFightTeleportations:Vector.<FightTeleportation>, pPortalsExit:MapPoint)
      {
         super();
         this._currentSpell = pSpellW;
         this._previewIdEntityIdAssoc = new Dictionary();
         this._previewsPositions = new Dictionary();
         this._portalsExit = pPortalsExit;
         this._fightTeleportations = pFightTeleportations;
      }
      
      public function getEntitiesIds() : Vector.<Number>
      {
         var fightTp:* = null;
         var targetId:Number = NaN;
         var entitiesIds:Vector.<Number> = new Vector.<Number>(0);
         for each(fightTp in this._fightTeleportations)
         {
            for each(targetId in fightTp.targets)
            {
               if(entitiesIds.indexOf(targetId) == -1)
               {
                  entitiesIds.push(targetId);
               }
            }
         }
         return entitiesIds;
      }
      
      public function getTelefraggedEntitiesIds() : Vector.<Number>
      {
         var telefraggedEntity:* = null;
         var telefraggedEntitiesIds:Vector.<Number> = new Vector.<Number>(0);
         for each(telefraggedEntity in this._teleFraggedEntities)
         {
            telefraggedEntitiesIds.push(!!this._previewIdEntityIdAssoc[telefraggedEntity.id]?this._previewIdEntityIdAssoc[telefraggedEntity.id]:telefraggedEntity.id);
         }
         return telefraggedEntitiesIds;
      }
      
      public function isPreview(pEntityId:Number) : Boolean
      {
         return this.getPreview(pEntityId) != null;
      }
      
      public function show() : void
      {
         var entityId:Number = NaN;
         var entity:* = null;
         var parentEntity:* = null;
         var parentEntityId:Number = NaN;
         var teleport:* = null;
         var fightTp:* = null;
         var i:int = 0;
         var nbEntities:int = 0;
         for each(fightTp in this._fightTeleportations)
         {
            teleport = this.getTeleportFunction(fightTp.effectId);
            this._fightTeleportationCasterPos = fightTp.casterPos;
            fightTp.targets.sort(this.compareDistanceFromCaster);
            nbEntities = fightTp.targets.length;
            for(i = 0; i < nbEntities; )
            {
               entity = DofusEntities.getEntity(fightTp.targets[i]) as AnimatedCharacter;
               if(entity)
               {
                  parentEntity = this.getParentEntity(entity) as AnimatedCharacter;
                  if(!(!fightTp.allTargets && entity.id != parentEntity.id))
                  {
                     parentEntity.visible = false;
                     teleport.apply(this,[!!fightTp.allTargets?entity.id:parentEntity.id,fightTp]);
                  }
               }
               i++;
            }
         }
      }
      
      public function remove() : void
      {
         var entityId:Number = NaN;
         var entity:* = null;
         var parentEntity:* = null;
         var parentEntityId:Number = NaN;
         var ac:* = null;
         var fightTp:* = null;
         var caster:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var showPermanentTooltips:Boolean = fightContextFrame.showPermanentTooltips && fightContextFrame.battleFrame.targetedEntities.length > 0;
         var overEntity:AnimatedCharacter = EntitiesManager.getInstance().getEntityOnCell(FightContextFrame.currentCell,AnimatedCharacter) as AnimatedCharacter;
         overEntity = !!overEntity?this.getParentEntity(overEntity) as AnimatedCharacter:null;
         for each(entityId in this.getEntitiesIds())
         {
            entity = DofusEntities.getEntity(entityId) as AnimatedCharacter;
            if(entity)
            {
               parentEntity = this.getParentEntity(entity) as AnimatedCharacter;
               if(!overEntity || overEntity.id != parentEntity.id)
               {
                  TooltipManager.hide("tooltipOverEntity_" + parentEntity.id);
                  if(showPermanentTooltips && fightContextFrame.battleFrame.targetedEntities.indexOf(parentEntity.id) != -1)
                  {
                     fightContextFrame.displayEntityTooltip(parentEntity.id);
                  }
               }
               parentEntity.visible = true;
            }
         }
         if(this._previews)
         {
            for each(ac in this._previews)
            {
               ac.destroy();
               fightContextFrame.entitiesFrame.updateEntityIconPosition(this._previewIdEntityIdAssoc[ac.id]);
               delete this._previewsPositions[ac.id];
            }
         }
         if(this._teleFraggedEntities)
         {
            for each(ac in this._teleFraggedEntities)
            {
               TooltipManager.hide("tooltipOverEntity_" + ac.id);
               if(showPermanentTooltips && fightContextFrame.battleFrame.targetedEntities.indexOf(ac.id) != -1)
               {
                  fightContextFrame.displayEntityTooltip(ac.id);
               }
               ac.visible = true;
            }
         }
         for each(fightTp in this._fightTeleportations)
         {
            caster = DofusEntities.getEntity(fightTp.casterId) as AnimatedCharacter;
            caster.visible = true;
         }
      }
      
      private function getTeleportFunction(pEffectId:uint) : Function
      {
         var teleport:* = null;
         switch(pEffectId)
         {
            case ActionIdEnum.ACTION_TELEPORT_TO_PREVIOUS_POSITION:
               teleport = this.teleportationToPreviousPosition;
               break;
            case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_TARGET:
               teleport = this.symetricTeleportation;
               break;
            case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_CASTER:
               teleport = this.symetricTeleportationFromCaster;
               break;
            case ActionIdEnum.ACTION_TELEPORT_MIRROR_BY_AREA_CENTER:
               teleport = this.symetricTeleportationFromImpactCell;
               break;
            case ActionIdEnum.ACTION_CHARACTER_EXCHANGE_PLACES:
               teleport = this.switchPositions;
               break;
            case ActionIdEnum.ACTION_TELEPORT_TO_TURN_START_POSITION:
               teleport = this.teleportToRoundStartPosition;
         }
         return teleport;
      }
      
      private function symetricTeleportation(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var preview:* = null;
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var casterPos:MapPoint = !!this._portalsExit?this._portalsExit:pFightTeleportation.casterPos;
         var teleportationCell:MapPoint = casterPos.pointSymetry(pFightTeleportation.impactPos);
         if(teleportationCell && this.isValidCell(teleportationCell.cellId) && EntitiesManager.getInstance().getEntitiesOnCell(pFightTeleportation.impactPos.cellId,AnimatedCharacter).length > 0)
         {
            preview = this.createFighterPreview(pTargetId,teleportationCell,casterPos.advancedOrientationTo(pFightTeleportation.impactPos));
            this.checkTeleFrag(preview,pTargetId,teleportationCell,casterPos);
         }
         else
         {
            entity.visible = true;
         }
      }
      
      private function symetricTeleportationFromCaster(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var preview:* = null;
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var existingTargetPreview:AnimatedCharacter = this.getPreview(pTargetId);
         var entityPos:MapPoint = !!existingTargetPreview?existingTargetPreview.position:entity.position;
         var entityDirection:uint = this._currentSpell.playerId == pTargetId?uint(entityPos.advancedOrientationTo(pFightTeleportation.impactPos)):uint(entity.getDirection());
         var existingCasterPreview:AnimatedCharacter = this.getPreview(pFightTeleportation.casterId);
         var casterPos:MapPoint = !!existingCasterPreview?existingCasterPreview.position:pFightTeleportation.casterPos;
         var teleportationCell:MapPoint = entityPos.pointSymetry(casterPos);
         if(teleportationCell && this.isValidCell(teleportationCell.cellId))
         {
            preview = this.createFighterPreview(pTargetId,teleportationCell,entityDirection);
            this.checkTeleFrag(preview,pTargetId,teleportationCell,entityPos);
         }
         else
         {
            entity.visible = true;
         }
      }
      
      private function symetricTeleportationFromImpactCell(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var direction:* = 0;
         var existingPreviewPos:* = null;
         var preview:* = null;
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var existingPreview:AnimatedCharacter = this.getPreview(pTargetId);
         var checkPositionsSwitch:Boolean = existingPreview && pFightTeleportation.multipleEffects;
         var entityPos:MapPoint = pTargetId == pFightTeleportation.casterId?pFightTeleportation.casterPos:entity.position;
         var currentPos:MapPoint = !!checkPositionsSwitch?existingPreview.position:entityPos;
         var teleportationCell:MapPoint = currentPos.pointSymetry(pFightTeleportation.impactPos);
         if(checkPositionsSwitch && this.willSwitchPosition(existingPreview,teleportationCell))
         {
            teleportationCell = entityPos.pointSymetry(pFightTeleportation.impactPos);
         }
         if(teleportationCell && this.isValidCell(teleportationCell.cellId))
         {
            direction = uint(pTargetId == pFightTeleportation.targets[0]?uint(entityPos.advancedOrientationTo(pFightTeleportation.impactPos)):uint(entity.getDirection()));
            existingPreviewPos = !!existingPreview?MapPoint.fromCellId(existingPreview.position.cellId):null;
            preview = this.createFighterPreview(pTargetId,teleportationCell,direction);
            this.checkTeleFrag(preview,pTargetId,teleportationCell,!!existingPreviewPos?existingPreviewPos:entityPos);
         }
         else
         {
            entity.visible = true;
         }
      }
      
      private function teleportationToPreviousPosition(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var teleportationCellId:int = 0;
         var previewPositions:* = null;
         var teleportationCell:* = null;
         var entityPos:* = null;
         var preview:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var existingPreview:AnimatedCharacter = this.getPreview(pTargetId);
         if(existingPreview)
         {
            previewPositions = this._previewsPositions[existingPreview.id];
            teleportationCellId = previewPositions.length > 1?int(previewPositions[previewPositions.length - 2]):int(entity.position.cellId);
         }
         else
         {
            teleportationCellId = this._fightTeleportations.indexOf(pFightTeleportation) == 0?int(fightContextFrame.getFighterPreviousPosition(pTargetId)):int(entity.position.cellId);
         }
         if(teleportationCellId != -1)
         {
            if(pFightTeleportation.allTargets && entity.parentSprite && entity.parentSprite.carriedEntity == entity)
            {
               return;
            }
            teleportationCell = MapPoint.fromCellId(teleportationCellId);
            if(teleportationCell && this.isValidCell(teleportationCell.cellId))
            {
               entityPos = !!existingPreview?existingPreview.position:entity.position;
               preview = this.createFighterPreview(pTargetId,teleportationCell,entity.getDirection());
               this.checkTeleFrag(preview,pTargetId,teleportationCell,entityPos);
            }
            else
            {
               entity.visible = true;
            }
         }
         else if(!existingPreview)
         {
            entity.visible = true;
         }
      }
      
      private function switchPositions(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var existingTargetPreview:AnimatedCharacter = this.getPreview(pTargetId);
         var entityPos:MapPoint = !!existingTargetPreview?existingTargetPreview.position:entity.position;
         var targetDirection:uint = pTargetId == this._currentSpell.playerId?uint(entityPos.advancedOrientationTo(pFightTeleportation.impactPos)):uint(entity.getDirection());
         var caster:AnimatedCharacter = DofusEntities.getEntity(pFightTeleportation.casterId) as AnimatedCharacter;
         caster.visible = false;
         var existingCasterPreview:AnimatedCharacter = this.getPreview(pFightTeleportation.casterId);
         var casterPos:MapPoint = !!existingCasterPreview?existingCasterPreview.position:pFightTeleportation.casterPos;
         var casterDirection:uint = this._currentSpell.playerId == pFightTeleportation.casterId?uint(casterPos.advancedOrientationTo(pFightTeleportation.impactPos)):uint(caster.getDirection());
         this.createFighterPreview(pTargetId,casterPos,targetDirection);
         this.createFighterPreview(pFightTeleportation.casterId,entityPos,casterDirection);
      }
      
      private function teleportToRoundStartPosition(pTargetId:Number, pFightTeleportation:FightTeleportation) : void
      {
         var entityPos:* = null;
         var preview:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var entity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var existingPreview:AnimatedCharacter = this.getPreview(pTargetId);
         var teleportationCell:MapPoint = MapPoint.fromCellId(fightContextFrame.getFighterRoundStartPosition(pTargetId));
         if(teleportationCell && this.isValidCell(teleportationCell.cellId))
         {
            entityPos = !!existingPreview?existingPreview.position:entity.position;
            preview = this.createFighterPreview(pTargetId,teleportationCell,entity.getDirection());
            this.checkTeleFrag(preview,pTargetId,teleportationCell,entityPos);
         }
         else
         {
            entity.visible = true;
         }
      }
      
      private function checkTeleFrag(pTeleportPreview:AnimatedCharacter, pTargetId:Number, pDestination:MapPoint, pFrom:MapPoint) : void
      {
         var entity:* = null;
         var entityActualId:Number = NaN;
         var cellEntityStatus:* = null;
         var teleportedActualEntityId:Number = NaN;
         var teleportedActualEntity:* = null;
         var teleportationCellEntities:Array = EntitiesManager.getInstance().getEntitiesOnCell(pDestination.cellId,AnimatedCharacter);
         var targetStatus:FighterStatus = FightersStateManager.getInstance().getStatus(pTargetId);
         if(teleportationCellEntities.length > 0)
         {
            for each(entity in teleportationCellEntities)
            {
               if(entity != pTeleportPreview && entity.id != pTargetId)
               {
                  if(this._previewIdEntityIdAssoc[entity.id])
                  {
                     entityActualId = this._previewIdEntityIdAssoc[entity.id];
                  }
                  else
                  {
                     if(this.getPreview(entity.id))
                     {
                        continue;
                     }
                     entityActualId = entity.id;
                  }
                  entity = this.getParentEntity(entity) as AnimatedCharacter;
                  cellEntityStatus = FightersStateManager.getInstance().getStatus(entityActualId);
                  if(!targetStatus.cantSwitchPosition && TeleportationUtil.canTeleport(entityActualId) && !cellEntityStatus.cantSwitchPosition && !this.isCarrying(entity) && !this.isCarrying(pTeleportPreview))
                  {
                     this.telefrag(entity,pTeleportPreview,pTargetId,pFrom);
                     break;
                  }
                  teleportedActualEntityId = this._previewIdEntityIdAssoc[pTeleportPreview.id];
                  teleportedActualEntity = DofusEntities.getEntity(teleportedActualEntityId) as AnimatedCharacter;
                  if(teleportedActualEntity)
                  {
                     teleportedActualEntity = this.getParentEntity(teleportedActualEntity) as AnimatedCharacter;
                     teleportedActualEntity.visible = true;
                     this.updateEntityTooltip(teleportedActualEntity.id,teleportedActualEntity);
                  }
                  this.removeFighterPreview(pTeleportPreview);
                  break;
               }
            }
         }
      }
      
      private function telefrag(pTeleFraggedEntity:AnimatedCharacter, pTeleFraggingPreviewEntity:AnimatedCharacter, pTeleFraggingActualEntityId:Number, pDestination:MapPoint) : void
      {
         var existingPreview:AnimatedCharacter = this.getPreview(pTeleFraggedEntity.id);
         var existingPreviewPos:MapPoint = !!existingPreview?existingPreview.position:null;
         var teleFraggedPreview:AnimatedCharacter = this.createFighterPreview(pTeleFraggedEntity.id,pDestination,pTeleFraggedEntity.getDirection());
         var telefraggedActualEntityId:Number = !!this._previewIdEntityIdAssoc[pTeleFraggedEntity.id]?Number(this._previewIdEntityIdAssoc[pTeleFraggedEntity.id]):Number(pTeleFraggedEntity.id);
         if(pDestination.equals(pTeleFraggingPreviewEntity.position) && existingPreviewPos)
         {
            this.telefrag(pTeleFraggingPreviewEntity,teleFraggedPreview,telefraggedActualEntityId,existingPreviewPos);
            return;
         }
         if(!this._previewIdEntityIdAssoc[pTeleFraggedEntity.id])
         {
            pTeleFraggedEntity.visible = false;
         }
         if(!this._teleFraggedEntities)
         {
            this._teleFraggedEntities = new Vector.<AnimatedCharacter>(0);
         }
         this._teleFraggedEntities.push(pTeleFraggedEntity);
         this.showTelefragTooltip(telefraggedActualEntityId,teleFraggedPreview);
         this.showTelefragTooltip(pTeleFraggingActualEntityId,pTeleFraggingPreviewEntity);
      }
      
      private function willSwitchPosition(pPreview:AnimatedCharacter, pTeleportationCell:MapPoint) : Boolean
      {
         var teleportationCellEntities:* = null;
         var entity:* = null;
         var actualEntityId:Number = NaN;
         var fightContextFrame:* = null;
         var entityFightInfos:* = null;
         var entityOnCellFightInfos:* = null;
         var entityOnCellId:Number = NaN;
         if(pTeleportationCell && this.isValidCell(pTeleportationCell.cellId))
         {
            teleportationCellEntities = EntitiesManager.getInstance().getEntitiesOnCell(pTeleportationCell.cellId,AnimatedCharacter);
            actualEntityId = this._previewIdEntityIdAssoc[pPreview.id];
            fightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
            entityFightInfos = fightContextFrame.entitiesFrame.getEntityInfos(actualEntityId) as GameFightFighterInformations;
            for each(entity in teleportationCellEntities)
            {
               if(entity != pPreview && entity.id != actualEntityId)
               {
                  entityOnCellId = !!this._previewIdEntityIdAssoc[entity.id]?Number(this._previewIdEntityIdAssoc[entity.id]):Number(entity.id);
                  entityOnCellFightInfos = fightContextFrame.entitiesFrame.getEntityInfos(entityOnCellId) as GameFightFighterInformations;
                  if(entityFightInfos.teamId == entityOnCellFightInfos.teamId)
                  {
                     return true;
                  }
                  return false;
               }
            }
         }
         return false;
      }
      
      private function getPreview(pEntityId:Number) : AnimatedCharacter
      {
         var previewEntityId:* = undefined;
         var previewEntity:* = null;
         if(this._previewIdEntityIdAssoc[pEntityId])
         {
            for each(previewEntity in this._previews)
            {
               if(previewEntity.id == pEntityId)
               {
                  return previewEntity;
               }
            }
         }
         else
         {
            for(previewEntityId in this._previewIdEntityIdAssoc)
            {
               if(this._previewIdEntityIdAssoc[previewEntityId] == pEntityId)
               {
                  for each(previewEntity in this._previews)
                  {
                     if(previewEntity.id == previewEntityId)
                     {
                        return previewEntity;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      private function createFighterPreview(pTargetId:Number, pDestPos:MapPoint, pDirection:uint, pUseParentEntity:Boolean = true) : AnimatedCharacter
      {
         var animModifier:* = null;
         var actualEntity:AnimatedCharacter = DofusEntities.getEntity(pTargetId) as AnimatedCharacter;
         var parentEntity:TiphonSprite = !!pUseParentEntity?this.getParentEntity(actualEntity):actualEntity;
         var previewEntity:AnimatedCharacter = this.getPreview(pTargetId);
         if(!previewEntity)
         {
            previewEntity = new AnimatedCharacter(EntitiesManager.getInstance().getFreeEntityId(),parentEntity.look,null,null);
            if(OptionManager.getOptionManager("atouin").useLowDefSkin)
            {
               previewEntity.setAlternativeSkinIndex(0,true);
            }
            for each(animModifier in parentEntity.animationModifiers)
            {
               previewEntity.addAnimationModifier(animModifier);
            }
            previewEntity.skinModifier = parentEntity.skinModifier;
            this.addPreviewSubEntities(parentEntity,previewEntity);
            previewEntity.mouseEnabled = previewEntity.mouseChildren = false;
            if(!pUseParentEntity && previewEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,0))
            {
               previewEntity.removeAnimationModifierByClass(CarrierAnimationModifier);
               previewEntity.removeSubEntity(previewEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,0));
               previewEntity.setAnimation(AnimationEnum.ANIM_STATIQUE);
            }
            if(!this._previews)
            {
               this._previews = new Vector.<AnimatedCharacter>(0);
            }
            this._previews.push(previewEntity);
            this._previewIdEntityIdAssoc[previewEntity.id] = pTargetId;
         }
         previewEntity.position = pDestPos;
         if(!this._previewsPositions[previewEntity.id])
         {
            this._previewsPositions[previewEntity.id] = new Vector.<uint>();
         }
         this._previewsPositions[previewEntity.id].push(pDestPos.cellId);
         previewEntity.setAnimationAndDirection(parentEntity.getAnimation(),pDirection,true);
         previewEntity.display(PlacementStrataEnums.STRATA_PLAYER);
         previewEntity.setCanSeeThrough(true);
         var actualEntityId:Number = !!this._previewIdEntityIdAssoc[pTargetId]?Number(this._previewIdEntityIdAssoc[pTargetId]):Number(pTargetId);
         this.updateEntityTooltip(actualEntityId,previewEntity);
         return previewEntity;
      }
      
      private function removeFighterPreview(pTeleportPreview:AnimatedCharacter) : void
      {
         var previewListIndex:int = 0;
         pTeleportPreview.destroy();
         delete this._previewIdEntityIdAssoc[pTeleportPreview.id];
         delete this._previewsPositions[pTeleportPreview.id];
         if(this._previews)
         {
            previewListIndex = this._previews.indexOf(pTeleportPreview);
            if(previewListIndex != -1)
            {
               this._previews.splice(previewListIndex,1);
            }
         }
      }
      
      private function getParentEntity(pEntity:TiphonSprite) : TiphonSprite
      {
         var parentEntity:* = null;
         var parent:TiphonSprite = pEntity.parentSprite;
         while(parent)
         {
            parentEntity = parent;
            parent = parent.parentSprite;
         }
         return !parentEntity?pEntity:parentEntity;
      }
      
      private function addPreviewSubEntities(pActualEntity:TiphonSprite, pPreviewEntity:TiphonSprite) : void
      {
         var carriedPreviewEntity:* = null;
         var animModifier:* = null;
         var subEntities:Array = pActualEntity.look.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET);
         if(subEntities && subEntities.length)
         {
            pPreviewEntity.setSubEntityBehaviour(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET,new AnimStatiqueSubEntityBehavior());
         }
         var isRider:Boolean = false;
         subEntities = pActualEntity.look.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER);
         if(subEntities && subEntities.length)
         {
            isRider = true;
            pPreviewEntity.setSubEntityBehaviour(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,new RiderBehavior());
         }
         var carryingEntity:TiphonSprite = pActualEntity;
         if(isRider && pActualEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0))
         {
            carryingEntity = pActualEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) as TiphonSprite;
         }
         var carryingPreviewEntity:TiphonSprite = pPreviewEntity;
         if(isRider && pPreviewEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0))
         {
            carryingPreviewEntity = pPreviewEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) as TiphonSprite;
         }
         var carriedEntity:TiphonSprite = carryingEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,0) as TiphonSprite;
         this.addTeamCircle(pActualEntity,pPreviewEntity);
         if(carriedEntity)
         {
            carriedPreviewEntity = new TiphonSprite(carriedEntity.look);
            if(OptionManager.getOptionManager("atouin").useLowDefSkin)
            {
               carriedPreviewEntity.setAlternativeSkinIndex(0,true);
            }
            for each(animModifier in carriedEntity.animationModifiers)
            {
               carriedPreviewEntity.addAnimationModifier(animModifier);
            }
            carriedPreviewEntity.skinModifier = carriedEntity.skinModifier;
            carryingPreviewEntity.setSubEntityBehaviour(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,new CarrierSubEntityBehaviour());
            carryingPreviewEntity.isCarrying = true;
            carryingPreviewEntity.addAnimationModifier(CarrierAnimationModifier.getInstance());
            carryingPreviewEntity.addSubEntity(carriedPreviewEntity,SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_LIFTED_ENTITY,0);
            carriedPreviewEntity.setAnimation(AnimationEnum.ANIM_STATIQUE);
            carryingPreviewEntity.setAnimation(AnimationEnum.ANIM_STATIQUE_CARRYING);
            this.addPreviewSubEntities(carriedEntity,carriedPreviewEntity);
         }
      }
      
      private function addTeamCircle(pActualEntity:TiphonSprite, pEntity:TiphonSprite) : void
      {
         var id:Number = NaN;
         var entityId:Number = NaN;
         var entitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         for each(entityId in entitiesFrame.getEntitiesIdsList())
         {
            if(DofusEntities.getEntity(entityId) == pActualEntity)
            {
               id = entityId;
            }
         }
         if(id != 0)
         {
            entitiesFrame.addCircleToFighter(pEntity,(entitiesFrame.getEntityInfos(id) as GameFightFighterInformations).teamId == TeamEnum.TEAM_DEFENDER?255:uint(16711680));
         }
      }
      
      private function isValidCell(pCellId:int) : Boolean
      {
         if(pCellId == -1)
         {
            return false;
         }
         var cellData:CellData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[pCellId];
         return cellData.mov && !cellData.nonWalkableDuringFight;
      }
      
      private function compareDistanceFromCaster(pEntityAId:Number, pEntityBId:Number) : int
      {
         var entityA:IEntity = DofusEntities.getEntity(pEntityAId);
         var entityB:IEntity = DofusEntities.getEntity(pEntityBId);
         var distanceA:int = entityA.position.distanceToCell(this._fightTeleportationCasterPos);
         var distanceB:int = entityB.position.distanceToCell(this._fightTeleportationCasterPos);
         if(distanceA < distanceB)
         {
            return -1;
         }
         if(distanceA > distanceB)
         {
            return 1;
         }
         return 0;
      }
      
      private function showTelefragTooltip(pActualEntityId:Number, pPreviewEntity:AnimatedCharacter) : void
      {
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var entityInfos:GameFightFighterInformations = fightContextFrame.entitiesFrame.getEntityInfos(pActualEntityId) as GameFightFighterInformations;
         TooltipManager.hide("tooltipOverEntity_" + pActualEntityId);
         SpellDamagesManager.getInstance().removeSpellDamageBySpellId(pActualEntityId,this._currentSpell.id);
         fightContextFrame.displayEntityTooltip(pActualEntityId,this._currentSpell,null,true,FightContextFrame.currentCell,{
            "fightStatus":(entityInfos.teamId == TeamEnum.TEAM_DEFENDER?DataEnum.SPELL_STATE_TELEFRAG_ALLY:DataEnum.SPELL_STATE_TELEFRAG_ENEMY),
            "target":pPreviewEntity.absoluteBounds,
            "cellId":pPreviewEntity.position.cellId
         });
      }
      
      private function updateEntityTooltip(pActualEntityId:Number, pEntity:AnimatedCharacter) : void
      {
         var entityInfos:* = null;
         var ttCacheName:* = null;
         var ttName:* = null;
         var offsetRect:* = null;
         var fightContextFrame:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var hasIcon:Boolean = fightContextFrame.entitiesFrame.hasIcon(pActualEntityId);
         if(TooltipManager.isVisible("tooltipOverEntity_" + pActualEntityId))
         {
            entityInfos = fightContextFrame.entitiesFrame.getEntityInfos(pActualEntityId) as GameFightFighterInformations;
            ttCacheName = entityInfos is GameFightCharacterInformations?"PlayerShortInfos" + pActualEntityId:"EntityShortInfos" + pActualEntityId;
            ttName = "tooltipOverEntity_" + pActualEntityId;
            offsetRect = !!hasIcon?new Rectangle2(0,-(fightContextFrame.entitiesFrame.getIcon(pActualEntityId).height * Atouin.getInstance().currentZoom + 10 * Atouin.getInstance().currentZoom),0,0):null;
            TooltipManager.updatePosition(ttCacheName,ttName,pEntity.absoluteBounds,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,true,pEntity.position.cellId,offsetRect);
         }
         else if(hasIcon)
         {
            fightContextFrame.entitiesFrame.getIcon(pActualEntityId).place(fightContextFrame.entitiesFrame.getIconEntityBounds(pEntity));
         }
      }
      
      private function isCarrying(pEntity:AnimatedCharacter) : Boolean
      {
         var entity:TiphonSprite = pEntity.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) as TiphonSprite;
         return !!entity?entity.carriedEntity != null:pEntity.carriedEntity != null;
      }
   }
}
