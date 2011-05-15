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

	import com.sibirjak.angara.resource.IResourceLoader;

	import org.as3commons.collections.ArrayList;
	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IOrderedList;
	import org.as3commons.collections.framework.IOrderedSet;

	/**
	 * A paged sequence enables loading of only a range of containing loaders
	 * at a time.
	 * 
	 * <p>Since the Sequence removes all loaders from its internal list, we
	 * need to make up another loaders list here, which keeps references to
	 * the loaders after they have been finished. This list is index based for
	 * an easy spefication of the range of loaders to be loaded at next. The
	 * list will be removed automatically after all loader items have been
	 * finished.</p> 
	 * 
	 * <p>For performance reasons the PagedSequence stores all waiting loaders
	 * (status LoaderItemStatus.WAITING) in a separate list. The iterator of
	 * this list will be considered by the Schedules nextItems() method.</p>
	 * 
	 * @author jes 11.05.2009
	 */
	public class PagedSequence extends Sequence implements IPagedSequence {
		
		/**
		 * A reference to all added loaders.
		 */
		private var _allLoaders : IOrderedList;

		/**
		 * A reference to all currently waiting loaders.
		 */
		private var _waitingLoaders : IOrderedSet;

		/**
		 * Creates a new PagedSequence object.
		 */
		public function PagedSequence() {
			super();
			
			_allLoaders = new ArrayList();
			_waitingLoaders = new LinkedSet();
		}

		/*
		 * ISequence
		 */

		/**
		 * @inheritDoc
		 */
		override public function clear() : void {
			super.clear();
			
			_allLoaders.clear();
			_waitingLoaders.clear();
		}

		/*
		 * IPagedSequence
		 */

		/**
		 * @inheritDoc
		 */
		public function activateLoaders(index : uint, numItems : uint) : void {
			if (!_allLoaders) return;
			
			pauseAllActiveLoaders();
			
			var numNextItems : uint = 0;
			var resourceLoader : IResourceLoader;
			var iterator : IIterator = _allLoaders.iterator(index);
			while (iterator.hasNext() && numNextItems < numItems) {
				resourceLoader = iterator.next();
				resourceLoader.resume();
				numNextItems++;
			}
		}
		
		/*
		 * IIterator
		 */

		/**
		 * Returns an iterator over all not paused resource loaders.
		 * 
		 * @param cursor Not supported.
		 * @return Iterator over all not paused resource loaders.
		 */
		override public function iterator(cursor : * = undefined) : IIterator {
			return _waitingLoaders.iterator(cursor);
		}

		/**
		 * Returns in iterator over all scheduled resource loaders.
		 * 
		 * @param cursor Not supported.
		 * @return Iterator over all resource loaders added to the paged sequence.
		 */
		public function getResourceLoaderIterator(cursor : uint = 0) : IIterator {
			return super.iterator(cursor);
		}

		/*
		 * Protected
		 */
		
		/**
		 * @inheritDoc
		 */
		override protected function loaderPaused(resourceLoader : IResourceLoader) : void {
			_waitingLoaders.remove(resourceLoader);
		}

		/**
		 * @inheritDoc
		 */
		override protected function loaderResumed(resourceLoader : IResourceLoader) : void {
			_waitingLoaders.add(resourceLoader);
		}

		/**
		 * @inheritDoc
		 */
		override protected function loaderAdded(resourceLoader : IResourceLoader) : void {
			resourceLoader.pause();
			
			_allLoaders.add(resourceLoader);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function loaderRemoved(resourceLoader : IResourceLoader) : void {
			_waitingLoaders.remove(resourceLoader);
			_allLoaders.remove(resourceLoader);
		}

		/**
		 * @inheritDoc
		 */
		override protected function loaderFinished(resourceLoader : IResourceLoader) : void {
			_waitingLoaders.remove(resourceLoader);
			
			if (!_waitingLoaders.size) {
				dispatchEvent(new PagedSequenceEvent(PagedSequenceEvent.PAGE_COMPLETE, this));
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function sequenceComplete() : void {
			_allLoaders = null;
			_waitingLoaders = null;
		}

		/*
		 * Private
		 */

		/**
		 * Calls the pause method for all resource loaders contained by the internal
		 * waiting loaders list.
		 * 
		 * <p>The loaders will dispatch their pause event and be removed from the
		 * waiting loaders list in loaderPaused().</p>
		 */
		private function pauseAllActiveLoaders() : void {
			var resourceLoader : IResourceLoader;
			var iterator : IIterator = _waitingLoaders.iterator();
			while (iterator.hasNext()) {
				resourceLoader = iterator.next();
				resourceLoader.pause();
			}
		}
	}
}
