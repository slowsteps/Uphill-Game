﻿package  {		import flash.display.MovieClip;	import flash.events.Event;	import flash.utils.Timer;	import flash.events.TimerEvent;			public class Emitter extends MovieClip {				private var mainscript;		private var particlepool:Array;		public var emitTimer:Timer 		public var followclip:MovieClip;		public var offsetx:Number;		public var offsety:Number;		public var velx:Number=0;		public var vely:Number=-1;		public var gravity:Number=0;		public var range:Number=10;		public var particleImage:String		public var blendmode:String="normal"		public var alphaDecaySpeed:Number = 0.01		public var shape:String = "point"		public static const AREA:String = "area"		public static const POINT:String = "point"				public function Emitter() {					}				//ERROR offsets don't update rotation				public function setup(caller,follow,xoff,yoff,particleName) {						mainscript = caller;			followclip = follow;			trace(this,followclip.name,particleName)			offsetx = xoff;			offsety = yoff;			particleImage = particleName			createParticlePool();			emitTimer = new Timer(60,0);			emitTimer.addEventListener(TimerEvent.TIMER,onEmit)			Start();		}				private function createParticlePool() {			particlepool = new Array();			for (var i=0;i<30;i++) {				var aParticle:Particle = new Particle(particleImage);				if (mainscript.zoomcontainer) mainscript.zoomcontainer.addChild(aParticle);				else mainscript.addChild(aParticle);				particlepool.push(aParticle);			}		}				public function Start() {			emitTimer.start();		}			public function Stop() {			emitTimer.stop();					}				public function Destroy() {			emitTimer.removeEventListener(TimerEvent.TIMER,onEmit)			trace(this.name, " destroyed")			for each (var part:Particle in particlepool) {				part.Destroy()			}						particlepool = null		}			private function onEmit(e:Event) {			for each (var aParticle:Particle in particlepool) {				if (aParticle.available) {					aParticle.begin(mainscript,this);					break;				}			}		}				public function setVelocity(invelx:Number,invely:Number,inrange:Number) {			velx = invelx			vely = invely			range = inrange		}				public function setGravity(ingrav:Number) {			gravity = ingrav		}				public function setBlendmode(inBlendmode:String) {			blendmode = inBlendmode		}				public function setalphaDecaySpeed(inalphaDecaySpeed:Number) {			alphaDecaySpeed = inalphaDecaySpeed		}				public function setEmitterShape(inShape:String) {			this.shape = inShape		}				public function getVelocityX():Number {			return velx		}				public function getVelocityY():Number {			return vely		}				public function getVelocityRange():Number {			return range		}				public function getGravity():Number {			return gravity		}					}	}