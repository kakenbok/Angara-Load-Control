package com.sibirjak.angara.resource {

	/**
	 * The callback interface provides methods to control a resource loader
	 * callback behaviour.
	 * 
	 * <p>It is possible to assign a callback function to any resource loader. If
	 * a callback has been specified, the callback will be executed before the
	 * resource loader COMPLETE event is dispatched. It is possible to mark a
	 * callback as asynchronous, which will stop the loader manager queue until
	 * the notifyComplete() method of that callback has been triggered.</p>
	 * 
	 * <p>Per default a callback method will be called synchronously. The loader
	 * manager continues working right after the callback handler has been triggered.</p>
	 * 
	 * @author jes 04.05.2009
	 */
	public interface ICallback {
		
		/**
		 * Returns a reference to the loader that defines the callback.
		 * 
		 * @return The resource loader defining the callback.
		 */
		function get loader() : IResourceLoader;

		/**
		 * Sets a callback to be asynchronous.
		 * 
		 * <p>The loader manager will wait for the callback completion to continue
		 * its work. You need to call callback.notifyComplete() to notify the loader
		 * manager to continue.</p>
		 */
		function setAsync() : void;

		/**
		 * Notifies the loader manager about a completed asynchronous callback.
		 * 
		 * <p>The loader manager will continue loading not until this method has
		 * been called.</p>
		 */
		function notifyComplete() : void;
		
	}
}
