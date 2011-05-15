package com.sibirjak.angara.resource.loaders {

	import flexunit.framework.TestCase;

	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.LoadingError;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;

	import flash.system.Security;



	/**
	 * @author jes 29.04.2009
	 */
	public class AbstractResourceLoaderTest extends TestCase {

		protected var _loader : IResourceLoader;

		/**
		 * test neutralization
		 */

		override public function setUp() : void {
			//_loader = new ImageLoader("accept.png");
		}

		public function setUp404Loader() : void {
			//_loader = new ImageLoader("accept2.png");
		}

		public function setUpLoaderWithoutLoadingPermission() : void {
			//_loader = new ImageLoader("file:///accept.png");
		}

		public function getBytes() : uint {
			return 0;
		}

		override public function tearDown() : void {
			_loader = null;
		}

		/**
		 * test initial state
		 */

		public function testInstantiated() : void {
			assertTrue("Schedule instantiated", _loader is IResourceLoader);
		}

		public function testSandboxType() : void {
			assertEquals(
				("You need to switch to the remote sandbox to test this class. "
				+ "You can do this by running this Test over a local web server"
				+ "rather than in the IDE flash viewer."),
				Security.REMOTE,
				Security.sandboxType
			);
		}

		public function testInitialStatus() : void {
			assertEquals(
				"Loader status now WAITING",
				LoaderItemStatus.WAITING,
				_loader.status
			);
		}

		/**
		 * test successful loading
		 */

		public function testSuccessfulLoading() : void {
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadingSuccessful, 1000));
			_loader.load();
		}
		
		protected function verifyLoadingSuccessful(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			assertStrictlyEquals(
				"Dispatched event belongs to our loader",
				_loader,
				loader
			);
			
			assertEquals(
				"Loader status now COMPLETE",
				LoaderItemStatus.COMPLETE, loader.status
			);
			
			assertNotUndefined(
				"Loader content is not undefined",
				loader.content
			);
			
		}

		/**
		 * test loading of nonexisting item
		 */

		public function testLoadingOfNonexistingResource() : void {
			setUp404Loader();
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyLoadingOfNonexistingResourceFailed, 5000));
			_loader.load();
		}
		
		protected function verifyLoadingOfNonexistingResourceFailed(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader =  event.resourceLoader;
			
			assertStrictlyEquals(
				"Dispatched event belongs to our loader",
				_loader,
				loader
			);
			
			assertEquals(
				"Loader status now FAILURE",
				LoaderItemStatus.FAILURE,
				loader.status
			);
			
			assertUndefined(
				"Loader content is undefined",
				loader.content
			);
			
			assertTrue("Loader http status 404", loader.httpStatus == 404 || loader.httpStatus == 0);

			assertEquals(
				"Type of event is File not found",
				LoadingError.FILE_NOT_FOUND,
				loader.loadingError.type
			);

		}

		/**
		 * test security violation when loading from local realm
		 */

		public function testLoadingOfNotPermittedResource() : void {
			setUpLoaderWithoutLoadingPermission();
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyLoadingOfWrongRealmFailed, 5000));
			_loader.load();
		}

		protected function verifyLoadingOfWrongRealmFailed(event : ResourceLoaderEvent, httpStatus : int = -1) : void {
			var loader : IResourceLoader =  event.resourceLoader;
			
			assertStrictlyEquals(
				"Dispatched event belongs to our loader",
				_loader,
				loader
			);
			
			assertEquals(
				"Loader status now FAILURE",
				LoaderItemStatus.FAILURE,
				loader.status
			);
			
			assertUndefined(
				"Loader content is undefined",
				loader.content
			);

			assertEquals(
				"Loader http status is " + httpStatus,
				httpStatus,
				loader.httpStatus
			);

			assertEquals(
				"Type of event is Loading denied",
				LoadingError.LOADING_DENIED,
				loader.loadingError.type
			);

		}

		/**
		 * test stopped loading
		 */

		public function testStoppedLoading() : void {
			_loader.addEventListener(ResourceLoaderEvent.PROGRESS, addAsync(verifyLoadingProgress, 1000));
			_loader.load();
		}
		
		protected function verifyLoadingProgress(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader =  event.resourceLoader;

			assertStrictlyEquals(
				"Dispatched event belongs to our loader",
				_loader,
				loader
			);
			
			assertEquals(
				"Loader status now LOADING",
				LoaderItemStatus.LOADING,
				loader.status
			);

			assertTrue(
				"Loader's progress > 0 " + loader.progress,
				0 < loader.progress
			);
			
			// stop
			
			loader.stop();

			assertStrictlyEquals(
				"Dispatched event belongs to our loader",
				_loader,
				loader
			);
			
			assertEquals(
				"Loader status now WAITING",
				LoaderItemStatus.WAITING,
				loader.status
			);
			
			assertEquals(
				"Loader's progress set back to zero",
				0,
				loader.progress
			);

			assertUndefined(
				"Loader content is undefined",
				loader.content
			);
		}

		/**
		 * test bytes loaded/total
		 */

		public function testBytesLoaded() : void {
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyBytesLoaded, 5000));
			_loader.load();
		}
		
		protected function verifyBytesLoaded(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			assertEquals(
				"Bytes total right.",
				getBytes(),
				loader.bytesTotal
			);	

			assertEquals(
				"Bytes loaded right.",
				getBytes(),
				loader.bytesLoaded
			);	
		}

	}
}
