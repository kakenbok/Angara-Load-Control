package com.sibirjak.angara.resource.loaders {
	import com.sibirjak.angara.resource.IResourceLoader;

	/**
	 * Extends the IResourceLoader interface with flash URLLoader functionality.
	 * 
	 * @author jes 07.05.2009
	 */
	public interface IURLLoaderDelegate extends IResourceLoader {

		/**
		 * Specifies the data format of the resource to load.
		 * 
		 * <p>You need to set up this property before the loader starts loading.</p>
		 * 
		 * @param format The resource data format.
		 */
		function set dataFormat(format : String) : void;
		
	}
}
