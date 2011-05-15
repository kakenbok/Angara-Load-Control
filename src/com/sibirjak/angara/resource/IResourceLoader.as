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

	import com.sibirjak.angara.core.ILoaderItem;

	/**
	 * Defines the interface of a resource loader item.
	 * 
	 * <p>A resource loader is basically an adapter to any of the built-in
	 * Flash loader types (Loader, URLLoader, Sound, ...). This interface
	 * lets those loaders interact with the LoaderManager.</p>
	 * 
	 * @author jes 10.02.2009
	 */
	public interface IResourceLoader extends ILoaderItem {
		
		/**
		 * Returns the URL of the resource loader.
		 * 
		 * @return URL of the resource loader.
		 */
		function get url() : String;

		/**
		 * Specifies the number of trials in cases of failures.
		 * 
		 * <p>Default value is 4 trials.</p>
		 * 
		 * @param trials The number of trials to load the resource.
		 */
		function set maxLoadingTrials(trials : uint) : void;
		
		/**
		 * Returns the max number of trails in case of failures.
		 * 
		 * @return The number of max connection trials.
		 */
		function get maxLoadingTrials() : uint;

		/**
		 * Returns the number of failed loading trails.
		 * 
		 * @return The number of failed loading trials.
		 */
		function get failedLoadingTrials() : uint;

		/**
		 * Specifies a timeout after that the resource loader will fail.
		 * 
		 * <p>If the resource loader does not show any raise in progress within this
		 * timeout, the loader will try to restart loading the resource as often as
		 * specified in connectionTrials. If the number of connectionTrials has been
		 * reached, the loader will be marked as failed and dispatch a 
		 * ResourceLoaderEvent.FAILURE.</p>
		 * 
		 * <p>Default value is 1000 ms = 1 second.</p>
		 * 
		 * @param trials The timeout within the progress should have been raised.
		 */
		function set timeout(timeout : uint) : void;
		
		/**
		 * Defines a callback function that will be executed right before the
		 * ResourceLoaderEvent.COMPLETE event.
		 * 
		 * @param callbackFunction The function to be called before the
		 * ResourceLoaderEvent.COMPLETE event.
		 * @see ICallback
		 */
		function set callbackFunction(callbackFunction : Function) : void;

		/**
		 * Lets you specify an arbitrary runtime property to be available within
		 * each resource loader event.
		 * 
		 * @param name The name of the property.
		 * @param value The value of the property.
		 */
		function setProperty(name : String, value : *) : void;

		/**
		 * Lets you pull a prior specified runtime property.
		 * 
		 * @param name The name of the property.
		 * @return The value of the property to get.
		 */
		function getProperty(name : String) : *;

		/**
		 * Starts loading of the resource.
		 * 
		 * <p>Won't have any effect if the status is any other than
		 * LoaderItemStatus.WAITING.</p>
		 */
		function load() : void;
		
		/**
		 * Returns the http status of a loaded resource.
		 * 
		 * <p>Initial value is -1.</p>
		 * 
		 * <p>Loading from a local realm will set the http status to 0.</p>
		 * 
		 * <p>Loading from a not permitted remote realm will set the http status to 0.</p>
		 * 
		 * @return The http status of the resource.
		 */
		function get httpStatus() : int;

		/**
		 * Returns the number of bytes already loaded.
		 * 
		 * @return Number of bytes loaded.
		 */
		function get bytesLoaded() : uint;

		/**
		 * Returns the number of bytes total.
		 * 
		 * <p>Note this is only available after a net connection has been established and
		 * the resource information has been received and the http response contains a
		 * file size property. In all other cases this method will return zero unit the
		 * resource is completely loaded from the server.
		 * 
		 * @return Number of bytes total.
		 */
		function get bytesTotal() : uint;

		/**
		 * Returns a reference to the loaded content.
		 * 
		 * <p>For streaming types the content will be available not before the
		 * INIT event has been dispatched. For static types the content won't be
		 * available until the resource has been loaded completely from the remote
		 * destination.
		 * 
		 * @return The loaded content.
		 */
		function get content() : *;

		/**
		 * Returns the loading error in a ResourceLoaderEvent.FAILURE event.
		 * 
		 * @return The loading error if any.
		 */
		function get loadingError() : LoadingError;

	}
}
