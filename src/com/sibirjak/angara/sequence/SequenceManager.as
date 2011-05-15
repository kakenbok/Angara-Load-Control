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

	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IOrderedSet;

	/**
	 * The Sequence manager controls the behaviour of a set of sequences.
	 * 
	 * <p>Completed sequences will be removed from the internal sequence list and
	 * therefore won't be considered in enumeration using the manager's iterator.
	 * They won't be considered any more in calculating the progress values.</p>
	 * 
	 * @author jes 13.05.2009
	 */
	public class SequenceManager extends AbstractLoaderItem implements ISequenceManager {

		/**
		 * Internal list of sequences added.
		 */
		private var _sequences : IOrderedSet;

		/**
		 * Creates a new SequenceManager instance. 
		 */
		public function SequenceManager() {
			_sequences = new LinkedSet();

			_type = LoaderItemType.SEQUENCE;
			_status = LoaderItemStatus.WAITING;
		}
		
		/*
		 * ISequenceManager
		 */

		/**
		 * @inheritDoc
		 */
		public function add(sequence : ISequence) : void {
			// cannot add sequence to a finished manager
			if (_status == LoaderItemStatus.COMPLETE) return;

			// cannot add sequences elsewhere scheduled
			// adding the same sequence twice is therefore not permitted
			if (sequence.scheduled) return;

			configureListeners(sequence);
			_sequences.add(sequence);

			AbstractLoaderItem(sequence).sibirjak_loader::setScheduled(true);

			dispatchAdd(sequence);
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove(sequence : ISequence) : void {
			// cannot remove sequences that not exist
			if (!_sequences.has(sequence)) return;

			// cannot remove sequences from a finished manager
			if (_status == LoaderItemStatus.COMPLETE) return;

			removeSequence(sequence);

			AbstractLoaderItem(sequence).sibirjak_loader::setScheduled(false);
			
			// finally stop loading, remove loader from ConnectionPool
			sequence.stop();

			dispatchRemove(sequence);
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() : void {
			stop();
			
			var iterator : IIterator = _sequences.iterator();
			while (iterator.hasNext()) {
				deconfigureListeners(iterator.next());
			}
			_sequences.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		public function pauseAllExcept(sequence : ISequence) : void {
			if (!_sequences.has(sequence)) return;
			
			var iterator : IIterator = _sequences.iterator();
			var theSequence : ISequence;
			while (iterator.hasNext()) {
				theSequence = iterator.next();
				if (theSequence != sequence) {
					theSequence.pause();
					theSequence.stop();
				}
			}
			sequence.resume();
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadBeforeOthers(sequence : ISequence) : void {
			if (!_sequences.has(sequence)) return;
			
			_sequences.remove(sequence);
			_sequences.addFirst(sequence);
		}

		/*
		 * ILoaderItem
		 */

		/**
		 * @inheritDoc
		 */
		override public function stop() : void {
			var iterator : IIterator = _sequences.iterator();

			var sequence : ISequence;
			while (iterator.hasNext()) {
				sequence = iterator.next();
				sequence.stop();
			}

			dispatchStop();
		}

		/**
		 * @inheritDoc
		 */
		override public function pause() : void {
			// cannot change status of a completed manager
			if (_status != LoaderItemStatus.WAITING) return;
			_status = LoaderItemStatus.PAUSED;
			dispatchPause();
		}

		/**
		 * @inheritDoc
		 */
		override public function resume() : void {
			// cannot change status of a completed manager
			if (_status != LoaderItemStatus.PAUSED) return;
			_status = LoaderItemStatus.WAITING;
			dispatchResume();
		}

		/*
		 * IProgressInfo
		 */

		/**
		 * @inheritDoc
		 */
		override public function get numItems() : uint {
			var numItems : uint = 0;
			var iterator : IIterator = _sequences.iterator();
			var sequence : ISequence;
			while (iterator.hasNext()) {
				sequence = iterator.next();
				numItems += (sequence.numItems);
			}
			return numItems;
		}

		/**
		 * @inheritDoc
		 */
		override public function get numItemsLoaded() : uint {
			var numItems : uint = 0;
			var iterator : IIterator = _sequences.iterator();
			var sequence : ISequence;
			while (iterator.hasNext()) {
				sequence = iterator.next();
				numItems += sequence.numItemsLoaded;
			}
			return numItems;
		}

		/**
		 * @inheritDoc
		 */
		override public function get numItemsFailed() : uint {
			var numItems : uint = 0;
			var iterator : IIterator = _sequences.iterator();
			var sequence : ISequence;
			while (iterator.hasNext()) {
				sequence = iterator.next();
				numItems += sequence.numItemsFailed;
			}
			return numItems;
		}

		/**
		 * @inheritDoc
		 */
		override public function get progress() : Number {
			if (!_sequences.size) return 0;
			
			var progress : Number = 0;
			var iterator : IIterator = _sequences.iterator();
			var sequence : ISequence;
			while (iterator.hasNext()) {
				sequence = iterator.next();
				progress += sequence.progress;
			}
			return progress / _sequences.size;
		}

		/*
		 * IIterable
		 */

		/**
		 * Returns an iterator over all sequences left.
		 * 
		 * @return Iterator over all left sequences.
		 */
		public function iterator(cursor : * = undefined) : IIterator {
			return _sequences.iterator();
		}

		/**
		 * Info
		 */
		override public function toString() : String {
			return "[SequenceManager] key:" + key + " sequences:" + _sequences.size;
		}

		/*
		 * Sequence listeners
		 */

		/**
		 * Starts listening to sequence notifications.
		 */
		private function configureListeners(sequence : ISequence) : void {
			sequence.addEventListener(SequenceEvent.PROGRESS, sequenceProgressHandler);
			sequence.addEventListener(SequenceEvent.RESUME, sequenceResumeHandler);
			sequence.addEventListener(SequenceEvent.COMPLETE, sequenceCompleteHandler);
		}
		
		/**
		 * Stops listening to sequence notifications.
		 */
		private function deconfigureListeners(sequence : ISequence) : void {
			sequence.removeEventListener(SequenceEvent.PROGRESS, sequenceProgressHandler);
			sequence.removeEventListener(SequenceEvent.RESUME, sequenceResumeHandler);
			sequence.removeEventListener(SequenceEvent.COMPLETE, sequenceCompleteHandler);
		}

		/**
		 * Handler for the sequence progress event.
		 */
		private function sequenceProgressHandler(event : SequenceEvent) : void {
			dispatchProgress();
		}

		/**
		 * Handler for the sequence resume event.
		 */
		private function sequenceResumeHandler(event : SequenceEvent) : void {
			dispatchResume();
		}

		/**
		 * Handler for the sequence complete event.
		 */
		private function sequenceCompleteHandler(event : SequenceEvent) : void {
			removeSequence(event.sequence);
			dispatchRemove(event.sequence);
		}

		/*
		 * Sequence manager events
		 */

		/**
		 * Dispatches the LoaderItemEvent.ADD event.
		 */
		protected function dispatchAdd(sequence : ISequence) : void {
			//trace ("DISPATCH SEQUENCE MANAGER ADD " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.ADD, this, sequence));
		}

		/**
		 * Dispatches the LoaderItemEvent.REMOVE event.
		 */
		protected function dispatchRemove(sequence : ISequence) : void {
			//trace ("DISPATCH SEQUENCE MANAGER REMOVE " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.REMOVE, this, sequence));
		}

		/**
		 * Dispatches the LoaderItemEvent.PROGRESS event.
		 */
		protected function dispatchProgress() : void {
			//trace ("DISPATCH SEQUENCE MANAGER PROGRESS " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.PROGRESS, this));
		}

		/**
		 * Dispatches the LoaderItemEvent.STOP event.
		 */
		protected function dispatchStop() : void {
			//trace ("DISPATCH SEQUENCE MANAGER STOPPED " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.STOP, this));
		}

		/**
		 * Dispatches the LoaderItemEvent.PAUSE event.
		 */
		protected function dispatchPause() : void {
			//trace ("DISPATCH SEQUENCE MANAGER PAUSED " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.PAUSE, this));
		}

		/**
		 * Dispatches the LoaderItemEvent.RESUME event.
		 */
		protected function dispatchResume() : void {
//			trace ("DISPATCH SEQUENCE MANAGER RESUME " + numItemsLoaded);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.RESUME, this));
		}

		/**
		 * Dispatches the LoaderItemEvent.COMPLETE event.
		 */
		protected function dispatchComplete() : void {
//			trace ("DISPATCH SEQUENCE MANAGER COMPLETE " + numItemsLoaded + " " + numItems);
			dispatchEvent(new SequenceManagerEvent(SequenceManagerEvent.COMPLETE, this));
		}

		/*
		 * Private
		 */

		/**
		 * Removes a sequence from the internal sequence list.
		 */
		private function removeSequence(sequence : ISequence) : void {
			deconfigureListeners(sequence);
			_sequences.remove(sequence);
			
			if (!_sequences.size) dispatchComplete();
		}

	}
}
