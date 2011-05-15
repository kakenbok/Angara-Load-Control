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
package com.sibirjak.angara.resource.loaders {

	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;

	import flash.display.Sprite;


	/**
	 * @author jes 29.04.2009
	 */
	public class TestLoaderTest extends AbstractResourceLoaderTest {

		override public function setUp() : void {
			super.setUp();
			
			_loader = new TestLoader(1);
		}

		override public function setUp404Loader() : void {
			_loader = new TestLoader(1);
			TestLoader(_loader).loaderType = TestLoader.TYPE_404;
			_loader.maxLoadingTrials = 1;
		}

		override public function setUpLoaderWithoutLoadingPermission() : void {
			_loader = new TestLoader(1);
			TestLoader(_loader).loaderType = TestLoader.TYPE_LOADING_PROHIBITED;
			_loader.maxLoadingTrials = 1;
		}

		override public function getBytes() : uint {
			return 100;
		}

		/**
		 * test content
		 */

		public function testLoadedContent() : void {
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadedContent, 5000));
			_loader.load();
		}

		protected function verifyLoadedContent(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			assertTrue(
				"content is a sprite",
				loader.content is Sprite
			);	
		}

	}
}
