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
package com.sibirjak.angara.resource {

	import flash.display.DisplayObject;

	/**
	 * The IResourceLoaderContainer declares an arbitrary display class to be
	 * a target of the loaded content of an IDisplayAssetLoader.
	 * 
	 * <p>You may develop a more complex display class. When implementing this
	 * interface and assigning the display class to an IDisplayAssetLoader instance,
	 * the addLoadedContent() will be called after the resource is ready to display.
	 * Within the addLoadedContent() method you can perform your custom addChild()
	 * operation.</p>
	 * 
	 * @author jes 13.05.2009
	 * @see IDisplayAssetLoader
	 */
	public interface IResourceLoaderContainer {
		
		/**
		 * Method that is called if the resource of the according IDisplayAssetLoader
		 * is ready to be displayed.
		 * 
		 * @param content The content to be displayed.
		 */
		function addLoadedContent(content : DisplayObject) : void;
		
	}
}
