﻿package  {	import flash.display.MovieClip;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.KeyboardEvent;	import flash.net.SharedObject;		public class Shop extends MovieClip {		private var myLoader:GameLoader		public var products:Object		public var cookie:SharedObject		public var coins:int=1000		public function Shop(inLoader:GameLoader) {			trace(this,this.name,Math.random())			myLoader = inLoader			x = 0			y = 0			continuebutton.addEventListener(MouseEvent.CLICK,onContinue)			clearCookieButton.addEventListener(MouseEvent.CLICK,onClearCookie)			createProducts()			showProducts()			loadCoins()		}		public function show() {			visible = true			this.updateCoinsField()		}		private function onContinue(e:Event) {			visible = false			myLoader.reset();		}				public function createProducts() {												products = new Object()			var upgradesBought:int = 0			var upgradesCost:Array			var upgradesValue:Array						//load flash cookie			cookie = SharedObject.getLocal("GameState")						if (cookie.data.coins) {				coins = cookie.data.coins				trace("found old cookie")			}			else coins = 0												//create some products with upgrades			upgradesCost = new Array(50,100,200,500,750,1000)			upgradesValue = new Array(30,35,40,50,65,80)			if (cookie.data.products) upgradesBought = cookie.data.products.wheel.upgradesBought			products.wheel = new ShopProduct("wheel",new ThumbWheel(),upgradesCost,upgradesValue,upgradesBought)			upgradesCost = new Array(10,100,250,500,1000,2000)			upgradesValue = new Array(100,200,350,500,700,1000)			if (cookie.data.products) upgradesBought = cookie.data.products.fuel.upgradesBought			products.fuel = new ShopProduct("fuel",new FuelTank(),upgradesCost,upgradesValue,upgradesBought)			upgradesCost = new Array(20,40,60,80,120,250)			upgradesValue = new Array(0.92,0.93,0.95,0.97,0.98,0.99)			if (cookie.data.products) upgradesBought = cookie.data.products.engine.upgradesBought			products.engine = new ShopProduct("engine",new ThumbEngine(),upgradesCost,upgradesValue,upgradesBought)						upgradesCost = new Array(20,40,60,80,120,250)			upgradesValue = new Array(0.02,0.03,0.05,0.07,0.08,0.10)			if (cookie.data.products) upgradesBought = cookie.data.products.luck.upgradesBought			products.luck = new ShopProduct("luck",new ThumbDice(),upgradesCost,upgradesValue,upgradesBought)															}				private function showProducts() {									var padding:Number = 15;						var posy = 125						for each (var product:ShopProduct in products) {								var posx = 150								//backdrop strip				var strip = addChild(new ProductBackdrop())				strip.y = posy				//strip.x = posx - 20								//thumb				var thumb = addChild(product.thumb)				thumb.x = posx				thumb.y = posy								posx = posx + 60 // width of thumb				product.upgradeIcons = new Array()				for (var i=0;i<product.upgradesCost.length;i++) {										//progress icons					var upgradeIcon					if (i<=product.upgradesBought) upgradeIcon = new UpgradeIconBought()					else upgradeIcon = new UpgradeIconNotBought()					//var hor = i*(upgradeIcon.width + padding) + 180					posx = posx + upgradeIcon.width + padding					upgradeIcon.x = posx					upgradeIcon.y = posy					addChild(upgradeIcon)					product.upgradeIcons.push(upgradeIcon)									}								var costLabel								if (product.upgradesBought < product.upgradesCost.length - 1) {										//cost of next upgrade					costLabel = new ProductCostLabel()					costLabel.textfield.text = "$ " + product.upgradesCost[product.upgradesBought]					addChild(costLabel)					posx = posx + padding + upgradeIcon.width					costLabel.x = posx					costLabel.y = posy										//buy button					var buyButton:BuyButton = new BuyButton()					buyButton.targetProduct = product					buyButton.targetCostLabel = costLabel					buyButton.addEventListener(MouseEvent.CLICK,onBuy)					addChild(buyButton)					posx = posx + padding + costLabel.width					buyButton.setPos(posx,posy)				}								else {					//maxed out, nothing to buy					costLabel = new ProductCostLabel()					costLabel.textfield.text = "max"					addChild(costLabel)					posx = posx + padding + upgradeIcon.width					costLabel.x = posx					costLabel.y = posy									}																posy = posy + 70							}							}				private function updateCoinsField() {			if (coins) {				this.coinstextfield.text = "$" + coins			}		}				private function onBuy(e:MouseEvent) {						var callingBuyButton:BuyButton = e.currentTarget as BuyButton			var curProduct:ShopProduct = callingBuyButton.targetProduct			//check wallet			if (coins < curProduct.upgradesCost[curProduct.upgradesBought]) {				return			}			else {				var deduct = curProduct.upgradesCost[curProduct.upgradesBought]				this.subtractCoins(deduct) 			}															//update affected game setting (move the needle)						if (curProduct.upgradesBought < curProduct.upgradesCost.length) {				curProduct.upgradesBought++				//final upgrade, maxed out				if (curProduct.upgradesBought == curProduct.upgradesCost.length - 1) {					callingBuyButton.visible = false					callingBuyButton.targetCostLabel.textfield.text = "max"				}				//still upgrades to buy				else {					callingBuyButton.targetCostLabel.textfield.text = "$ " + curProduct.upgradesCost[curProduct.upgradesBought]				}								//from red to green icon				var notBoughtIcon = curProduct.upgradeIcons[curProduct.upgradesBought]				var boughtIcon = new UpgradeIconBought()				addChild(boughtIcon)				boughtIcon.x = notBoughtIcon.x				boughtIcon.y = notBoughtIcon.y			}												//save to cookie			var cookie = SharedObject.getLocal("GameState")			cookie.data.products = products			cookie.flush					}				public function addCoins(incoins) {			coins = coins + incoins			cookie.data.coins = coins			cookie.flush()			this.updateCoinsField()		}				public function subtractCoins(incoins) {			coins = coins - incoins			cookie.data.coins = coins			cookie.flush()			this.updateCoinsField()		}				private function loadCoins() {			if (cookie.data) coins = cookie.data.coins			this.updateCoinsField()		}				private function onClearCookie(e:Event) {			cookie.clear()			trace("cookie cleared")		}	}	}