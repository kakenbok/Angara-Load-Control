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

	import com.sibirjak.angara.core.AbstractLoaderItem;
	import com.sibirjak.angara.core.LoaderItemStatus;
	import com.sibirjak.angara.core.LoaderItemType;
	import com.sibirjak.angara.core.sibirjak_loader;
	import com.sibirjak.angara.monitor.IMonitor;
	import com.sibirjak.angara.monitor.Monitor;
	import com.sibirjak.angara.monitor.MonitorEvent;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;

	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IOrderedSet;

	/**
	 * A sequence is a list of resource loaders.
	 * 
	 * <p>Finished loaders will be removed from the internal loader list and
	 * therefore won't be considered in enumeration using the sequence's iterator.
	 * However they will be still counted in the numItems property.</p>
	 * 
	 * @author jes 10.02.2009
	 */
	public class Sequence extends AbstractLoaderItem implements ISequence {
		
		/**
		 * Internal list to store all loaders.
		 */
		private var _loaders : IOrderedSet;

		/**
		 * Internal list to store all currnently loading loaders.
		 * 
		 * <p>Necessary to offer the sequence.stop() functionality.</p>
		 */
		private var _loadingLoaders : IOrderedSet;
		
		/**
		 * Internal progress monitor.
		 */
		private var _monitor : IMonitor;
		
		/**
		 * Creates a new sequence.
		 */
		public function Sequence() {
			_loaders = new LinkedSet();
			_loadingLoaders = new LinkedSet();
			
			/*
			 * We pull the resource complete event from the monitor and not from
			 * the loader itself since we need to guarantee that the sequence
			 * complete event is dispatched after the last resource complete.
			 */
			
			_monitor = new Monitor();
			_monitor.addEventListener(MonitorEvent.PROGRESS, monitorProgressHandler);
			_monitor.addEventListener(MonitorEvent.COMPLETE, monitorCompleteHandler);
			
			_type = LoaderItemType.SEQUENCE;
			_status = LoaderItemStatus.WAITING;
		}

		/*
		 * ISequence
		 */
		
		/**
		 * @inheritDoc
		 */
		public function add(resourceLoader : IResourceLoader, weight : uint = 0) : void {
			// cannot add loaders to a finished sequence
			if (_status == LoaderItemStatus.COMPLETE) return;
			
			// cannot add loaders elsewhere scheduled
			// adding the same loader twice is therefore not permitted
			if (resourceLoader.scheduled) return;

			_monitor.add(resourceLoader, weight);
			
			_loaders.add(resourceLoader);
			configureListeners(resourceLoader);

			AbstractLoaderItem(resourceLoader).sibirjak_loader::setScheduled(true);

			loaderAdded(resourceLoader);

			dispatchAdd(resourceLoader);
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(resourceLoader : IResourceLoader) : void {
			// cannot remove loaders that not exist
			if (!_loaders.has(resourceLoader)) return;

			// cannot remove loaders from a finished sequence
			if (_status == LoaderItemStatus.COMPLETE) return;

			_monitor.remove(resourceLoader);

			removeLoaderFromSchedule(resourceLoader);

			AbstractLoaderItem(resourceLoader).sibirjak_loader::setScheduled(false);
			
			// finally stop loading, remove loader from ConnectionPool
			resourceLoader.stop();

			loaderRemoved(resourceLoader);

			dispatchRemove(resourceLoader);
		}

		/**
		 * @inheritDoc
		 */
		public function clear() : void {
			stop();
			
			_monitor.clear();

			var iterator : IIterator = _loaders.iterator();
			while (iterator.hasNext()) {
				deconfigureListeners(iterator.next());
			}
			_loaders.clear();

			_numItems = 0;
			_numItemsLoaded = 0;
			_numItemsFailed = 0;
			_progress = 0;
		}

		/**
		 * @inheritDoc
		 */
		override public function stop() : void {
			var iterator : IIterator = _loadingLoaders.iterator();
			var loader : IResourceLoader;
			while (iterator.hasNext()) {
				loader = iterator.next();
				loader.removeEventListener(ResourceLoaderEvent.STOP, resourceStopHandler);
				loader.stop();
			}
			_loadingLoaders.clear();

			dispatchStop();
		}

		/**
		 * @inheritDoc
		 */
		override public function pause() : void {
			// can only pause a waiting sequence
			if (_status != LoaderItemStatus.WAITING) return;
			_status = LoaderItemStatus.PAUSED;
			dispatchPause();
		}

		/**
		 * @inheritDoc
		 */
		override public function resume() : void {
			// can only resume a paused sequence
			if (_status != LoaderItemStatus.PAUSED) return;
			_status = LoaderItemStatus.WAITING;
			dispatchResume();
		}

		/*
		 * IIterable
		 */

		/**
		 * Returns an iterator over all resource loaders left.
		 * 
		 * @param cursor Not supported.
		 * @return Iterator over all left resource loaders.
		 */
		public function iterator(cursor : * = undefined) : IIterator {
			return _loaders.iterator(cursor);
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[Sequence] key:" + key + " status:" + _status + " items:" + _numItems + " loaded:" + _numItemsLoaded + " failed:" + _numItemsFailed + " progress:" + _progress;
		}
		
		/**
		 * Template method to notify subclasses after a resource loader has been added
		 * but before the sequence dispatches the ADD event.
		 */
		protected function loaderAdded(resourceLoader : IResourceLoader) : void {
			// hook
		}
		
		/**
		 * Template method to notify subclasses after a resource loader has been removed.
		 */
		protected function loaderRemoved(resourceLoader : IResourceLoader) : void {
			// hook
		}

		/**
		 * Template method to notify subclasses after the internal monitor has been completed
		 * but before the sequence dispatches its COMPLETE event.
		 */
		protected function sequenceComplete() : void {
			// hook
		}

		/**
		 * Template method to notify subclasses after a resource has been paused.
		 */
		protected function loaderPaused(resourceLoader : IResourceLoader) : void {
			// hook
		}

		/**
		 * Template method to notify subclasses after a resource has been resumed
		 * but before the sequence dispatches its RESUME event.
		 */
		protected function loaderResumed(resourceLoader : IResourceLoader) : void {
			// hook
		}

		/**
		 * Template method to notify subclasses after a resource has been finished.
		 */
		protected function loaderFinished(resourceLoader : IResourceLoader) : void {
			// hook
		}

		/*
		 * Monitor listeners
		 */

		/**
		 * Handler for the monitor complete event.
		 */
		private function monitorCompleteHandler(event : MonitorEvent) : void {
			_monitor.removeEventListener(MonitorEvent.PROGRESS, monitorProgressHandler);
			_monitor.removeEventListener(MonitorEvent.COMPLETE, monitorCompleteHandler);
			
			_monitor.clear();
			
			_status = LoaderItemStatus.COMPLETE;
			sequenceComplete();
			
			dispatchComplete();
		}
		
		/**
		 * Handler for the monitor progress event.
		 */
		private function monitorProgressHandler(event : MonitorEvent) : void {

			_numItems = _monitor.numItems;
			_numItemsLoaded = _monitor.numItemsLoaded;
			_numItemsFailed = _monitor.numItemsFailed;
			_progress = _monitor.progress;

			dispatchProgress();
		}

		/*
		 * Resource loader listeners
		 */

		/**
		 * Starts listening to resource loader notifications.
		 */
		private function configureListeners(loader : IResourceLoader) : void {
			loader.addEventListener(ResourceLoaderEvent.LOADING, resourceLoadingHandler);

			loader.addEventListener(ResourceLoaderEvent.RESUME, resourceResumeHandler);
			loader.addEventListener(ResourceLoaderEvent.PAUSE, resourcePauseHandler);
			loader.addEventListener(ResourceLoaderEvent.FAILURE, resourceFinishedHandler, false, 2);
			loader.addEventListener(ResourceLoaderEvent.COMPLETE, resourceFinishedHandler, false, 2);
		}
		
		/**
		 * Stops listening to resource loader notifications.
		 */
		private function deconfigureListeners(loader : IResourceLoader) : void {
			loader.removeEventListener(ResourceLoaderEvent.LOADING, resourceLoadingHandler);

			loader.removeEventListener(ResourceLoaderEvent.RESUME, resourceResumeHandler);
			loader.removeEventListener(ResourceLoaderEvent.PAUSE, resourcePauseHandler);
			loader.removeEventListener(ResourceLoaderEvent.FAILURE, resourceFinishedHandler);
			loader.removeEventListener(ResourceLoaderEvent.COMPLETE, resourceFinishedHandler);
		}

		/**
		 * Handler for the resource loading event.
		 * 
		 * <p>Starts listening to the loader stop event.</p>
		 */
		private function resourceLoadingHandler(event : ResourceLoaderEvent) : void {
			var resourceLoader : IResourceLoader = event.resourceLoader;
			_loadingLoaders.add(resourceLoader);
			resourceLoader.addEventListener(ResourceLoaderEvent.STOP, resourceStopHandler);
		}

		/**
		 * Handler for the resource stop event.
		 */
		private function resourceStopHandler(event : ResourceLoaderEvent) : void {
			removeLoaderFromLoadingList(event.resourceLoader);
		}

		/**
		 * Handler for the resource pause event.
		 */
		private function resourcePauseHandler(event : ResourceLoaderEvent) : void {
			loaderPaused(event.resourceLoader);
		}
		
		/**
		 * Handler for the resource resume event.
		 */
		private function resourceResumeHandler(event : ResourceLoaderEvent) : void {
			loaderResumed(event.resourceLoader);

			dispatchResume();
		}
		
		/**
		 * Handler for the resource finished events COMPLETE and FAILURE.
		 */
		private function resourceFinishedHandler(event : ResourceLoaderEvent) : void {
			var resourceLoader : IResourceLoader = event.resourceLoader;
			//trace ("Resource " + event.type + " " + resourceLoader);
			removeLoaderFromLoadingList(resourceLoader);
			removeLoaderFromSchedule(resourceLoader);

			loaderFinished(resourceLoader);
			
			dispatchRemove(resourceLoader);
		}

		/*
		 * Private
		 */
		
		/**
		 * Removes a finished loader from the loading loaders list.
		 */
		private function removeLoaderFromLoadingList(resourceLoader : IResourceLoader) : void {
			_loadingLoaders.remove(resourceLoader);
			resourceLoader.removeEventListener(ResourceLoaderEvent.STOP, resourceStopHandler);
		}

		/**
		 * Removes a loader from the loaders list.
		 */
		private function removeLoaderFromSchedule(resourceLoader : IResourceLoader) : void {
			_loaders.remove(resourceLoader);
			deconfigureListeners(resourceLoader);
		}

		/*
		 * Sequence events
		 */

		/**
		 * Dispatches the SequenceEvent.ADD event.
		 */
		protected function dispatchAdd(resourceLoader : IResourceLoader) : void {
//			trace ("DISPATCH SEQUENCE ADD " + numItemsLoaded + " " + numItems);
			dispatchEvent(new SequenceEvent(SequenceEvent.ADD, this, resourceLoader));
		}

		/**
		 * Dispatches the SequenceEvent.REMOVE event.
		 */
		protected function dispatchRemove(resourceLoader : IResourceLoader) : void {
//			trace ("DISPATCH SEQUENCE REMOVE " + numItemsLoaded + " " + numItems);
			dispatchEvent(new SequenceEvent(SequenceEvent.REMOVE, this, resourceLoader));
		}

		/**
		 * Dispatches the SequenceEvent.PROGRESS event.
		 */
		protected function dispatchProgress() : void {
			//trace ("DISPATCH SEQUENCE PROGRESS " + numItemsLoaded + " " + numItems);
			dispatchEvent(new SequenceEvent(SequenceEvent.PROGRESS, this));
		}
		
		/**
		 * Dispatches the SequenceEvent.STOP event.
		 */
		protected function dispatchStop() : void {
			//trace ("DISPATCH SEQUENCE STOPPED " + numItemsLoaded);
			dispatchEvent(new SequenceEvent(SequenceEvent.STOP, this));
		}

		/**
		 * Dispatches the SequenceEvent.PAUSE event.
		 */
		protected function dispatchPause() : void {
			//trace ("DISPATCH SEQUENCE PAUSED " + numItemsLoaded);
			dispatchEvent(new SequenceEvent(SequenceEvent.PAUSE, this));
		}

		/**
		 * Dispatches the SequenceEvent.RESUME event.
		 */
		protected function dispatchResume() : void {
//			trace ("DISPATCH SEQUENCE RESUME " + numItemsLoaded);
			dispatchEvent(new SequenceEvent(SequenceEvent.RESUME, this));
		}

		/**
		 * Dispatches the SequenceEvent.COMPLETE event.
		 */
		protected function dispatchComplete() : void {
//			trace ("DISPATCH SEQUENCE COMPLETE " + numItemsLoaded + " " + numItems);
			dispatchEvent(new SequenceEvent(SequenceEvent.COMPLETE, this));
		}

	}
}
