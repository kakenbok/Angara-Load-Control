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
	 * The callback interface provides methods to control a resource loader
	 * callback behaviour.
	 * 
	 * <p>It is possible to assign a callback function to any resource loader. If
	 * a callback has been specified, the callback will be executed before the
	 * resource loader COMPLETE event is dispatched. It is possible to mark a
	 * callback as asynchronous, which will stop the loader manager queue until
	 * the notifyComplete() method of that callback has been triggered.</p>
	 * 
	 * <p>Per default a callback method will be called synchronously. The loader
	 * manager continues working right after the callback handler has been triggered.</p>
	 * 
	 * @author jes 04.05.2009
	 */
	public interface ICallback {
		
		/**
		 * Returns a reference to the loader that defines the callback.
		 * 
		 * @return The resource loader defining the callback.
		 */
		function get loader() : IResourceLoader;

		/**
		 * Sets a callback to be asynchronous.
		 * 
		 * <p>The loader manager will wait for the callback completion to continue
		 * its work. You need to call callback.notifyComplete() to notify the loader
		 * manager to continue.</p>
		 */
		function setAsync() : void;

		/**
		 * Notifies the loader manager about a completed asynchronous callback.
		 * 
		 * <p>The loader manager will continue loading not until this method has
		 * been called.</p>
		 */
		function notifyComplete() : void;
		
	}
}
