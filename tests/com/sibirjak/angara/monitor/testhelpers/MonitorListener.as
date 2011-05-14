package com.sibirjak.angara.monitor.testhelpers {
	import com.sibirjak.angara.monitor.IMonitor;
	import com.sibirjak.angara.monitor.MonitorEvent;
	import com.sibirjak.angara.resource.IResourceLoader;
	import com.sibirjak.angara.resource.ResourceLoaderEvent;

	/**
	 * @author jes 17.02.2009
	 */
	public class MonitorListener {
		
		private var _monitorCompleteReceived : Boolean = false;
		private var _monitorProgressReceived : Boolean = false;
		private var _resourceCompleteReceived : Boolean = false;
		private var _resourceFailureReceived : Boolean = false;
		
		private var _targetedResource : IResourceLoader;

		public function MonitorListener(monitor : IMonitor) {
			monitor.addEventListener(ResourceLoaderEvent.COMPLETE, resourceCompleteHandler);
			monitor.addEventListener(ResourceLoaderEvent.FAILURE, resourceFailureHandler);
			monitor.addEventListener(MonitorEvent.COMPLETE, monitorCompleteHandler);
			monitor.addEventListener(MonitorEvent.PROGRESS, monitorProgressHandler);
		}
		
		private function resourceCompleteHandler(event : ResourceLoaderEvent) : void {
			_resourceCompleteReceived = true;
			
			_targetedResource = event.resourceLoader;
		}

		private function resourceFailureHandler(event : ResourceLoaderEvent) : void {
			_resourceFailureReceived = true;
			
			_targetedResource = event.resourceLoader;
		}

		private function monitorCompleteHandler(event : MonitorEvent) : void {
			_monitorCompleteReceived = true;
		}
		
		private function monitorProgressHandler(event : MonitorEvent) : void {
			_monitorProgressReceived = true;
		}
		
		public function get monitorCompleteReceived() : Boolean {
			var received : Boolean = _monitorCompleteReceived;
			_monitorCompleteReceived = false;
			_targetedResource = null;
			return received;
		}
		
		public function get monitorProgressReceived() : Boolean {
			var received : Boolean = _monitorProgressReceived;
			_monitorProgressReceived = false;
			return received;
		}
		
		public function get resourceCompleteReceived() : Boolean {
			var received : Boolean = _resourceCompleteReceived;
			_resourceCompleteReceived = false;
			return received;
		}
		
		public function get resourceFailureReceived() : Boolean {
			var received : Boolean = _resourceFailureReceived;
			_resourceFailureReceived = false;
			return received;
		}
		
		public function get targetedResource() : IResourceLoader {
			return _targetedResource;
		}
	}
}
