#!/usr/bin/xcrun swift
// Playground - noun: a place where people can play

import Foundation

let envKey = "KZBEnvironments"
let overrideKey = "KZBEnvOverride"

func validateEnvSettings(_ envSettings: NSDictionary?, prependMessage: NSString? = nil) -> Bool {
    if envSettings == nil {
        return false
    }
    
    var settings = envSettings! as! Dictionary<String, AnyObject>
    let allowedEnvs = settings[envKey] as! [String]
    
    settings.removeValue(forKey: envKey)
    
    var missingOptions = [String : [String]]()
    
    for (name, values) in settings {
        let variable = name as String
        let envValues = values as! [String: AnyObject]
        
        let notConfiguredOptions = allowedEnvs.filter {
            return envValues.index(forKey: $0) == nil
        }
        
        if notConfiguredOptions.count > 0 {
            missingOptions[variable] = notConfiguredOptions
        }
    }
    
    for (variable, options) in missingOptions {
        if let prepend = prependMessage {
            print("\(prepend) error:\(variable) is missing values for '\(options)'")
        } else {
            print("error:\(variable) is missing values for '\(options)'")
        }
    }
    
    return missingOptions.count == 0
}

func filterEnvSettings(_ entries: NSDictionary, forEnv env: String, prependMessage: String? = nil) -> NSDictionary {
    var settings = entries as! Dictionary<String, AnyObject>
    settings[envKey] = [env] as AnyObject
    for (name, values) in entries {
        let variable = name as! String
        if let envValues = values as? [String: AnyObject] {
            if let allowedValue: AnyObject = envValues[env] {
                settings[variable] = [env: allowedValue] as AnyObject
            } else {
                if let prepend = prependMessage {
                    print("\(prepend) missing value of variable \(name) for env \(env) available values \(values)")
                } else {
                    print("missing value of variable \(name) for env \(env) available values \(values)")
                }
            }
        }
    }
    
    return settings as NSDictionary
}


func processSettings(_ settingsPath: String, availableEnvs:[String], allowedEnv: String? = nil) -> Bool {
    var settingsPath = settingsPath
    let preferenceKey = "PreferenceSpecifiers"
    settingsPath = (settingsPath as NSString).appendingPathComponent("Root.plist") as String
    
    if let settings = NSMutableDictionary(contentsOfFile: settingsPath) {
        if var existing = settings[preferenceKey] as? [AnyObject] {
            existing = existing.filter {
                if let dictionary = $0 as? [String:AnyObject] {
                    let value = dictionary["Key"] as? String
                    if value == overrideKey {
                        return false
                    }
                }
                return true
            }
            
            //! only add env switch if there isnt allowedEnv override
            var updatedPreferences = existing as [AnyObject]
            if allowedEnv == nil {
                updatedPreferences.append(
                    [ "Type" : "PSMultiValueSpecifier",
                      "Title" : "Environment",
                      "Key" : overrideKey,
                      "Titles" : availableEnvs,
                      "Values" : availableEnvs,
                      "DefaultValue" : ""
                        ] as AnyObject)
            }
            settings[preferenceKey] = updatedPreferences
            print("Updating settings at \(settingsPath)")
            return settings.write(toFile: settingsPath, atomically: true)
        }
    }
    return false
}

func processEnvs(_ bundledPath: String, sourcePath: String, settingsPath: String, allowedEnv: String? = nil, dstPath: String? = nil) -> Bool {
    let settings = NSDictionary(contentsOfFile: bundledPath)
    let availableEnvs = (settings as! [String:AnyObject])[envKey] as! [String]
    
    if validateEnvSettings(settings, prependMessage: "\(sourcePath):1:" as NSString?) {
        if let filterEnv = allowedEnv {
            let productionSettings = filterEnvSettings(settings!, forEnv: filterEnv, prependMessage: "\(sourcePath):1:")
            
            productionSettings.write(toFile: dstPath ?? bundledPath, atomically: true)
        }
        
        let settingsAdjusted = processSettings(settingsPath, availableEnvs: availableEnvs, allowedEnv: allowedEnv)
        if settingsAdjusted == false {
            print("\(#file):\(#line): Unable to adjust settings bundle")
        }
        return settingsAdjusted
    }
    
    return false
}

let count = CommandLine.arguments.count
if count == 1 || count > 5 {
    print("\(#file):\(#line): Received \(count) arguments, Proper usage: processEnvironments.swift -- [bundledPath] [srcPath] [settingsPath] [allowedEnv]")
    exit(1)
}

let path = CommandLine.arguments[1]
let srcPath = CommandLine.arguments[2]
let settingsPath = CommandLine.arguments[3]
let allowedEnv: String? = (count != 5 ? nil : CommandLine.arguments[4])

if (processEnvs(path, sourcePath: srcPath, settingsPath: settingsPath, allowedEnv:allowedEnv) == true)
{
    exit (0)
}
else
{
    exit (1)
}
