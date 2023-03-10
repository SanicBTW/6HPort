package substates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.system.System;

class GameOverSubstate extends MusicBeatSubstate
{
	var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static function resetVariables()
	{
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		if (SaveData.get(SNAP_CAMERA_ON_GAMEOVER))
			FlxG.camera.focusOn(camFollow);

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		#if android
		addVirtualPad(NONE, A_B);
		addPadCamera();
		#end
	}

	var isFollowingAlready:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (updateCamera)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			#if android
			removeVirtualPad();
			#end
			endBullshit(function()
			{
				MusicBeatState.resetState();
			});
		}

		if (controls.BACK)
		{
			endBullshit(function()
			{
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				#if android
				removeVirtualPad();
				#end

				MusicBeatState.switchState(new FreeplayState());

				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}, false);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if (boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = (!SaveData.get(SNAP_CAMERA_ON_GAMEOVER));
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == "tank")
				{
					playingDeathSound = true;
					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound("jeffGameover/jeffGameover-" + FlxG.random.int(1, 25)), 1, false, null, true, function()
					{
						if (!isEnding)
						{
							FlxG.sound.music.fadeIn(1, 0.2, 1);
						}
					});
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit(cb:Void->Void, playAnimSound:Bool = true):Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			if (playAnimSound)
			{
				boyfriend.playAnim('deathConfirm', true);
				FlxG.sound.play(Paths.music(endSoundName));
			}
			else
			{
				FlxG.sound.play(Paths.sound("cancelMenu"));
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, cb);
			});
		}
	}
}
