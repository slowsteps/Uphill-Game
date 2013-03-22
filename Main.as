﻿package {	import flash.display.Sprite;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.display.Graphics;	import flash.display.Shape;	import Box2D.Dynamics.*;	import Box2D.Collision.*;	import Box2D.Collision.Shapes.*;	import Box2D.Common.Math.*;	import Box2D.Dynamics.Joints.*;	import Box2D.Dynamics.b2Body;	import flash.display.MovieClip;	import flash.text.TextField;	import flash.utils.getTimer;	import flash.utils.Timer;    import flash.events.TimerEvent;    import flash.geom.Point;	import com.greensock.TweenLite;	import com.greensock.easing.*;					public final class Main extends Sprite {		public var myLoader:GameLoader;		public var stageheight:int=450;		public var stagewidth:int=800;		public var gameover:Boolean=false;		private var world:b2World=new b2World(new b2Vec2(0,10.0),true);		private var worldScale:int=30;		private var worldstep:int=30		public var car:b2Body;		public var roof:b2Body;		public var cardistance:Number=0;		public var carspeed:Number;		public var zoomcontainer:MovieClip;		private var zoom:Number=1;		private var pickupClips: Array;		public var carclip:Car;		public var cardown:Cardown;		public var frontwheelclip:Wheel;		public var backwheelclip:Wheel;		private var rabbitBalloon:TextBalloon		private var dinoBalloon:TextBalloon				private var fuelempty:Boolean = false;		private var rearWheel:b2Body;		private var frontWheel:b2Body;		private var rearAxle:b2Body;		private var frontAxle:b2Body;				private var sliceClips:Array;		private var sliceBodies:Array;		private var rearMotor:b2RevoluteJoint;		private var frontMotor:b2RevoluteJoint;		private var left:Boolean=false;		private var right:Boolean=false;		private var clockwise:Boolean=false;		private var anticlockwise:Boolean=false;		private var space:Boolean=false;				private var motorSpeed:Number=0;		private var frontSpring:b2PrismaticJoint;		private var rearSpring:b2PrismaticJoint;		private var debugclip;		private var hillControlpoints:Array; //the points that are interpolated for the hill shape		private var bunnyParticleEmitter:Emitter;		private var bunnyParticleEmitter2:Emitter;		private var dinoParticleEmitter:Emitter 		public var frametick:int=0;		public var dino:Dino		private var dinoSavedX:Number		private var dinoVelocityX:Number = 0		public var portal:Portal		public var portalFront:PortalFront		private var closeToPortal:Boolean=false		private var portalFlare:Flare		private var portalSavedX:Number		public const DINO_VICTORY:String="dino victory"		public const RABBIT_VICTORY:String="rabbit victory"		public const OUT_OF_FUEL:String="out of fuel"		public const CRASH:String="player crashed"		private var distanceToPortal:Number		private var savedFuelbarWidth:Number		private var savedPortalbarWidth:Number		private var savedY2:Number		private var backgroundAnim:MovieClip						//car settings				private var debugging:Boolean = false;		private var fuel:int = 0;		private var maxfuel:int = 0;		private var carWheelTorque:int = 300;		private var carAirborneTorque:int = 1000;		private var carShockDamper:int = 100;  //bigger is bouncier		private var springforceAmp:Number = 20 //low number, stiffer suspension		private var globalRestitution:Number = 0.1		private var zoomInterpolationStrength:Number = 0.02 //low number, slow reaction		private var zoomStrength = 0.02 // big number, bigger scale		private var startingZoom = 0.5 // zoom at speed 0		private var numhills:int = 200; //big number, big level.		private var slicewidth:int = 100; //low number, narrow hills		private var hillAmp:int = 500 //hill height		private var maxglidetime:Number = 100; //maximum amount of gliding		private var prescroll:Number = 400; //scroll the level before starting		private var pickupdensity:Number = 0.05 //between 0 and 1 - percentage of pickup		private var fuelconsumption:Number = 1;		private var glidingFuelconsumption:Number = 1;		private var frontwheelradius: Number = 60;		private var backwheelradius: Number = 60;		private var lineardamping:Number = 0.05 //experimental		private var angledamping:Number = 0.90		private var friction:Number = 0.99 //below 1 is slippy		private var motorDamping = 0.98 // low number is slower		private var portalY = 500		private var dinoMaxSpeed = 10;							public function Main(inLoader:GameLoader):void {			trace(this,this.name,Math.random())			this.myLoader = inLoader			loadGameData()			createUtilities();			createHillData();			createPickups();			createDino()			createCarVisuals();			createCollisonSystem();			createPhysicsModel();			createPortal()			createHUD()			addEventListener(Event.ENTER_FRAME,onEnterFrame);					}				private function loadGameData() {						this.frontwheelradius = myLoader.shop.products.wheel.upgradesValue[myLoader.shop.products.wheel.upgradesBought]			this.backwheelradius = this.frontwheelradius			this.fuel = myLoader.shop.products.fuel.upgradesValue[myLoader.shop.products.fuel.upgradesBought]			this.maxfuel = myLoader.shop.products.fuel.upgradesValue[myLoader.shop.products.fuel.upgradesValue.length - 1]			this.motorDamping = myLoader.shop.products.engine.upgradesValue[myLoader.shop.products.engine.upgradesBought]			this.pickupdensity = myLoader.shop.products.luck.upgradesValue[myLoader.shop.products.luck.upgradesBought]						//used in updateDistance			savedFuelbarWidth = HUDFuel.fuelbar.width			savedPortalbarWidth = HUDDistance.portalbar.width		}				private function createUtilities() {			//needs to be done otherwise stage is null			addEventListener(Event.ADDED_TO_STAGE, stageAddHandler);			//car and level will be added to a container clip for zooming			zoomcontainer = new MovieClip();			addChild(zoomcontainer);			zoomcontainer.y=stageheight;			//visual rep of zoomcontainer			//zoomcontainer.addChild(new Crosshair());		}				private function stageAddHandler(e:Event) {			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);			stage.addEventListener(KeyboardEvent.KEY_UP,keyReleased);		}				private function createHUD() {			TweenLite.from(HUDFuel,1,{y:-100,ease:Elastic.easeOut,delay:1})			TweenLite.from(HUDDistance,1,{y:-100,ease:Elastic.easeOut,delay:1})					}				public function createCarVisuals() {									carclip = new Car();			zoomcontainer.addChild(carclip);			cardown = new Cardown()			zoomcontainer.addChild(cardown);			cardown.visible = false			frontwheelclip = new Wheel();			frontwheelclip.width = frontwheelradius*2;			frontwheelclip.height = frontwheelradius*2;			zoomcontainer.addChild(frontwheelclip);			backwheelclip = new Wheel();			backwheelclip.width = backwheelradius*2;			backwheelclip.height = backwheelradius*2;			zoomcontainer.addChild(backwheelclip);						rabbitBalloon = new TextBalloon(this,carclip)			dinoBalloon = new TextBalloon(this,dino,-200,"right")			rabbitBalloon.show("I own that portal")			dinoBalloon.show("I love my jetpack")						bunnyParticleEmitter = new Emitter();			bunnyParticleEmitter.setup(this,backwheelclip,0,50,"ParticleOrange");			bunnyParticleEmitter.setVelocity(-1,0,10);						bunnyParticleEmitter2 = new Emitter();			bunnyParticleEmitter2.setup(this,backwheelclip,0,50,"ParticleFireSpark");			bunnyParticleEmitter2.setGravity(0.1)			bunnyParticleEmitter2.setBlendmode("add")			bunnyParticleEmitter2.setVelocity(-0.2,-3,10);						zoomcontainer.addChild(bunnyParticleEmitter);			zoomcontainer.addChild(bunnyParticleEmitter2);								}				//physics hill slice		public function createSlice(posx,slicewidth,y1,y2):b2Body {						var floorShape:b2PolygonShape = new b2PolygonShape();					var floorVector:Vector.<b2Vec2>=new Vector.<b2Vec2>();			floorVector[0]=new b2Vec2(0/worldScale,0/worldScale);			floorVector[1]=new b2Vec2(0/worldScale,-y1/worldScale);			floorVector[2]=new b2Vec2(slicewidth/worldScale,-y2/worldScale);			floorVector[3]=new b2Vec2(slicewidth/worldScale,0/worldScale);			floorShape.SetAsVector(floorVector,4);					var floorFixture:b2FixtureDef = new b2FixtureDef();			floorFixture.density=0;			floorFixture.friction=friction;			floorFixture.restitution=globalRestitution;			floorFixture.shape=floorShape;			// body definition			var floorBodyDef:b2BodyDef = new b2BodyDef();						floorBodyDef.position.Set(posx/worldScale,stageheight/worldScale);			// the floor itself			var floor:b2Body=world.CreateBody(floorBodyDef);			floor.CreateFixture(floorFixture);			floor.SetUserData("floor");			return floor;				}				private function debugDraw():void {			var worldDebugDraw:b2DebugDraw=new b2DebugDraw();			var debugSprite:Sprite = new Sprite();			debugclip = zoomcontainer.addChild(debugSprite);			debugclip.y = -stageheight;			worldDebugDraw.SetSprite(debugSprite);			worldDebugDraw.SetDrawScale(worldScale/1);			worldDebugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);			worldDebugDraw.SetFillAlpha(0.5);			world.SetDebugDraw(worldDebugDraw);		}				private function keyPressed(e:KeyboardEvent):void {												switch (e.keyCode) {				case 39 :					clockwise = true;					break;				case 37 :					anticlockwise = true;					break;				case 40 :					left=true;					break;				case 38 : 					right=true;					break;				case 32 :					space=true			}		}				private function keyReleased(e:KeyboardEvent):void {			switch (e.keyCode) {				case 39 :					clockwise = false;					break;				case 37 :					anticlockwise = false;					break;				case 40 :					left=false;					break;				case 38 :					right=false;					break;				case 32 :					space=false;			}		}										public function setGameOver(reason:String) {									if (!gameover) {				gameover = true;				fuelempty = true;				rearAxle.SetActive(false);				frontAxle.SetActive(false);				frontSpring.EnableLimit(false);				frontSpring.EnableMotor(false);				rearSpring.EnableLimit(false);				rearSpring.EnableMotor(false);				//car.ApplyForce(new b2Vec2(0,300),new b2Vec2(0,0));				rearWheel.ApplyForce(new b2Vec2(0,1),new b2Vec2(0,0));				frontWheel.ApplyForce(new b2Vec2(0,1),new b2Vec2(0,0));								var bonus:int = Math.round(100*cardistance/this.distanceToPortal)				if (bonus<0) bonus = 0				myLoader.shop.addCoins(bonus)												if (reason == Gamestate.CRASH ) {					rabbitBalloon.show("poo")					dinoBalloon.show("You shouldn't do that")					dino.laugh()					myLoader.gameoverScreen.show(Gamestate.CRASH,bonus)					this.showSadRabbit()				}				if (reason == Gamestate.OUT_OF_FUEL ) {					rabbitBalloon.show("bugger")					dinoBalloon.show("Pathetic!")					dino.laugh()					myLoader.gameoverScreen.show(Gamestate.OUT_OF_FUEL,bonus)					this.showSadRabbit()				}				if (reason == Gamestate.OUT_OF_BOUNDS ) {					rabbitBalloon.show("Aaahhh!!")					dinoBalloon.show("Bye bye!")					dino.laugh()					myLoader.gameoverScreen.show(Gamestate.OUT_OF_BOUNDS,bonus)					this.showSadRabbit()				}				if (reason == Gamestate.DINO_VICTORY ) {					rabbitBalloon.show("nrghh")					dinoBalloon.show("See ya!")					dino.visible = false					this.showSadRabbit()					portal.visible = false					portalFront.visible = false					portalFlare.show(dino)					dinoParticleEmitter.Stop()					myLoader.gameoverScreen.show(Gamestate.DINO_VICTORY,bonus)				}				if (reason == Gamestate.RABBIT_VICTORY ) {					rabbitBalloon.show("into the void!")					portal.visible = false					portalFront.visible = false					world.SetGravity(new b2Vec2(0,0))					car.SetLinearVelocity(new b2Vec2(0,0))					carclip.visible = false					backwheelclip.visible = false					frontwheelclip.visible = false					bunnyParticleEmitter.Stop()					bunnyParticleEmitter2.Stop()										dinoVelocityX = 0					myLoader.gameoverScreen.show(Gamestate.RABBIT_VICTORY,bonus)					portalFlare.show(carclip)									}											}		}						private function onEnterFrame(e:Event) {			updatePhysics();			updateVisuals();		}				private function updatePhysics():void {									if (left && !fuelempty) {				motorSpeed+=0.5;			}						if (right && !fuelempty) {				motorSpeed-=0.5;				fuel = fuel - fuelconsumption;				bunnyParticleEmitter.emitTimer.start();				bunnyParticleEmitter2.emitTimer.start();			}			else {				bunnyParticleEmitter.emitTimer.stop();				bunnyParticleEmitter2.emitTimer.stop();			}			if (clockwise) {				car.ApplyTorque(carAirborneTorque);			}			if (anticlockwise) {				car.ApplyTorque(-carAirborneTorque);			}			if (space) {				var jumpForce = new b2Vec2(0,-1000)				//roof.ApplyForce(jumpForce,new b2Vec2(15,0))			}												//push rotation back to 0 degrees									//if (Math.abs(car.GetAngle()) < 1) car.ApplyTorque(-500*car.GetAngle())			car.ApplyTorque(-500*car.GetAngle())						motorSpeed*=motorDamping;			if (motorSpeed>100) {				motorSpeed=100;			}						//TODO try and understand this http://www.emanueleferonato.com/2009/04/06/two-ways-to-make-box2d-cars/ 						rearMotor.SetMotorSpeed(motorSpeed);			frontMotor.SetMotorSpeed(motorSpeed);																		var springforce:Number ;			if(frontSpring.GetJointTranslation()<0) springforce = Math.abs(springforceAmp*frontSpring.GetJointTranslation());			else springforce = 0;						//trace(springforce);			var baseMotorForce = 1000			rearSpring.SetMaxMotorForce(baseMotorForce - springforce*2);			rearSpring.SetMotorSpeed(frontSpring.GetMotorSpeed() -baseMotorForce - springforce);									frontSpring.SetMaxMotorForce(baseMotorForce - springforce*2);			frontSpring.SetMotorSpeed(frontSpring.GetMotorSpeed() - baseMotorForce - springforce);						//rearSpring.SetMaxMotorForce(Math.abs(1000/rearSpring.GetJointTranslation()));							world.Step(1/this.worldstep,10,10);			world.ClearForces();			world.DrawDebugData();										}				private function updateVisuals() {						if (!this.gameover) {				updateDistance();				updateFuel();				updateDino()				updatePortal()			}						//zoom camera			var speedfactor = car.GetLinearVelocity().Length();						zoom = zoom +  zoomInterpolationStrength*((1 + zoomStrength*speedfactor) - zoom)						zoomcontainer.scaleX=startingZoom/zoom;			zoomcontainer.scaleY=startingZoom/zoom;						if (debugging) debugclip.x = 250 - worldScale*car.GetPosition().x;						//TODO Cache			cardistance = worldScale*car.GetPosition().x;						//BIND car movieclips to bodies and rotate			carclip.x = stagewidth / 2;			carclip.y = -stageheight + worldScale*car.GetPosition().y;			carclip.rotation = car.GetAngle() * (180/Math.PI) % 360 ;			if (this.gameover) {				cardown.x = carclip.x				cardown.y = carclip.y				cardown.rotation = carclip.rotation			}			backwheelclip.x = carclip.x - cardistance + worldScale*rearWheel.GetPosition().x;			backwheelclip.y = -stageheight + worldScale*rearWheel.GetPosition().y;			backwheelclip.rotation = rearWheel.GetAngle() * (180/Math.PI) % 360;									frontwheelclip.x = carclip.x - cardistance  + worldScale*frontWheel.GetPosition().x			frontwheelclip.y = -stageheight + worldScale*frontWheel.GetPosition().y			frontwheelclip.rotation = 50 + frontWheel.GetAngle() * (180/Math.PI) % 360;			if (Math.abs(carclip.rotation) < 45) {				carclip.earRight.rotation = carclip.earRight.rotation + (carclip.rotation - carclip.earRight.rotation)/10				carclip.earLeft.rotation = carclip.earLeft.rotation + (carclip.rotation +30 -carclip.earLeft.rotation)/15			}						//SCROLL PICKUPS TODO needs offscreen culling						var i:int						for (i=0;i<pickupClips.length;i++) {				//scroll				if (!pickupClips[i].collected) pickupClips[i].x = prescroll + pickupClips[i].startx - cardistance;				//collision detection with car				var deltax = pickupClips[i].x - carclip.x;				var deltay = pickupClips[i].y - carclip.y;				var dist = Math.sqrt( (deltax*deltax) + (deltay*deltay));								//if not already collected and in collision with car, remove, add fuel and display fx.				if (!pickupClips[i].collected && dist < 100) {										pickupClips[i].Collect();									}			}						//TODO replace by for each			//SCROLL SLICES and optimze for offscreen items			for (i=0;i<sliceClips.length;i++) {				//TODO safe the startx instead of working with the width				sliceClips[i].x = prescroll + i*sliceClips[i].width - cardistance;								if (sliceClips[i].x < -sliceClips[i].width || sliceClips[i].x > (stagewidth/zoomcontainer.scaleX)) {					sliceClips[i].visible = false;					//TODO - only the bodies below the car need to be active, not all in screen					sliceBodies[i].SetActive(false);				}				//clip and body slice onscreen				else {					//trace("Zoom " + zoom);					sliceClips[i].visible = true;					sliceBodies[i].SetActive(true);				}							}				}				//todo allow for fuel pickup while fuel empty, finish when fuel==0 and speed==0		private function updateFuel() {			if (fuel<0) fuel = 0;			HUDFuel.fuellabel.text = fuel.toString();						HUDFuel.fuelbar.width = savedFuelbarWidth - (fuel/maxfuel)*savedFuelbarWidth									if (fuel < 1) {				fuelempty = true;				if (car.GetLinearVelocity().Length() < 2) {					//this.setGameOver("out of fuel");					if (!gameover) this.setGameOver(Gamestate.OUT_OF_FUEL)				}			}						else {				fuelempty = false;			}		}								private function showSadRabbit() {			carclip.visible = false			cardown.visible = true			var sadEmitter:Emitter = new Emitter()			sadEmitter.setup(this,cardown,0,0,"ParticleWhite");			sadEmitter.setVelocity(0,-0.3,2)			sadEmitter.setGravity(0)			sadEmitter.Start()						var sadEmitter2:Emitter = new Emitter()			sadEmitter2.setup(this,cardown,0,0,"ParticleFireSpark");			sadEmitter2.setVelocity(0,-3.5,10)			sadEmitter2.setGravity(0.05)			sadEmitter2.setBlendmode('add')			sadEmitter2.Start()											}				//distance related UI and effects								private function createDino() {			dino = new Dino()			zoomcontainer.addChild(dino)			dino.x = 800			dino.y = -650			this.dinoSavedX = 700;			dinoParticleEmitter = new Emitter();			dinoParticleEmitter.setup(this,dino,-60,180,"ParticleWhite");			dinoParticleEmitter.setVelocity(5,10,5)			dinoParticleEmitter.setGravity(-0.1)			dino.stop()  //stop laughing		}				private function updateDino() {						frametick++			if (dinoVelocityX< dinoMaxSpeed) dinoVelocityX = dinoVelocityX + 0.1			dinoSavedX = dinoSavedX + dinoVelocityX			if (!this.gameover) dino.x = dinoSavedX - cardistance			dino.y = -650 + 20*Math.sin(frametick/10)		}				private function createPortal() {			portal = new Portal()			portalFront = new PortalFront()			zoomcontainer.addChild(portal)			zoomcontainer.addChild(portalFront)			zoomcontainer.setChildIndex(portal,0)						portalSavedX = numhills*slicewidth + prescroll + 500			portal.y = -sliceClips[this.numhills-1].top						portalFlare = new Flare(this)					}				private function updatePortal() {			portal.x = portalSavedX - cardistance			portalFront.x = portal.x			portalFront.y = portal.y			//portalFlare.x = portal.x			//portalFlare.y = portal.y						if (cardistance + 2000 > portalSavedX) {				if (!closeToPortal) {					closeToPortal = true					var slomo = 3					this.worldstep = worldstep * slomo					this.dinoVelocityX = this.dinoVelocityX / slomo				}			}			if (cardistance > portalSavedX) {				if (!gameover) this.setGameOver(Gamestate.RABBIT_VICTORY)			}			if (dinoSavedX > portalSavedX) {				if (!gameover) {					this.setGameOver(Gamestate.DINO_VICTORY)				}			}		}				private function updateDistance() {						if (carclip.y>0) setGameOver(Gamestate.OUT_OF_BOUNDS)									if ((distanceToPortal - cardistance) > 0 ) {				HUDDistance.distance.text = Math.round(0.01*(distanceToPortal - cardistance)) + " M";				HUDDistance.portalbar.width = savedPortalbarWidth - (cardistance/distanceToPortal)*savedPortalbarWidth			}			else {				HUDDistance.distance.text = "0 M"				HUDDistance.portalbar.width = 0			}			//var needle:int = Math.round(backgroundAnim.totalFrames*cardistance/distanceToPortal)			//backgroundAnim.gotoAndStop(needle)					}												//TODO make 2 dimensonal array with list of x,y pairs. hillfunction should find two surrounding x values and return the interpolated y value.		//or make equal size 1 dimensional array and check for null. Option 1 seems safer.				//create noise array and return interpolated values		public function hillFunction(x:int):Number {			//fil up and array with randon numbers, on random intervals and make block hills.						var x1 = getLower(x)[0];			var y1 = getLower(x)[1];			var x2 = getHigher(x)[0];			var y2 = getHigher(x)[1];			return interpolate(x1,y1,x2,y2,x);					}				private function interpolate(x1,y1,x2,y2,x) {			var ret;						if (x == x1) ret = y1;			else if (x == x2) ret = y2;						else {				var xnorm = (x-x1)/(x2-x1);				//lineair				//ret = y1*(1-xnorm) + y2*xnorm;				//cosine				var ft = xnorm*3.1415927;				var f = (1 - Math.cos(ft))*0.5				ret =  y1*(1-f) + y2*f;			}						return ret;		}				private function getLower(x) : Array {			var ret:Array = new Array();			for (var i=0;i<hillControlpoints.length;i++) {				if (hillControlpoints[i][0] > x) {					ret = hillControlpoints[i-1];					break;				}				else ret = new Array(x,300);			}			return ret;		}				//TODO merge, code duplication		private function getHigher(x) : Array {			var ret:Array = new Array();			for (var i=0;i<hillControlpoints.length;i++) {				if (hillControlpoints[i][0] > x) {					ret = hillControlpoints[i];					break;				}				else ret = new Array(x,300);			}			return ret;		}						private function createHillFunction(){			hillControlpoints = new Array();			for (var i=0;i<numhills+1;i++) {				//TODO change mod 6 into varying gap				if (i%6 == 0) {					var xypair:Array = new Array(); 					var amp:Number;					if (i<13) amp=30;					else if (i>(numhills - 3)) amp = 30					else amp=hillAmp;					xypair[0]=i;					xypair[1]=1+amp*Math.random();					hillControlpoints.push(xypair);					//NOTE this array is smaller than numhills!				}				else {									}			}					}						//generate segmented procedural hill and make box2d bodies and identical movieclips		public function createHillData() {			//first generate the shape of the hills			createHillFunction();						slicewidth = 100;			var numSlices:int;			numSlices = numhills;					distanceToPortal = numSlices * slicewidth						sliceClips = new Array();			sliceBodies = new Array();			for (var i=0;i<numSlices;i++) {				//visual hill slices, fist get two heights from the hillfunction								var y1:Number				var y2:Number								//rolling hills				if (i< (numSlices - 10) ) {					y1 = hillFunction(i);					if (i == (numSlices - 1) ) y2 = y1					else y2 = hillFunction(i+1);					savedY2 = y2				}				//ramp to portal				else {					y1 = savedY2					y2 = y1 + 20					savedY2 = y2				}								var sliceClip:Slice = new Slice();				sliceClip.setNumber(i,slicewidth,y1,y2);				zoomcontainer.addChild(sliceClip);				sliceClip.visible = false;				sliceClip.x = i*slicewidth;				sliceClip.y = 0;				sliceClip.width = slicewidth;				//save in array for scrolling loop				sliceClips.push(sliceClip);								//physics hill slices				var sliceBody:b2Body = createSlice(i*slicewidth,slicewidth,y1,y2);				//save in array for scrolling loop				sliceBodies.push(sliceBody);			}								}				private function createCollisonSystem() {			   	var aCarContactListener:CarContactListener = new CarContactListener();    			world.SetContactListener(aCarContactListener);				aCarContactListener.setParentScript(this);		}				public function createPickups() {						pickupClips = new Array();			for (var i=0;i<this.numhills;i++) {				//5% pickup density				if (Math.random()<pickupdensity) {					var aPickup:Pickup = new Pickup(this);					zoomcontainer.addChild(aPickup);					aPickup.setPosition(100*i,-sliceClips[i].top - 100 - 300*Math.random());					pickupClips.push(aPickup);				}			}		}				public function addFuel(addedfuel:int) {						if (fuel< (maxfuel - addedfuel)) fuel = fuel + addedfuel;		}				private function createPhysicsModel() {			//all the box2d setup stuff			if (debugging) debugDraw();						// ************************ THE CAR ************************ //			// shape												// fixture			var carFixture:b2FixtureDef = new b2FixtureDef();			carFixture.density=1;			carFixture.friction=0.5;			carFixture.restitution=0.2;			carFixture.filter.groupIndex=-1;						// body definition						var carShape:b2PolygonShape = new b2PolygonShape();			carShape.SetAsBox(150/worldScale,50/worldScale);			carFixture.shape=carShape;						var carBodyDef:b2BodyDef = new b2BodyDef();			carBodyDef.type=b2Body.b2_dynamicBody;									carBodyDef.angularDamping = 0.05;			carBodyDef.linearDamping = lineardamping;						//position where it's spawned in the world			carBodyDef.position.Set(0.5*stagewidth/worldScale,0.5*stageheight/worldScale);			car=world.CreateBody(carBodyDef);			car.CreateFixture(carFixture);			car.SetUserData("car");			//car.SetFixedRotation(true);						//ROOF for falling on roof gameover state			var roofFixture:b2FixtureDef = new b2FixtureDef();			roofFixture.density=0.1;			roofFixture.friction=0.1;			roofFixture.restitution=0.2;			roofFixture.filter.groupIndex=-1;			var roofShape:b2PolygonShape = new b2PolygonShape();			roofShape.SetAsBox(120/worldScale,20/worldScale);			roofFixture.shape=roofShape;						var roofBodyDef:b2BodyDef = new b2BodyDef();			roofBodyDef.type=b2Body.b2_dynamicBody;						roofBodyDef.position.Set(car.GetWorldCenter().x,car.GetWorldCenter().y+(-100/worldScale));			roof = world.CreateBody(roofBodyDef);			roof.CreateFixture(roofFixture);			roof.SetUserData("roof");			roof.SetActive(true);			roof.SetActive(true);									var weldJointDef:b2WeldJointDef = new b2WeldJointDef();			weldJointDef.Initialize(car, roof, car.GetWorldCenter()); 			world.CreateJoint(weldJointDef);						//end roof												// ************************ THE AXLES ************************ //			// shape			var axleShape:b2PolygonShape = new b2PolygonShape();			axleShape.SetAsBox(20/worldScale,20/worldScale);			// fixture			var axleFixture:b2FixtureDef = new b2FixtureDef();			axleFixture.density=1;			axleFixture.friction=0;			axleFixture.restitution=0;			axleFixture.shape=axleShape;			axleFixture.filter.groupIndex=-1;			// body definition			var axleBodyDef:b2BodyDef = new b2BodyDef();			axleBodyDef.type=b2Body.b2_dynamicBody;						// the rear axle itself			axleBodyDef.position.Set(car.GetWorldCenter().x-(110/worldScale),car.GetWorldCenter().y+(0/worldScale));			rearAxle=world.CreateBody(axleBodyDef);			rearAxle.CreateFixture(axleFixture);			// the front axle itself			axleBodyDef.position.Set(car.GetWorldCenter().x+(110/worldScale),car.GetWorldCenter().y+(0/worldScale));			frontAxle=world.CreateBody(axleBodyDef);			frontAxle.CreateFixture(axleFixture);			// ************************ THE WHEELS ************************ //			// shape			var wheelShape:b2CircleShape=new b2CircleShape(frontwheelradius/worldScale);			var wheelShape2:b2CircleShape=new b2CircleShape(backwheelradius/worldScale);			// fixture			var wheelFixture:b2FixtureDef = new b2FixtureDef();			wheelFixture.density=0.2;			wheelFixture.friction=friction;			wheelFixture.restitution=globalRestitution;			wheelFixture.filter.groupIndex=-1;			wheelFixture.shape=wheelShape;			//bigwheeltest			var wheelFixture2:b2FixtureDef = new b2FixtureDef();			wheelFixture2.density=0.2;			wheelFixture2.friction=friction;			wheelFixture2.restitution=globalRestitution;			wheelFixture2.filter.groupIndex=-1;			wheelFixture2.shape=wheelShape2;			//end bigwheel test			// body definition			var wheelBodyDef:b2BodyDef = new b2BodyDef();			wheelBodyDef.type=b2Body.b2_dynamicBody;			wheelBodyDef.allowSleep = false;			//wheelBodyDef.angularDamping = 0.1;			// the rear wheel itself			wheelBodyDef.position.Set(rearAxle.GetWorldCenter().x,rearAxle.GetWorldCenter().y);			rearWheel=world.CreateBody(wheelBodyDef);			rearWheel.CreateFixture(wheelFixture2);			rearWheel.SetUserData("rearwheel");			// the front wheel itself			wheelBodyDef.position.Set(frontAxle.GetWorldCenter().x,frontAxle.GetWorldCenter().y);			frontWheel=world.CreateBody(wheelBodyDef);			frontWheel.CreateFixture(wheelFixture);			frontWheel.SetUserData("frontwheel");						frontWheel.SetActive(true);			rearWheel.SetActive(true);						// ************************ MOTOR JOINTS ************************ //			// rear joint			var rearMotorDef:b2RevoluteJointDef=new b2RevoluteJointDef();			rearMotorDef.Initialize(rearWheel,rearAxle,rearWheel.GetWorldCenter());			rearMotorDef.enableMotor=true;			rearMotorDef.maxMotorTorque=carWheelTorque;			rearMotorDef.collideConnected=false;			rearMotor=world.CreateJoint(rearMotorDef) as b2RevoluteJoint;			// front joint			var frontMotorDef:b2RevoluteJointDef=new b2RevoluteJointDef();			frontMotorDef.Initialize(frontWheel,frontAxle,frontWheel.GetWorldCenter());			frontMotorDef.enableMotor=true;			frontMotorDef.maxMotorTorque=carWheelTorque;			rearMotorDef.collideConnected=false;			frontMotor=world.CreateJoint(frontMotorDef) as b2RevoluteJoint;						// ************************ SPRINGS ************************ //			//  definition			var axlePrismaticJointDef:b2PrismaticJointDef=new b2PrismaticJointDef();			axlePrismaticJointDef.lowerTranslation=-carShockDamper/worldScale;			axlePrismaticJointDef.upperTranslation=50/worldScale;						//axlePrismaticJointDef.lowerTranslation=60;			//axlePrismaticJointDef.upperTranslation=20;						axlePrismaticJointDef.enableLimit=true;			axlePrismaticJointDef.enableMotor=true;			axlePrismaticJointDef.collideConnected=false;						// front spring			axlePrismaticJointDef.Initialize(car,frontAxle,frontAxle.GetWorldCenter(),new b2Vec2( -Math.cos(Math.PI/3), -Math.sin(Math.PI/3)));			frontSpring = world.CreateJoint(axlePrismaticJointDef) as b2PrismaticJoint;						// rear spring			axlePrismaticJointDef.Initialize(car,rearAxle,rearAxle.GetWorldCenter(),new b2Vec2( Math.cos(Math.PI/3), -Math.sin(Math.PI/3)));			rearSpring = world.CreateJoint(axlePrismaticJointDef) as b2PrismaticJoint;																	}			}}