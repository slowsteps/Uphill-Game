﻿package  {		import flash.display.MovieClip;	import flash.events.Event;			public class Particle extends MovieClip {				public var available:Boolean=true;		private var lifetime:Number=0;		private var velocityx:Number;		private var mainscript:Main;		private var startx:Number;		//settings		private var maxlifetime:Number=150;				public function Particle() {			// constructor code		}				public function begin(inscript) {			mainscript = inscript;						available = false;						startx=mainscript.cardistance - 170;			//TODO get global spawnpos positions from emitter instead of car - Now not resuable.			y=mainscript.carclip.y;			var partscale = 5*Math.random();			this.scaleX = partscale;			this.scaleY = partscale;			velocityx = 1 + 5*Math.random();			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);					}				private function onEnterFrame(e:Event) {						lifetime++;			if (lifetime>maxlifetime) {								recycle();			}			x = 400 + startx - mainscript.cardistance;			alpha = alpha - 0.05;			y--;		}				private function recycle() {			this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);			available = true;			x=0;			alpha=1;			lifetime=0;		}			}	}