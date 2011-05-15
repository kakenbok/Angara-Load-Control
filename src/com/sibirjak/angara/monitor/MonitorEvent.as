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

	import flash.events.Event;

	/**
	 * Monitor event definition.
	 * 
	 * @author jes 17.02.2009
	 */
	public class MonitorEvent extends Event {

		private var _monitor : IMonitor;

		/**
		 * Progress of monitor has changed.
		 */
		public static const PROGRESS : String = "monitor_progress";

		/**
		 * All monitor items finished (complete or failed).
		 */
		public static const COMPLETE : String = "monitor_complete";

		/**
		 * Creates a new LoaderItemEvent.
		 * 
		 * @param type Type of the event.
		 * @param monitor Reference to the monitor.
		 */
		public function MonitorEvent(type : String, monitor : IMonitor) {
			super(type);
			
			_monitor = monitor;
		}

		/**
		 * Returns the monitor dispatching this event.
		 * 
		 * @return The monitor.
		 */
		public function get monitor() : IMonitor {
			return _monitor;
		}
	}
}
