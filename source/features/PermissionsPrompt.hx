package features;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

// too fucking lazy to delete this and set up properly shit
class PermissionsPrompt extends MusicBeatState
{
	override function create()
	{
		PlayerSettings.init();

		FlxG.save.bind('funkin', 'sanicbtw');
		SaveData.loadSettings();
		Paths.prepareLibraries();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());

		super.create();
	}
}
