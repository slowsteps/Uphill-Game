﻿package  {	import flash.display.MovieClip;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.KeyboardEvent;	import com.greensock.TweenMax;	import com.greensock.*;	import com.greensock.easing.*;		public class GameoverScreen extends MovieClip {		private var myLoader:GameLoader		private var myReason:String				public function GameoverScreen(inLoader:GameLoader) {			trace(this,this.name,Math.random())			myLoader = inLoader						x = 200			y = (height + myLoader.stage.fullScreenHeight)/2			continuebutton.addEventListener(MouseEvent.CLICK,onContinue)					}		public function show(inreason:String,inbonus:int) {			myReason = inreason			this.textfield.text = inreason			this.rewardtextfield.text = "Distance bonus $" + inbonus			visible = true			TweenMax.from(this, 2, {alpha:0,delay:2,onComplete:showComplete});					}		private function showComplete() {			//myLoader.stage.addEventListener(KeyboardEvent.KEY_DOWN,onContinue)		}		private function onContinue(e:Event) {						visible = false			//myLoader.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onContinue)			if (myReason == Gamestate.RABBIT_VICTORY) myLoader.showEnding()			else myLoader.shop.show()		}	}	}