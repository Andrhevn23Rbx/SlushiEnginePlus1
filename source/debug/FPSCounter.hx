package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import cpp.vm.Gc;
import lime.system.System as LimeSystem;
import external.memory.Memory;
import haxe.Timer;
import Type;

class FPSCounter extends TextField
{
	public var currentFPS(default, null):Int;
	public var memoryMegas(get, never):Float;

	private var times:Array<Float> = [];
	private var deltaTimeout:Float = 0.0;

	private var avg:Float = 0;
	private var os:String;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 16, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		// OS Info
		if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
			os = 'OS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end;
		else
			os = 'OS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end + ' - ${LimeSystem.platformVersion}';
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		if (deltaTimeout < 1000 / ClientPrefs.data.fpsRate) {
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = Math.round(times.length);
		avg = times.length > 0 ? 1000 / ((times[times.length - 1] - times[0]) / times.length) : 0;

		updateText();
		deltaTimeout = 0.0;
	}

	public dynamic function updateText():Void
	{
		var ramUsage:String = CoolUtil.formatBytes(Memory.getCurrentUsage(), 2, true);
		var ramPeak:String  = CoolUtil.formatBytes(Memory.getPeakUsage(), 2, true);
		var ramLimit:String = CoolUtil.formatBytes(Gc.memInfo64(Gc.MEM_INFO_USAGE), 2, true);

		text = 'FPS: $currentFPS\n' +
			   'RAM: $ramUsage / $ramLimit / $ramPeak\n' +
			   os + '\n' +
			   'State: ${Type.getClassName(Type.getClass(FlxG.state))}\n' +
			   'SubState: ${Type.getClassName(Type.getClass(FlxG.state.subState))}';

		// FPS color: gradient from red to green based on FPS
		textColor = Std.int(
			0xFFFF0000 +
			(Std.int(CoolUtil.normalize(currentFPS, 1, ClientPrefs.data.framerate >> 1, true) * 255) << 8) +
			Std.int(CoolUtil.normalize(currentFPS, ClientPrefs.data.framerate >> 1, ClientPrefs.data.framerate, true) * 255)
		);
	}

	inline function get_memoryMegas():Float
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);

	#if cpp
	#if windows
	@:functionCode('
		SYSTEM_INFO osInfo;
		GetSystemInfo(&osInfo);
		switch(osInfo.wProcessorArchitecture)
		{
			case 9: return ::String("x86_64");
			case 5: return ::String("ARM");
			case 12: return ::String("ARM64");
			case 6: return ::String("IA-64");
			case 0: return ::String("x86");
			default: return ::String("Unknown");
		}
	')
	#elseif (ios || mac)
	@:functionCode('
		const NXArchInfo *archInfo = NXGetLocalArchInfo();
		return ::String(archInfo == NULL ? "Unknown" : archInfo->name);
	')
	#else
	@:functionCode('
		struct utsname osInfo{};
		uname(&osInfo);
		return ::String(osInfo.machine);
	')
	#end
	private function getArch():String return "Unknown";
	#end
}
