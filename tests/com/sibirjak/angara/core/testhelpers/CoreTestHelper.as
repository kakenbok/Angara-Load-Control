package com.sibirjak.angara.core.testhelpers {

	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.loaders.TestLoader;

	import org.as3commons.collections.framework.IOrderedList;


	/**
	 * @author jes 26.02.2009
	 */
	public class CoreTestHelper {

		/**
		 * resource loader related
		 */
		
		public static function createResourceLoader() : IResourceLoader {
			return new TestLoader(1);
		}

		public static function setResourceLoaderProgressByIndex(loaders : IOrderedList, index : uint, progress : Number) : void {
			var loader : IResourceLoader = loaders.itemAt(index) as IResourceLoader;
			setResourceLoaderProgress(loader, progress);
		}

		public static function setResourceLoaderProgress(loader : IResourceLoader, progress : Number) : void {
			TestLoader(loader).notifyProgressMock(progress);
		}

		public static function setResourceLoaderCompletedByIndex(loaders : IOrderedList, index : uint) : void {
			var loader : IResourceLoader = loaders.itemAt(index) as IResourceLoader;
			setResourceLoaderCompleted(loader);
		}

		public static function setResourceLoaderFailedByIndex(loaders : IOrderedList, index : uint) : void {
			var loader : IResourceLoader = loaders.itemAt(index) as IResourceLoader;
			setResourceLoaderFailed(loader);
		}

		public static function setResourceLoaderCompleted(loader : IResourceLoader) : void {
			TestLoader(loader).notifyCompleteMock();
		}

		public static function setResourceLoaderFailed(loader : IResourceLoader) : void {
			TestLoader(loader).notifyFailureMock();
		}

	}
}
