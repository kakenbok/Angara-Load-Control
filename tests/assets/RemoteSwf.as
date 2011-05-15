/*******************************************************************************
* The MIT License
* 
* Copyright (c) 2011 Jens Struwe.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
******************************************************************************/
package assets {

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.Security;

	/**
	 * @author jes 29.04.2009
	 */
	public class RemoteSwf extends Sprite {
		
		private var _rect : Sprite;
		private var _color : Number = 0xFF0000;

		public function RemoteSwf() {
			
			Security.allowDomain("*");
			
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
