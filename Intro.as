﻿package  {		import flash.display.MovieClip;	import flash.events.Event;	import flash.events.Event;	import flash.events.MouseEvent;	import com.greensock.TweenLite;	import com.greensock.easing.*;					public class Intro extends MovieClip {			//private var start:MovieClip							//for particle Emitter		public var zoomcontainer		public var cardistance=0					public function Intro() {			trace(this,this.name,Math.random())									zoomcontainer = new MovieClip()			this.addChild(zoomcontainer)						TweenLite.from(menudino,0.5,{x:-300})			TweenLite.from(rabbit,0.5,{x:1000})			TweenLite.from(logo,0.5,{y:-200})										}											}	}