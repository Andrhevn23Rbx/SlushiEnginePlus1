override function create()
{
	super.create();

	// Instantly skip to main menu without showing anything
	leftState = true;
	MusicBeatState.switchState(new MainMenuState());
}

