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
