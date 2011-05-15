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

	/**
	 * @author jes 20.05.2009
	 */
	public class LoadingError {
		
		/**
		 * No raise in progress after the specified timeout period.
		 */
		public static var TIMEOUT : String = "timeout";

		/**
		 * Server returns a 404 error, or the file could not be found in the file system.
		 */
		public static var FILE_NOT_FOUND : String = "file_not_found";

		/**
		 * Loading of a resource from a not permitted realm.
		 * 
		 * <p>Possible reasons:</p>
		 * <ul>
		 * <li>Loading from the local realm is not permitted for a remote
		 * sandbox type.</li>
		 * <li>Loading from the network for the local-with-filesystem sandbox type.</li>
		 * <li>Different remote realm has to declare a policy file but did not.</li>
		 * </ul>
		 */
		public static var LOADING_DENIED : String = "loading_not_permitted";

		/**
		 * Accessing the loaded content not permitted.
		 * 
		 * <p>The Flash Loader may load a resource successfully but can't display it
		 * afterwards.</p>
		 * 
		 * <p>Possible reasons:</p>
		 * <ul>
		 * <li>Loaded SWF is in a different domain but did not define a appropriate
		 * Security.allowDomain rule.</li>
		 * <li>Loaded image is in a different domain, which has to declare a policy
		 * file but did not.</li>
		 * </ul>
		 */
		public static var ACCESS_DENIED : String = "content_access_not_permitted";
		
		/**
		 * The error type.
		 */
		private var _type : String; 

		/**
		 * The affected resource loader.
		 */
		private var _loader : IResourceLoader; 

		/**
		 * A detailed failure message.
		 */
		private var _failureMessage : String; 

		/**
		 * The Flash Error, if any is occurred.
		 */
		private var _error : Error; 
		
		/**
		 * Creates a new LoadingError object.
		 */
		public function LoadingError(type : String, loader : IResourceLoader, message : String = "", error : Error = null) {
			_type = type;
			_loader = loader;
			_failureMessage = message;
			_error = error;
		}
		
		/**
		 * Info
		 */
		public function toString() : String {
			return "[LoadingError] type:" + _type + " message:" + _failureMessage + " loader:" + _loader + " error:" + error;
		}
		
		/**
		 * Returns the type of the loading error.
		 * 
		 * @return The type of the loading error.
		 */
		public function get type() : String {
			return _type;
		}
		
		/**
		 * Returns the affected resource loader.
		 * 
		 * @return The affected resource loader.
		 */
		public function get loader() : IResourceLoader {
			return _loader;
		}
		
		/**
		 * Returns a more detailed error message in cases of loading failures.
		 * 
		 * @return The failure message.
		 */
		public function get failureMessage() : String {
			return _failureMessage;
		}
		
		/**
		 * Returns the Flash Error, if the loading failure is a result of a Flash exception.
		 * 
		 * <p>Exception may have been thrown for the types LOADING_DENIED and ACCESS_DENIED.</p>
		 * 
		 * @return The thrown Flash Error.
		 */
		public function get error() : Error {
			return _error;
		}
	}
}
