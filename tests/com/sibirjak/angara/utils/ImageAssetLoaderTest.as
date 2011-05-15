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
package com.sibirjak.angara.utils {

	import com.sibirjak.angara.resource.ResourceLoaderEvent;
	import com.sibirjak.angara.resource.loaders.AbstractResourceLoaderTest;

	import flash.display.Bitmap;
	import flash.net.URLRequest;


	/**
	 * @author jes 29.04.2009
	 */
	public class ImageAssetLoaderTest extends AbstractResourceLoaderTest {

		override public function setUp() : void {
			super.setUp();
			
			_loader = new ImageAssetLoader(new URLRequest("image.png"));
		}

		override public function setUp404Loader() : void {
			_loader = new ImageAssetLoader(new URLRequest("image2.png"));
			_loader.maxLoadingTrials = 1;
		}

		override public function setUpLoaderWithoutLoadingPermission() : void {
			_loader = new ImageAssetLoader(new URLRequest("file:///image.png"));
			_loader.maxLoadingTrials = 1;
		}
		
		override public function getBytes() : uint {
			return 781;
		}

		/**
		 * test different not permitted resource
		 */

		public function testLoadingOfNotPermittedResource2() : void {
			_loader = new ImageAssetLoader(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/remoteImage.png"
			));
			_loader.maxLoadingTrials = 1;
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyLoadingOfWrongRealmFailed, 5000, 0));
			_loader.load();
		}

		/**
		 * test scripting access for the current realm
		 */

		public function testLoadedContentForCurrentRealm() : void {
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadedContentForCurrentRealm, 1000));
			_loader.load();
		}
		
		protected function verifyLoadedContentForCurrentRealm(event : ResourceLoaderEvent) : void {
			assertTrue ("content is bitmap", event.resourceLoader.content is Bitmap);
		}

	}
}
