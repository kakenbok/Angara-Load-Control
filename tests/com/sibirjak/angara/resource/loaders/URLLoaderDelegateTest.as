package com.sibirjak.angara.resource.loaders {

	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;
	import com.sibirjak.angara.utils.ImageAssetLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;


	/**
	 * @author jes 29.04.2009
	 */
	public class URLLoaderDelegateTest extends AbstractResourceLoaderTest {

		override public function setUp() : void {
			super.setUp();
			
			Security.loadPolicyFile(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteXMLPolicy.xml"
			);
			
			_loader = new URLLoaderDelegate(new URLRequest("xml.xml"));
		}

		override public function setUp404Loader() : void {
			_loader = new URLLoaderDelegate(new URLRequest("xml2.xml"));
			_loader.maxLoadingTrials = 1;
		}

		override public function setUpLoaderWithoutLoadingPermission() : void {
			_loader = new URLLoaderDelegate(new URLRequest("file:///xml.xml"));
			_loader.maxLoadingTrials = 1;
		}

		override public function getBytes() : uint {
			return 97;
		}

		public function getDataToSend() : URLVariables {
			var data : URLVariables = new URLVariables();
			data["value1"] = "value1";
			data["value2"] = "value2";
			return data;
		}

		/**
		 * test different not permitted resource
		 */

		public function testLoadingOfNotPermittedResource2() : void {
			_loader = new ImageAssetLoader(new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/remoteXML.xml"
			));
			_loader.maxLoadingTrials = 1;
			
			_loader.addEventListener(ResourceLoaderEvent.FAILURE, addAsync(verifyLoadingOfWrongRealmFailed, 5000, 0));
			_loader.load();
		}

		/**
		 * test content
		 */

		public function testLoadedContent() : void {
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyLoadedContent, 1000));
			_loader.load();
		}

		protected function verifyLoadedContent(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			var xml : XML = new XML(loader.content);
			var data : XML = xml.children()[1];
			
			assertEquals(
				"data is NodeValue2",
				"NodeValue2",
				data.toString()
			);	
		}

		/**
		 * test sending data
		 */

		public function testSendDataViaGET() : void {
			var request : URLRequest = new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteXML.php"
			);
			request.data = getDataToSend();
			
			_loader = new URLLoaderDelegate(request);
			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyDataSentViaGET, 5000));
			_loader.load();
		}
		
		protected function verifyDataSentViaGET(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			var xml : XML = new XML(loader.content);
			
			var data : XML = xml.children()[0];

			assertEquals(
				"data is value1",
				"value1",
				data.toString()
			);	

			data = xml.children()[1];
			assertEquals(
				"data is value2",
				"value2",
				data.toString()
			);	

			data = xml.children()[2];
			assertEquals(
				"data is ''",
				"",
				data.toString()
			);	

			data = xml.children()[3];
			assertEquals(
				"data is ''",
				"",
				data.toString()
			);	

		}

		public function testSendDataViaGETAndPOST() : void {
			var request : URLRequest = new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteXML.php?value1=value1&value2=value2"
			);
			request.method = URLRequestMethod.POST;
			request.data = getDataToSend();
			
			_loader = new URLLoaderDelegate(request);

			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyDataSentViaGETAndPOST, 5000));
			_loader.load();
		}
		
		protected function verifyDataSentViaGETAndPOST(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			var xml : XML = new XML(loader.content);
			
			var data : XML = xml.children()[0];
			assertEquals(
				"data is value1",
				"value1",
				data.toString()
			);	

			data = xml.children()[1];
			assertEquals(
				"data is value2",
				"value2",
				data.toString()
			);	

			data = xml.children()[2];
			assertEquals(
				"data is value1",
				"value1",
				data.toString()
			);	

			data = xml.children()[3];
			assertEquals(
				"data is value2",
				"value2",
				data.toString()
			);	

		}

		public function testSendDataViaPOST() : void {
			var request : URLRequest = new URLRequest(
				"http://sibirjak.com/projects/loadermanager/testassets/granted/remoteXML.php"
			);
			request.method = URLRequestMethod.POST;
			request.data = getDataToSend();
			
			_loader = new URLLoaderDelegate(request);

			_loader.addEventListener(ResourceLoaderEvent.COMPLETE, addAsync(verifyDataSentViaPOST, 5000));
			_loader.load();
		}
		
		protected function verifyDataSentViaPOST(event : ResourceLoaderEvent) : void {
			var loader : IResourceLoader = event.resourceLoader;
			
			var xml : XML = new XML(loader.content);
			
			var data : XML = xml.children()[0];
			assertEquals(
				"data is ''",
				"",
				data.toString()
			);	

			data = xml.children()[1];
			assertEquals(
				"data is ''",
				"",
				data.toString()
			);	

			data = xml.children()[2];
			assertEquals(
				"data is value1",
				"value1",
				data.toString()
			);	

			data = xml.children()[3];
			assertEquals(
				"data is value2",
				"value2",
				data.toString()
			);	

		}

	}
}
