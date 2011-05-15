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
package com.sibirjak.angara.sequence {

	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.resource.IResourceLoader;

	import org.as3commons.collections.framework.IIterable;

	/**
	 * A sequence enables the controlling of a list of resource loaders.
	 * 
	 * <p>A sequence can be prioritised, added, removed, stopped, paused
	 * or resumed like ordinary loaders. A sequence is the best approach
	 * to load lists of display assets such as lists of thumbnails.</p>
	 * 
	 * <p>A sequence does not support the status LoaderItemStatus.FAILURE.
	 * A sequence instead will be marked as LoaderItemStatus.COMPLETE when all
	 * contained items are either COMPLETE or FAILURE.
	 * if (numItemsLoaded + numItemsFailed == numItems) => status = LoaderItemStatus.COMPLETE.</p>
	 * 
	 * @author jes 10.02.2009
	 */
	public interface ISequence extends ILoaderItem, IIterable {

		/**
		 * Adds a new resource loader to the sequence.
		 * 
		 * <p>Its possible to add resource at any time of loading to a sequence but
		 * not after the sequence has been marked as complete.</p>
		 * 
		 * @param resourceLoader The resource loader to add.
		 */
		function add(resourceLoader : IResourceLoader, weight : uint = 0) : void;

		/**
		 * Removes a loader from a sequence.
		 * 
		 * <p>This will decrease the number of items by 1 and adjust the sequence's
		 * progress value.</p>
		 *  
		 * @param resourceLoader The resource loader to remove.
		 */
		function remove(resourceLoader : IResourceLoader) : void;

		/**
		 * Stops all loaders and removes all loader references from the sequence.
		 */
		function clear() : void;
		
	}
}
