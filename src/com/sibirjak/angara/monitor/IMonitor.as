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
package com.sibirjak.angara.monitor {

	import com.sibirjak.angara.core.ILoaderItem;
	import com.sibirjak.angara.core.IProgressInfo;

	/**
	 * A monitor encapsulates the progress calculation of a sequence of
	 * loader items.
	 * 
	 * <p>A monitor returns the overall progress of its containing loader
	 * items.</p>
	 * 
	 * <p>It is possible to add loader items cross over their assignment to
	 * the loader manager, to a sequence or a sequence manager.</p>
	 * 
	 * <p>The monitor listens to progress and complete events of its loader
	 * items and updates its internal progress information simultaneously.</p>
	 * 
	 * @author jes 13.02.2009
	 */
	public interface IMonitor extends IProgressInfo {

		/**
		 * Adds a loader item to a progress monitor.
		 * 
		 * <p>You can add any loader item type (resource loader, sequence,
		 * sequence manager).</p>
		 * 
		 * <p>If no weight parameter is given, the monitor uses the items.numItems
		 * property for the weight. Adding one resource loader and a sequence of
		 * 3 items would this way result in a cumulative weight of 4.
		 * Finishing the sequence would change the monitor's progress to .75 then.</p>
		 * 
		 * @param loaderItem The loader item to be monitored.
		 * @param weight The weight of the item within all monitor item's 
		 */
		function add(loaderItem : ILoaderItem, weight : uint = 0) : void;

		/**
		 * Removes a loader item from the progress monitor.
		 * 
		 * @param loaderItem The loader to be removed.
		 */
		function remove(loaderItem : ILoaderItem) : void;

		/**
		 * Removes all loader item references from the progress monitor.
		 */
		function clear() : void;

	}
}
