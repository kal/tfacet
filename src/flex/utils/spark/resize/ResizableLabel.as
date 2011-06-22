/*******************************************************************************
	Copyright (c) 2010 Chris Callendar (http://flexdevtips.blogspot.com/)
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/
package flex.utils.spark.resize {
	import mx.core.UIComponent;

	import spark.components.Label;

	/**
	 * Extends Label to show a resize handle in the bottom right corner
	 * that when dragged resizes the label.
	 *
	 * @author Chris Callendar
	 * @date June 28th, 2010
	 */
	public class ResizableLabel extends Label {

		private var resizeManager:ResizeManager;

		private var _resizeHandle:UIComponent;

		private var createdChildren:Boolean;

		public function ResizableLabel() {
			super();
			mouseChildren = true; // required for the resizeHandle to accept mouse events
			minWidth = 13;
			minHeight = 13;
			resizeManager = new ResizeManager(this, null);
		}

		[Bindable]
		public function get resizeHandle():UIComponent {
			return _resizeHandle;
		}

		public function set resizeHandle(value:UIComponent):void {
			if (_resizeHandle) {
				removeChild(_resizeHandle);
			}
			_resizeHandle = value;
			if (createdChildren && _resizeHandle) {
				addChild(_resizeHandle);
				resizeManager.resizeHandle = _resizeHandle;
			}
		}

		override protected function createChildren():void {
			super.createChildren();
			createdChildren = true;
			if (!resizeHandle) {
				resizeHandle = createResizeHandle();
			} else {
				addChild(resizeHandle);
			}
		}

		protected function createResizeHandle():UIComponent {
			var handle:ResizeHandleLines = new ResizeHandleLines();
			return handle;
		}

		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);

			if (resizeHandle) {
				resizeHandle.x = w - resizeHandle.width - 1;
				resizeHandle.y = h - resizeHandle.height - 1;
			}
		}

	}
}