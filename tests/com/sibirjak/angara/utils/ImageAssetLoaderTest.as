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
