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

	import com.sibirjak.angara.core.LoaderItemEvent;
	import com.sibirjak.angara.resource.IResourceLoader;

	/**
	 * Sequence event definition.
	 * 
	 * @author jes 17.02.2009
	 */
	public class SequenceEvent extends LoaderItemEvent {

		/**
		 * A loader has been added.
		 */
		public static const ADD : String = LoaderItemEvent.ADD;

		/**
		 * A loader has been removed.
		 */
		public static const REMOVE : String = LoaderItemEvent.REMOVE;

		/**
		 * Progress of sequence has changed.
		 */
		public static const PROGRESS : String = LoaderItemEvent.PROGRESS;

		/**
		 * All containing loaders are finished (either complete or failed).
		 */
		public static const COMPLETE : String = LoaderItemEvent.COMPLETE;

		/**
		 * Sequence stopped.
		 */
		public static const STOP : String = LoaderItemEvent.STOP;

		/**
		 * Sequence paused.
		 */
		public static const PAUSE : String = LoaderItemEvent.PAUSE;

		/**
		 * Sequence or any containing loader resumed.
		 */
		public static const RESUME : String = LoaderItemEvent.RESUME;

		/**
		 * Creates a new SequenceEvent.
		 * 
		 * @param type Type of the event.
		 * @param sequence Reference to the sequence.
		 * @param resourceLoader The affected (added or removed) resource loader.

		 */
		public function SequenceEvent(type : String, sequence : ISequence, resourceLoader : IResourceLoader = null) {
			super(type, sequence, resourceLoader);
		}
		
		/**
		 * Returns the event dispatching sequence.
		 * 
		 * @return The event dispatching sequence.
		 */
		public function get sequence() : ISequence {
			return _loaderItem as ISequence;
		}

		/**
		 * Returns the added or removed resource Loader in case of ADD or REMOVE events.
		 * 
		 * @return The added or removed resource loader.
		 */
		public function get resourceLoader() : IResourceLoader {
			return _affectedLoaderItem as IResourceLoader;
		}
	}
}
