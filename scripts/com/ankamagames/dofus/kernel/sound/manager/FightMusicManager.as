package com.ankamagames.dofus.kernel.sound.manager
{
   import com.ankamagames.dofus.datacenter.ambientSounds.AmbientSound;
   import com.ankamagames.dofus.datacenter.ambientSounds.PlaylistSound;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.datacenter.playlists.Playlist;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.kernel.sound.SoundManager;
   import com.ankamagames.dofus.kernel.sound.TubulSoundConfiguration;
   import com.ankamagames.dofus.kernel.sound.type.SoundDofus;
   import com.ankamagames.dofus.kernel.sound.utils.SoundUtil;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.jerakine.BalanceManager.BalanceManager;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.protocolAudio.ProtocolEnum;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.tubul.enum.EnumSoundType;
   import com.ankamagames.tubul.factory.SoundFactory;
   import com.ankamagames.tubul.interfaces.ISound;
   import com.ankamagames.tubul.types.VolumeFadeEffect;
   import flash.utils.getQualifiedClassName;
   
   public class FightMusicManager
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(FightMusicManager));
       
      
      private var _fightMusics:Vector.<AmbientSound>;
      
      private var _bossMusics:Vector.<AmbientSound>;
      
      private var _fightMusic:PlaylistSound;
      
      private var _bossMusic:PlaylistSound;
      
      private var _hasBoss:Boolean;
      
      private var _fightMusicsId:Array;
      
      private var _fightMusicBalanceManager:BalanceManager;
      
      private var _actualFightMusic:ISound;
      
      private var _fightMusicPlaylist:Playlist;
      
      private var _bossMusicPlaylist:Playlist;
      
      public function FightMusicManager()
      {
         super();
         this.init();
      }
      
      public function prepareFightMusic() : void
      {
         if(SoundManager.getInstance().manager is RegSoundManager && !RegConnectionManager.getInstance().isMain)
         {
            return;
         }
         RegConnectionManager.getInstance().send(ProtocolEnum.PREPARE_FIGHT_MUSIC);
      }
      
      public function isBossBattle() : void
      {
         var entity:* = null;
         var monster:* = null;
         var monsterData:* = null;
         this._hasBoss = false;
         var entitiesFrame:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(entitiesFrame)
         {
            for each(entity in entitiesFrame.getEntitiesDictionnary())
            {
               if(entity is GameFightMonsterInformations)
               {
                  monster = entity as GameFightMonsterInformations;
                  monsterData = Monster.getMonsterById(monster.creatureGenericId);
                  if(monsterData.isBoss)
                  {
                     this._hasBoss = true;
                  }
               }
            }
         }
      }
      
      public function startFightPlaylist(fadeStartVolume:Number = -1, fadeEndVolume:Number = 1) : void
      {
         var sound:* = null;
         var busId:* = 0;
         var soundPath:* = null;
         var soundUri:* = null;
         var fadeCurrentMusic:* = null;
         var fightSongs:* = null;
         if(!SoundManager.getInstance().manager.soundIsActivate)
         {
            return;
         }
         if(SoundManager.getInstance().manager is RegSoundManager && !RegConnectionManager.getInstance().isMain)
         {
            return;
         }
         if(this._hasBoss && this._bossMusic)
         {
            sound = this._bossMusic;
         }
         else
         {
            sound = this._fightMusic;
         }
         if(sound)
         {
            busId = uint(SoundUtil.getBusIdBySoundId(String(sound.id)));
            soundPath = SoundUtil.getConfigEntryByBusId(busId);
            soundUri = new Uri(soundPath + sound.id + ".mp3");
            if(SoundManager.getInstance().manager is ClassicSoundManager)
            {
               this._actualFightMusic = SoundFactory.getSound(EnumSoundType.UNLOCALIZED_SOUND,soundUri);
            }
            if(SoundManager.getInstance().manager is RegSoundManager)
            {
               this._actualFightMusic = new SoundDofus(String(sound.id));
            }
            this._actualFightMusic.busId = busId;
            this._actualFightMusic.volume = 1;
            this._actualFightMusic.currentFadeVolume = 0;
            fadeCurrentMusic = new VolumeFadeEffect(fadeStartVolume,fadeEndVolume,TubulSoundConfiguration.TIME_FADE_IN_MUSIC);
            fightSongs = new Array();
            if(this._hasBoss && this._bossMusicPlaylist)
            {
               fightSongs = this.createPlaylistSounds(this._bossMusicPlaylist);
            }
            else if(this._fightMusicPlaylist)
            {
               fightSongs = this.createPlaylistSounds(this._fightMusicPlaylist);
            }
            if(fightSongs.length > 0)
            {
               RegConnectionManager.getInstance().send(ProtocolEnum.ADD_SOUNDS_PLAYLIST,fightSongs);
            }
            this._actualFightMusic.play(true,0,fadeCurrentMusic);
         }
      }
      
      public function stopFightMusic() : void
      {
         if(!SoundManager.getInstance().manager.soundIsActivate)
         {
            return;
         }
         if(SoundManager.getInstance().manager is RegSoundManager && !RegConnectionManager.getInstance().isMain)
         {
            return;
         }
         RegConnectionManager.getInstance().send(ProtocolEnum.STOP_FIGHT_MUSIC);
      }
      
      public function setFightSounds(pFightMusic:Vector.<AmbientSound>, pBossMusic:Vector.<AmbientSound>, combatPlaylist:Playlist, bossFightPlaylist:Playlist) : void
      {
         var asound:* = null;
         this._fightMusics = pFightMusic;
         this._bossMusics = pBossMusic;
         this._fightMusicPlaylist = combatPlaylist;
         this._bossMusicPlaylist = bossFightPlaylist;
         var logText:String = "";
         if(this._fightMusics.length == 0 && this._bossMusics.length == 0 && (!this._fightMusicPlaylist || this._fightMusicPlaylist.sounds.length == 0) && (!this._bossMusicPlaylist || this._bossMusicPlaylist.sounds.length == 0))
         {
            logText = "Ni musique de combat, ni musique de boss ???";
         }
         else
         {
            logText = "Cette map contient les musiques de combat : ";
            for each(asound in this._fightMusics)
            {
               logText = logText + (asound.id + ", ");
            }
            logText = " et les musiques de boss d\'id : ";
            for each(asound in this._bossMusics)
            {
               logText = logText + (asound.id + ", ");
            }
         }
         _log.info(logText);
      }
      
      public function selectValidSounds() : void
      {
         var rnd:int = 0;
         var playlistSound:* = null;
         var ambientSound:* = null;
         var count:int = 0;
         if(this._fightMusicPlaylist && this._fightMusicPlaylist.sounds.length > 0)
         {
            count = this._fightMusicPlaylist.sounds.length;
            rnd = int(Math.random() * count);
            for each(playlistSound in this._fightMusicPlaylist.sounds)
            {
               if(rnd == 0)
               {
                  this._fightMusic = playlistSound;
                  break;
               }
               rnd--;
            }
         }
         else
         {
            for each(ambientSound in this._fightMusics)
            {
               count++;
            }
            rnd = int(Math.random() * count);
            for each(ambientSound in this._fightMusics)
            {
               if(rnd == 0)
               {
                  this._fightMusic = ambientSound;
                  break;
               }
               rnd--;
            }
         }
         if(this._bossMusicPlaylist && this._bossMusicPlaylist.sounds.length > 0)
         {
            count = this._bossMusicPlaylist.sounds.length;
            rnd = int(Math.random() * count);
            for each(playlistSound in this._bossMusicPlaylist.sounds)
            {
               if(rnd == 0)
               {
                  this._bossMusic = playlistSound;
                  break;
               }
               rnd--;
            }
         }
         else
         {
            for each(ambientSound in this._bossMusics)
            {
               count++;
            }
            rnd = int(Math.random() * count);
            for each(ambientSound in this._bossMusics)
            {
               if(rnd == 0)
               {
                  this._bossMusic = ambientSound;
                  break;
               }
               rnd--;
            }
         }
      }
      
      private function init() : void
      {
         this._fightMusicsId = TubulSoundConfiguration.fightMusicIds;
         this._fightMusicBalanceManager = new BalanceManager(this._fightMusicsId);
      }
      
      private function createPlaylistSounds(playlist:Playlist) : Array
      {
         var playlistSound:* = null;
         var music:* = null;
         var soundUriM:* = null;
         var soundPathM:* = null;
         var iteration:int = 0;
         var songsContainer:Array = new Array();
         for each(playlistSound in playlist.sounds)
         {
            if(!(this._fightMusic && playlistSound.id == this._fightMusic.id || this._bossMusic && playlistSound.id == this._bossMusic.id))
            {
               soundPathM = SoundUtil.getConfigEntryByBusId(playlistSound.channel);
               soundUriM = new Uri(soundPathM + playlistSound.id + ".mp3");
               if(SoundManager.getInstance().manager is ClassicSoundManager)
               {
                  music = SoundFactory.getSound(EnumSoundType.UNLOCALIZED_SOUND,soundUriM);
                  music.busId = playlistSound.channel;
               }
               if(SoundManager.getInstance().manager is RegSoundManager)
               {
                  music = new SoundDofus(String(playlistSound.id));
               }
               iteration = playlist.iteration;
               if(iteration <= 0)
               {
                  iteration = 1;
               }
               music.setLoops(iteration);
               music.volume = playlistSound.volume / 100;
               music.currentFadeVolume = 0;
               songsContainer.push(music.id);
            }
         }
         return songsContainer;
      }
   }
}
