package com.sibirjak.angara.resource.loaders {
	import assets.RemoteSwf;
	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.LoadingError;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;



	/**
	 * @author jes 29.04.2009
	 */
	public class LoaderDelegateTest extends AbstractResourceLoaderTest {

		override public function setUp() : void {
			super.setUp();
			
			Security.loadPolicyFile(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteXMLPolicy.xml"
			);

			_loader = new LoaderDelegate(new URLRequest("image.png"));
		}

		override public function setUp404Loader() : void {
			_loader = new LoaderDelegate(new URLRequest("image2.png"));
			_loader.maxLoadingTrials = 1;
		}

		override public function setUpLoaderWithoutLoadingPermission() : void {
			_loader = new LoaderDelegate(new URLRequest("file:///image.png"));
			_loader.maxLoadingTrials = 1;
		}
		
		override public function getBytes() : uint {
			return 781;
		}

		/**
		 * test security violation when accessing content as data for wrong realm
		 */

		public function testLoadingWithoutContentAccessPermission() : void {
			_loader = new LoaderDelegate(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteSwfWithoutAllowedDomains.swf"
			));
			_loader.maxLoadingTrials = 1;
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyAccessingContentFailed, 1000));
			_loader.load();
		}
		
		protected function verifyAccessingContentFailed(event : ResourceLoaderEvent) : void {
			
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

			// the error will be thrown during the init phase where no status is
			// yet available. therefore the status will be -1 here.

			assertEquals(
				"Loader http status is -1",
				-1,
				loader.httpStatus
			);

			assertEquals(
				"Type of event is Loading ",
				LoadingError.ACCESS_DENIED,
				loader.loadingError.type
			);

		}

		/**
		 * test security violation during content access
		 */

		public function testLoadingWithoutContentAccessPermission2() : void {
			_loader = new LoaderDelegate(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/remoteImage.png"
			));
			_loader.maxLoadingTrials = 1;
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyAccessingContentFailed, 2000));
			_loader.load();
		}
		
		/**
		 * test scripting access for the current realm
		 */

		public function testLoadedContentForCurrentRealm() : void {
			_loader = new LoaderDelegate(new URLRequest(
				"remoteSWF.swf"
			));
			
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadedContentForCurrentRealm, 1000));
			_loader.load();
		}
		
		protected function verifyLoadedContentForCurrentRealm(event : ResourceLoaderEvent) : void {
			var testMovie : RemoteSwf = event.resourceLoader.content as RemoteSwf;
			testMovie.x = 10;
			testMovie.y = 40;

			var movie : RemoteSwf = event.resourceLoader.content as RemoteSwf;
			
			assertEquals(
				"color is red",
				0xFF0000,
				movie.color
			);

			movie.color = 0x0000FF;
			
			assertEquals(
				"color is blue",
				0x0000FF,
				movie.color
			);
		}

		/**
		 * test scripting access for a remote realm
		 */

		public function testLoadedContentForRemoteRealm() : void {
			_loader = new LoaderDelegate(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteSWF.swf"
			));
			
			var context : LoaderContext = new LoaderContext();
			context.securityDomain = SecurityDomain.currentDomain;
			context.applicationDomain = ApplicationDomain.currentDomain;
			LoaderDelegate(_loader).loaderContext = context;
			
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadedContentForRemoteRealm, 5000));
			_loader.load();
		}

		protected function verifyLoadedContentForRemoteRealm(event : ResourceLoaderEvent) : void {
			//var movie : RemoteSwf = event.resourceLoader.content as RemoteSwf;
			var movie : RemoteSwf = event.resourceLoader.content as RemoteSwf;
			
			assertEquals(
				"color is red",
				0xFF0000,
				movie.color
			);

			movie.color = 0x0000FF;
			
			assertEquals(
				"color is blue",
				0x0000FF,
				movie.color
			);
		}
		
		public function testLoadedContentForRemoteRealm2() : void {
			var loader : Loader = new Loader();
			
			var context : LoaderContext = new LoaderContext();
			context.securityDomain = SecurityDomain.currentDomain;
			context.applicationDomain = ApplicationDomain.currentDomain;

			loader.contentLoaderInfo.addEventListener(Event.INIT, addAsync(verifyLoadedContentForRemoteRealm2, 5000));
			loader.load(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteSWF.swf"
			), context);
		}

		protected function verifyLoadedContentForRemoteRealm2(event : Event) : void {
			//var movie : RemoteSwf = event.resourceLoader.content as RemoteSwf;
			var movie : RemoteSwf = LoaderInfo(event.target).content as RemoteSwf;
			
			assertEquals(
				"color is red",
				0xFF0000,
				movie.color
			);

			movie.color = 0x0000FF;
			
			assertEquals(
				"color is blue",
				0x0000FF,
				movie.color
			);
		}

	}
}
