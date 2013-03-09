﻿ package  {		import flash.display.MovieClip;	import flash.events.Event;	import flash.geom.Point;	import flash.utils.getDefinitionByName			public class Particle extends MovieClip {				public var available:Boolean=true;		private var lifetime:Number=0;		private var velocityx:Number;		private var velocityy:Number;		private var gravity:Number=0		private var mainscript:Main;		private var startx:Number;		private var starty:Number;		private var pt:Point;		//settings		private var maxlifetime:Number=200;		private var startdistance:Number;		public var particleImage:MovieClip		public var angularVelocity:Number=0						public function Particle(inParticleName:String) {						var particleClass:Class = getDefinitionByName(inParticleName) as Class			particleImage = new particleClass()											addChild(particleImage)									// constructor code		}				public function begin(inscript:Main,emitter:Emitter) {						mainscript = inscript;			startdistance = mainscript.cardistance;						available = false;							startx=emitter.followclip.x + emitter.offsetx;			starty=emitter.followclip.y + emitter.offsety;						var partscale = 1+3*Math.random();			this.scaleX = partscale;			this.scaleY = partscale;						this.angularVelocity = 30*Math.random()									velocityx = emitter.getVelocityX() - (emitter.getVelocityRange()/2) + emitter.getVelocityRange()*Math.random()			velocityy = emitter.getVelocityY() - (emitter.getVelocityRange()/2) + emitter.getVelocityRange()*Math.random()			gravity = emitter.getGravity()			//velocityx = -1 - 4*Math.random();			//velocityy = -16 + 12*Math.random();			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);			blendMode = emitter.blendmode		}				private function onEnterFrame(e:Event) {						lifetime++;						//rotation = rotation + this.angularVelocity						alpha = alpha - 0.01			if (lifetime>maxlifetime) {				recycle();			}			else {				//scroll is difference in cardistance since spawn				x=startx + (this.velocityx*lifetime) + (startdistance - mainscript.cardistance);				y=starty + (this.velocityy*lifetime);				velocityy = velocityy + gravity;			}					}				private function recycle() {						this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);			available = true;			x=0;			y=0;			this.scaleX = 0.5;			this.scaleY = 0.5;			alpha=1;			lifetime=0;		}			}	}