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
package com.sibirjak.angara.monitor.testhelpers {

	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.monitor.IMonitor;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.sequence.ISequence;
	import com.sibirjak.angara.sequence.testhelpers.SequenceTestHelper;

	import org.as3commons.collections.ArrayList;
	import org.as3commons.collections.framework.IOrderedList;


	/**
	 * @author jes 16.02.2009
	 */
	public class MonitorTestHelper {

		/**
		 * loader related
		 */
		
		public static function createAndAddResourceLoaders(monitor : IMonitor, numItems : uint) : IOrderedList {
			var list : IOrderedList = new ArrayList();
			for (var i : int = 0; i < numItems; i++) {
				var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
				list.add(loader);
				monitor.add(loader);
			}
			return list;
		}

		public static function createAndAddResourceLoader(monitor : IMonitor, weight : uint = 0) : IResourceLoader {
			var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
			monitor.add(loader, weight);
			return loader;
		}

		public static function createFillAndAddSequence(monitor : IMonitor, numItems : uint, weight : uint = 0) : ISequence {
			var sequence : ISequence = SequenceTestHelper.createAndFillSequence(numItems);
			monitor.add(sequence, weight);
			return sequence;
		}

	}
}
