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
package com.sibirjak.angara.resource {

	import com.sibirjak.angara.core.LoaderItemEvent;

	/**
	 * Resource loader event definition.
	 * 
	 * @author jes 17.02.2009
	 */
	public class ResourceLoaderEvent extends LoaderItemEvent {
		
		/**
		 * Progress of resource loader has changed.
		 */
		public static const PROGRESS : String = LoaderItemEvent.PROGRESS;

		/**
		 * Loaded content is ready to process (e.g. to display).
		 */
		public static const INIT : String = "resource_init";

		/**
		 * Loading finished successfully.
		 */
		public static const COMPLETE : String = LoaderItemEvent.COMPLETE;

		/**
		 * Loading failed.
		 */
		public static const FAILURE : String = LoaderItemEvent.FAILURE;

		/**
		 * Loader has stopped loading.
		 */
		public static const STOP : String = LoaderItemEvent.STOP;

		/**
		 * Loader paused.
		 */
		public static const PAUSE : String = LoaderItemEvent.PAUSE;

		/**
		 * Loader resumed.
		 */
		public static const RESUME : String = LoaderItemEvent.RESUME;

		/**
		 * Loader has started loading.
		 */
		public static const LOADING : String = "resource_loading";

		/**
		 * Loading failed.
		 */
		public static const TRIAL_FAILURE : String = "resource_loading_trail_failure";

		/**
		 * Creates a new LoaderItemEvent.
		 * 
		 * @param type Type of the event.
		 * @param resourceLoader Reference to the affected resource loader.
		 */
		public function ResourceLoaderEvent(type : String, resourceLoader : IResourceLoader) {
			super(type, resourceLoader);
		}

		/**
		 * Returns the affected resource loader.
		 * 
		 * @return The affected resource loader.
		 */
		public function get resourceLoader() : IResourceLoader {
			return _loaderItem as IResourceLoader;
		}
		
	}
}
