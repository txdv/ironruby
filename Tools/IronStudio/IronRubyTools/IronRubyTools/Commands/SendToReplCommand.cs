﻿/* ****************************************************************************
 *
 * Copyright (c) Microsoft Corporation. 
 *
 * This source code is subject to terms and conditions of the Apache License, Version 2.0. A 
 * copy of the license can be found in the License.html file at the root of this distribution. If 
 * you cannot locate the Apache License, Version 2.0, please send an email to 
 * ironruby@microsoft.com. By using this source code in any fashion, you are agreeing to be bound 
 * by the terms of the Apache License, Version 2.0.
 *
 * You must not remove this notice, or any other, from this software.
 *
 * ***************************************************************************/

using System;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.OLE.Interop;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Shell;
using Microsoft.IronStudio.Repl;
using Microsoft.IronStudio;

namespace Microsoft.IronRubyTools.Commands {
    /// <summary>
    /// Provides the command to send selected text from a buffer to the remote REPL window.
    /// </summary>
    class SendToReplCommand : Command {
        public override void DoCommand(object sender, EventArgs args) {
            var window = ExecuteInReplCommand.EnsureReplWindow();

            IVsWindowFrame windowFrame = (IVsWindowFrame)window.Frame;
            ErrorHandler.ThrowOnFailure(windowFrame.Show());
            
            var activeView = CommonPackage.GetActiveTextView();

            foreach (var span in activeView.Selection.SelectedSpans) {
                var text = span.GetText();
                ((IReplWindow)window).PasteText(text);
            }

            ((IReplWindow)window).Focus();
        }

        public override int? EditFilterQueryStatus(ref VisualStudio.OLE.Interop.OLECMD cmd, IntPtr pCmdText) {
            var activeView = CommonPackage.GetActiveTextView();
            if (activeView != null && activeView.TextBuffer.ContentType.IsOfType(RubyCoreConstants.ContentType)) {
                if (activeView.Selection.IsEmpty || activeView.Selection.Mode == TextSelectionMode.Box) {
                    cmd.cmdf = (uint)(OLECMDF.OLECMDF_SUPPORTED);
                } else {
                    cmd.cmdf = (uint)(OLECMDF.OLECMDF_ENABLED | OLECMDF.OLECMDF_SUPPORTED);
                }
            } else {
                cmd.cmdf = (uint)(OLECMDF.OLECMDF_INVISIBLE);
            }

            return VSConstants.S_OK;
        }

        public override EventHandler BeforeQueryStatus {
            get {
                return (sender, args) => {
                    ((OleMenuCommand)sender).Visible = false;
                    ((OleMenuCommand)sender).Supported = false;
                };
            }
        }
        public override int CommandId {
            get { return (int)PkgCmdIDList.cmdidSendToRepl; }
        }
    }
}
