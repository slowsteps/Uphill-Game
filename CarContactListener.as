﻿package{    import Box2D.Dynamics.Contacts.b2Contact;    import Box2D.Dynamics.b2ContactListener;    import flash.utils.Timer;    import flash.events.TimerEvent;    import flash.utils.getTimer;    import Box2D.Common.Math.b2Vec2;	import Box2D.Common.Math.*;	import flash.display.Shape;     public class CarContactListener extends b2ContactListener    {		public var mainScript:Main;		private var frontwheelAirborne:Boolean = true;		private var rearwheelAirborne:Boolean = true;		private var carAirborne:Boolean = true;		private var airtime:int = 0;		private var airTimer:Timer;		private var frontwheelTimestamp:Number;		private var rearwheelTimestamp:Number;		private var frameticker:int = 0;		private var myshape:Shape;					        public function CarContactListener()        {						        }				public function setParentScript(inScript:Main) {			mainScript = inScript;			myshape = new Shape();			mainScript.addChild(myshape);		}         override public function BeginContact(contact:b2Contact):void        {						//trace(airtime);						var collidernameA:String = contact.GetFixtureA().GetBody().GetUserData();			var collidernameB:String = contact.GetFixtureB().GetBody().GetUserData();						if (collidernameB == "frontwheel") {				//mainScript.frontwheelclip.alpha = 0.5;			}			else if (collidernameB == "rearwheel"){				//mainScript.backwheelclip.alpha = 0.5;			}			else if (collidernameA == "roof") {				if (!mainScript.gameover) mainScript.setGameOver(Gamestate.CRASH);			}										}				override public function EndContact(contact:b2Contact):void        {						if (contact.GetFixtureB().GetBody().GetUserData() == "frontwheel") {				frontwheelAirborne = true;				mainScript.frontwheelclip.alpha = 1;			}			if (contact.GetFixtureB().GetBody().GetUserData() == "rearwheel") {				rearwheelAirborne = true;				mainScript.backwheelclip.alpha = 1;			}						        }				    }}