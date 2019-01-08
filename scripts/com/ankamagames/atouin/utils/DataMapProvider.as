package com.ankamagames.atouin.utils
{
   import com.ankamagames.atouin.AtouinConstants;
   import com.ankamagames.atouin.data.map.Cell;
   import com.ankamagames.atouin.data.map.CellData;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.interfaces.IObstacle;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.map.IDataMapProvider;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class DataMapProvider implements IDataMapProvider
   {
      
      private static const TOLERANCE_ELEVATION:int = 11;
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(DataMapProvider));
      
      private static var _self:DataMapProvider;
      
      public static var throwSingletonError:Boolean = true;
      
      private static var _playerClass:Class;
       
      
      public var isInFight:Boolean;
      
      public var obstaclesCells:Vector.<uint>;
      
      private var _updatedCell:Dictionary;
      
      private var _specialEffects:Dictionary;
      
      public function DataMapProvider()
      {
         this.obstaclesCells = new Vector.<uint>(0);
         this._updatedCell = new Dictionary();
         this._specialEffects = new Dictionary();
         super();
      }
      
      public static function getInstance() : DataMapProvider
      {
         if(!_self && throwSingletonError)
         {
            throw new SingletonError("Init function wasn\'t call");
         }
         return _self;
      }
      
      public static function init(playerClass:Class) : void
      {
         _playerClass = playerClass;
         if(!_self)
         {
            _self = new DataMapProvider();
         }
      }
      
      public function pointLos(x:int, y:int, bAllowTroughEntity:Boolean = true) : Boolean
      {
         var cellEntities:* = null;
         var o:* = null;
         var cellId:uint = MapPoint.fromCoords(x,y).cellId;
         var los:Boolean = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]).los;
         if(this._updatedCell[cellId] != null)
         {
            los = this._updatedCell[cellId];
         }
         if(!bAllowTroughEntity)
         {
            cellEntities = EntitiesManager.getInstance().getEntitiesOnCell(cellId,IObstacle);
            if(cellEntities.length)
            {
               for each(o in cellEntities)
               {
                  if(!IObstacle(o).canSeeThrough())
                  {
                     return false;
                  }
               }
            }
         }
         return los;
      }
      
      public function farmCell(x:int, y:int) : Boolean
      {
         var cellId:uint = MapPoint.fromCoords(x,y).cellId;
         return CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]).farmCell;
      }
      
      public function cellByIdIsHavenbagCell(cellId:int) : Boolean
      {
         return CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]).havenbagCell;
      }
      
      public function cellByCoordsIsHavenbagCell(x:int, y:int) : Boolean
      {
         var cellId:uint = MapPoint.fromCoords(x,y).cellId;
         return CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]).havenbagCell;
      }
      
      public function isChangeZone(cell1:uint, cell2:uint) : Boolean
      {
         var cellData1:CellData = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cell1]);
         var cellData2:CellData = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cell2]);
         var dif:int = Math.abs(Math.abs(cellData1.floor) - Math.abs(cellData2.floor));
         if(cellData1.moveZone != cellData2.moveZone && dif == 0)
         {
            return true;
         }
         return false;
      }
      
      public function pointMov(x:int, y:int, bAllowTroughEntity:Boolean = true, previousCellId:int = -1, endCellId:int = -1, avoidObstacles:Boolean = true) : Boolean
      {
         var useNewSystem:Boolean = false;
         var cellId:* = 0;
         var cellData:* = null;
         var mov:Boolean = false;
         var previousCellData:* = null;
         var dif:int = 0;
         var cellEntities:* = null;
         var o:* = null;
         if(MapPoint.isInMap(x,y))
         {
            useNewSystem = MapDisplayManager.getInstance().getDataMapContainer().dataMap.isUsingNewMovementSystem;
            cellId = uint(MapPoint.fromCoords(x,y).cellId);
            cellData = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]);
            mov = cellData.mov && (!this.isInFight || !cellData.nonWalkableDuringFight);
            if(this._updatedCell[cellId] != null)
            {
               mov = this._updatedCell[cellId];
            }
            if(mov && useNewSystem && previousCellId != -1 && previousCellId != cellId)
            {
               previousCellData = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[previousCellId]);
               dif = Math.abs(Math.abs(cellData.floor) - Math.abs(previousCellData.floor));
               if(previousCellData.moveZone != cellData.moveZone && dif > 0 || previousCellData.moveZone == cellData.moveZone && cellData.moveZone == 0 && dif > TOLERANCE_ELEVATION)
               {
                  mov = false;
               }
            }
            if(!bAllowTroughEntity)
            {
               cellEntities = EntitiesManager.getInstance().getEntitiesOnCell(cellId,IObstacle);
               if(cellEntities.length)
               {
                  for each(o in cellEntities)
                  {
                     if(!(endCellId == cellId && o.canWalkTo()))
                     {
                        if(!o.canWalkThrough())
                        {
                           return false;
                        }
                     }
                  }
               }
               else if(avoidObstacles && (this.obstaclesCells.indexOf(cellId) != -1 && cellId != endCellId))
               {
                  return false;
               }
            }
         }
         else
         {
            mov = false;
         }
         return mov;
      }
      
      public function pointCanStop(x:int, y:int, bAllowTroughEntity:Boolean = true) : Boolean
      {
         var cellId:uint = MapPoint.fromCoords(x,y).cellId;
         var cellData:CellData = CellData(MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId]);
         return this.pointMov(x,y,bAllowTroughEntity) && (this.isInFight || !cellData.nonWalkableDuringRP);
      }
      
      public function pointWeight(x:int, y:int, bAllowTroughEntity:Boolean = true) : Number
      {
         var entity:* = null;
         var weight:* = 1;
         var speed:int = this.getCellSpeed(MapPoint.fromCoords(x,y).cellId);
         if(bAllowTroughEntity)
         {
            if(speed >= 0)
            {
               weight = Number(weight + (5 - speed));
            }
            else
            {
               weight = Number(weight + (11 + Math.abs(speed)));
            }
            entity = EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x,y),_playerClass);
            if(entity && !entity["allowMovementThrough"])
            {
               weight = 20;
            }
         }
         else
         {
            if(EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x,y),_playerClass) != null)
            {
               weight = Number(weight + 0.3);
            }
            if(EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x + 1,y),_playerClass) != null)
            {
               weight = Number(weight + 0.3);
            }
            if(EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x,y + 1),_playerClass) != null)
            {
               weight = Number(weight + 0.3);
            }
            if(EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x - 1,y),_playerClass) != null)
            {
               weight = Number(weight + 0.3);
            }
            if(EntitiesManager.getInstance().getEntityOnCell(Cell.cellIdByXY(x,y - 1),_playerClass) != null)
            {
               weight = Number(weight + 0.3);
            }
            if((this.pointSpecialEffects(x,y) & 2) == 2)
            {
               weight = Number(weight + 0.2);
            }
         }
         return weight;
      }
      
      public function getCellSpeed(cellId:uint) : int
      {
         return (MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells[cellId] as CellData).speed;
      }
      
      public function pointSpecialEffects(x:int, y:int) : uint
      {
         var cellId:uint = MapPoint.fromCoords(x,y).cellId;
         if(this._specialEffects[cellId])
         {
            return this._specialEffects[cellId];
         }
         return 0;
      }
      
      public function get width() : int
      {
         return AtouinConstants.MAP_HEIGHT + AtouinConstants.MAP_WIDTH - 2;
      }
      
      public function get height() : int
      {
         return AtouinConstants.MAP_HEIGHT + AtouinConstants.MAP_WIDTH - 1;
      }
      
      public function hasEntity(x:int, y:int, bAllowTroughEntity:Boolean = false) : Boolean
      {
         var o:* = null;
         var cellEntities:Array = EntitiesManager.getInstance().getEntitiesOnCell(MapPoint.fromCoords(x,y).cellId,IObstacle);
         if(cellEntities.length)
         {
            for each(o in cellEntities)
            {
               if(!IObstacle(o).canWalkTo() && (!bAllowTroughEntity || !o.canSeeThrough()))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function updateCellMovLov(cellId:uint, canMove:Boolean) : void
      {
         this._updatedCell[cellId] = canMove;
      }
      
      public function resetUpdatedCell() : void
      {
         this._updatedCell = new Dictionary();
      }
      
      public function setSpecialEffects(cellId:uint, value:uint) : void
      {
         this._specialEffects[cellId] = value;
      }
      
      public function resetSpecialEffects() : void
      {
         this._specialEffects = new Dictionary();
      }
   }
}
