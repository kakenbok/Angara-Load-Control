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
package com.sibirjak.angara.sequence.testhelpers {

	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.testhelpers.CoreTestHelper;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.sequence.ISequence;

	import org.as3commons.collections.framework.IIterator;


	/**
	 * @author jes 16.02.2009
	 */
	public class PagedSequenceTestHelper {
		
		public static function createAndFillSequence(numItems : uint) : ISequence {
			var sequence : ISequence = new PagedSequenceMock();
			fillSequence(sequence, numItems);
			return sequence;
		}

		public static function setSequenceProgress(sequence : ISequence, progress : Number) : void {
			PagedSequenceMock(sequence).setProgress(progress);
			PagedSequenceMock(sequence).dispatchProgressMock();
		}

		public static function setSequenceComplete(sequence : ISequence) : void {
			PagedSequenceMock(sequence).setProgress(1);
			PagedSequenceMock(sequence).setNumItemsLoaded(getNumResourceLoaders(sequence));

			PagedSequenceMock(sequence).setStatus(LoaderItemStatus.COMPLETE);

			PagedSequenceMock(sequence).dispatchCompleteMock();
		}

		public static function getResourceLoaderAt(sequence : ISequence, index : uint) : IResourceLoader {
			var iterator : IIterator = sequence.iterator();
			var i : uint = 0;
			while (iterator.hasNext()) {
				var item : IResourceLoader = iterator.next() as IResourceLoader;
				if (i == index) return item;
				i++;
			}
			return null;
		}

		public static function getNumResourceLoaders(sequence : ISequence) : uint {
			var iterator : IIterator = sequence.iterator();
			var numItems : uint = 0;
			while (iterator.hasNext()) {
				iterator.next();
				numItems++;
			}
			return numItems;
		}

		public static function fillSequence(sequence : ISequence, numItems : uint) : void {
			for (var i : int = 0; i <  numItems ; i++) {
				var loader : IResourceLoader = CoreTestHelper.createResourceLoader();
				sequence.add(loader);
			}
		}

		public static function setResourceLoaderFailedByIndex(sequence : ISequence, index : uint) : void {
			var loader : IResourceLoader = getResourceLoaderAt(sequence, index);
			CoreTestHelper.setResourceLoaderFailed(loader);
		}

		public static function setResourceLoaderCompletedByIndex(sequence : ISequence, index : uint) : void {
			var loader : IResourceLoader = getResourceLoaderAt(sequence, index);
			CoreTestHelper.setResourceLoaderCompleted(loader);
		}

	}
}
