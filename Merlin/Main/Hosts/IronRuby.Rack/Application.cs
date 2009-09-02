﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.IO;
using System.Web;
using IronRuby.Builtins;

namespace IronRuby.Rack {
    public class Application {

        private readonly object _app;
        private readonly string _appRoot;
        private readonly string _rackVersion;
        private readonly string _gemPath;

        public object App {
            get { return _app; }
        }

        private const string AppRootOptionName = "AppRoot";
        private const string RackVersionOptionName = "RackVersion";
        private const string GemPathOptionName = "GemPath";

        public Application(HttpContext context) {
            _appRoot = GetRoot(context);
            _rackVersion = GetRackVersion();
            _gemPath = GetGemPath();

            InitRack();
            _app = Rackup();
        }

        public RubyArray Call(IDictionary<object, object> env) {
            var envHash = new Hash(RubyEngine.Context);
            foreach (var pair in env) {
                var value = pair.Value.GetType() == "".GetType() ? MutableString.Create((string)pair.Value, RubyEncoding.Default) : pair.Value;
                envHash[MutableString.Create((string)pair.Key, RubyEncoding.Default)] = value;
            }
            return RubyEngine.ExecuteMethod<RubyArray>(_app, "call", envHash);
        }

        private void InitRack() {
            Environment.SetEnvironmentVariable("GEM_PATH", _gemPath);

            Utils.Log("=> Loading RubyGems");
            RubyEngine.Require("rubygems");

            Utils.Log("=> Loading Rack " + _rackVersion);
            RubyEngine.Require("rack", _rackVersion);

            Utils.Log("=> Application root: " + _appRoot);
            RubyEngine.AddLoadPath(_appRoot);
        }

        private object Rackup() {
            Utils.Log("=> Loading Rack application");
            var fullPath = RubyEngine.FindFile("config.ru");
            if(fullPath != null) {
                var content = File.ReadAllText(fullPath, Encoding.UTF8);
                return RubyEngine.Execute("Rack::Builder.new { " + content + "}.to_app");
            }
            return null;
        }

        private static string GetRackVersion() {
            return ConfigurationManager.AppSettings[RackVersionOptionName] ?? "=1.0.0";
        }

        private static string GetRoot(HttpContext context) {
            var root = ConfigurationManager.AppSettings[AppRootOptionName];
            if (root == null) {
                root = context.Request.PhysicalApplicationPath;
            } else {
                if (!Path.IsPathRooted(root)) {
                    root = Path.Combine(context.Request.PhysicalApplicationPath, root);
                }
                if (!Directory.Exists(root)) {
                    throw new ConfigurationErrorsException(String.Format(
                        "Directory '{0}' specified by '{1}' setting in configuration doesn't exist",
                        root, AppRootOptionName));
                }
            }
            return root;
        }

        private static string GetGemPath() {
            return ConfigurationManager.AppSettings[GemPathOptionName] ?? "";
        }
    }
}
