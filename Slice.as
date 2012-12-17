package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	
	public class Slice extends MovieClip {
		
		
		public function Slice() {
			
        }


		public function setNumber(i,y1,y2) {
			       
            var child:Shape = new Shape();
            child.graphics.beginFill(0x33CC33);
            child.graphics.lineStyle(0, 0xAAAAAA);
            
			child.graphics.lineTo(0,-y1);
			child.graphics.lineTo(60,-y2);
			child.graphics.lineTo(60,0);
			child.graphics.lineTo(0,0);
			
            child.graphics.endFill();
            addChild(child);
		
		}
		
	}
	
}
