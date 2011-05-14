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
