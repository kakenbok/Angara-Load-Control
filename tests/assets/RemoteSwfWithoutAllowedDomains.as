package assets {
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author jes 29.04.2009
	 */
	public class RemoteSwfWithoutAllowedDomains extends Sprite {
		
		private var _rect : Sprite;
		private var _color : Number = 0xFF0000;

		public function RemoteSwfWithoutAllowedDomains() {
			
			_rect = new Sprite();
			addChild(_rect);
			
			draw();
			
			addEventListener(MouseEvent.MOUSE_DOWN, click);
		}
		
		private function click(event : MouseEvent) : void {
			color = 0x0000FF;
		}
		
		private function draw() : void {
			with (_rect) {
				graphics.clear();
				graphics.beginFill(_color);
				graphics.drawRect(0, 0, 100, 100);
			}
		}
		
		public function get color() : Number {
			return _color;
		}
		
		public function set color(color : Number) : void {
			_color = color;
			draw();
		}
	}
}
