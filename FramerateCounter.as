﻿package {	import flash.display.MovieClip;	import flash.events.Event;	import flash.utils.getTimer;	public class FramerateCounter extends MovieClip	{		private var savedTime:Number = 0;		private var frames:int = 0;		public function FramerateCounter()		{			textfield.text = "hallo";			addEventListener(Event.ENTER_FRAME,onEnterFrame);		}		private function onEnterFrame(e:Event)		{			var delta = (getTimer() - savedTime) / 1000;			frames ++			;			if (delta>1)			{				var fps = Math.round((frames / delta));				textfield.text = fps + " fps";				savedTime = getTimer();				frames = 0				;			}		}	}}