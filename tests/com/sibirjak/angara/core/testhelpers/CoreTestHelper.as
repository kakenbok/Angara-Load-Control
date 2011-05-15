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
