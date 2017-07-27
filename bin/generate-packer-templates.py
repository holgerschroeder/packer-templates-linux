#!/usr/bin/python

# this script is used to generate "packer template json files"
# from jinja template files. we do this, because the packer
# template files are quite repetitive and error-prone to write
# by hand...

import copy
import os
import errno
import sys
import jinja2
import yaml
import glob
import pprint
import argparse

argParser = argparse.ArgumentParser(description="Generate packer templates")
argParser.add_argument("-r", "--distrel", required=True)
argParser.add_argument("-t", "--targetnettype", default="direct", choices=["direct", "mycompany"])
argParser.add_argument("-f", "--fetchnettype", default="direct", choices=["direct", "mycompany"])
argParser.add_argument("-v", "--boxversion", required=True)
argParser.add_argument("-d", "--debug", action='store_true')
argParser.add_argument("steps", nargs="+", metavar="step")

args = argParser.parse_args()

# the target net type, used to add company-only customizations,
# if needed.
targetNetType=args.targetnettype

# the fetch net type, same as above, but only for fetching data,
# e.g. for setting package repos.
# used e.g. to build a box for "direct internet access settings"
# from behind a company firewall. there you need to use e.g. a
# proxy to access the internet, but the resulting box should not
# have these settings.
fetchNetType=args.fetchnettype

# the name of the distribution and its release
distRelName = args.distrel

# the box version that the vagrant box should get
boxVersion=args.boxversion

# the steps that should be executed
steps=args.steps

# here we hold the loaded yaml configs
yamlConfigs = {}

# here we hold the "real configs", i.e. we load and merge
# the yaml_config entries into this dict, and we resolve
# the data inheritance by putting the base data in the dict
# first, and then overwriting it by the child data. this
# way we do not need to walk around in the dicts later, but
# we have all data members in the correct dict.
realConfigs = {}

def loadYamlConfig( yamlConfigs, fileName ):
    # here we load a yaml file into the yaml_configs dict.
    # we have the following requirements:
    # - each yaml file needs to have a "name" parameter.
    # - the "name" parameter needs to be the same as the config
    #   file name without the ".yaml" suffix.
    # - the "name" parameter of each yaml file needs to be unique.
    # - if a config has a "parent" parameter, it has to point
    #   to an existing other config name.
    # - all the other parameters will be used to configure the
    #   build steps of a "distrel" (a release of a distribution)
    # - we keep the configs in different files, so that in the
    #   end we do not have to maintain duplicated information
    print "loadYamlConfig: %s" % fileName

    # load yaml file into this python dictionary
    dict = yaml.load(open(fileName, "r").read())

    # do some sanity checking
    if not dict:
        raise ValueError("file: %s. error: the dictionary is empty." % fileName)

    if "name" not in dict:
        raise ValueError("file: %s. error: no \"name\" attribute set." % fileName)

    expectedName = fileName.split(os.path.sep)[-1].split(".")[0]

    if not (expectedName == dict["name"]):
        raise ValueError("file: %s. error: \"name\" attribute does not match file name." % fileName)

    # save the data into an entry in the yamlconfigs dictionary
    yamlConfigs[ dict["name"] ] = dict
    

def loadYamlConfigs( yamlConfigs ):
    # here we just load all .yaml config files in the config directory
    print "loadYamlConfigs"

    for fileName in glob.glob("config/*.yaml"):
        loadYamlConfig(yamlConfigs, fileName)

def loadRealConfigsFromYamlConfigs( real_configs, yaml_configs ):
    # a config can have a "parent". when it has a parent,
    # it inherits the data from that parent, and it can
    # have own data that possibly overwrites the parent
    # data.

    # we implement this "config inheritance" this way:
    # we try to copy all configs from yamlConfigs to
    # realConfigs. we can have these cases:
    # - a config has no parent: we can copy it directly
    # - a config has a parent, and that parent was already
    #   copied: we fill the config with the data from the
    #   parent config, then we fill in the own data, then
    #   we save it to the realConfigs.
    # - a config has a parent, and the parent is not in
    #   realConfigs yet: we skip this config
    # Then we loop over the yamlConfigs until all configs
    # are copied. By filling config data from the parent
    # first and then from the own data we "flatten" the
    # config hierarchy, and every config contains all the
    # data of its parents.

    # to guard against endless loops, we check if we changed
    # something in each loop, and we check if we are done.
    # and we return an error if we did not change anything
    # in a loop, and when we are not done.

    # yes, this looks a bit complicated, but it is easier
    # than needing to maintain many similar packer config
    # files. (at least i hope so...)

    if args.debug:
        print "loadRealConfigsFromYamlConfigs begin"

    while True:
        if args.debug:
            print "loadRealConfigsFromYamlConfigs loop begin"

        done = True
        changed = False

        for yamlConfigName in yamlConfigs:
            yamlConfig = yamlConfigs[yamlConfigName]

            if args.debug:
                print "yamlConfigName:"
                pprint.pprint(yamlConfigName)
                print "yamlConfig:"
                pprint.pprint(yamlConfig)

            # check if config is already done
            if "done" in yamlConfig:
                if args.debug:
                    print "%s already done, skipping" % yamlConfigName

            # check if config has no parent
            elif not "parent" in yamlConfig:
                if args.debug:
                    print "%s has no parent, copying it" % yamlConfigName

                realConfigs[yamlConfigName] = copy.deepcopy(yamlConfig)
                realConfigs[yamlConfigName]["scriptSearchPathList"] = [ yamlConfigName ]
                yamlConfig["done"] = True
                changed = True

            # check if parent is already copied to realConfigs
            elif yamlConfig["parent"] in realConfigs:
                if args.debug:
                    print "%s has already copied parent, copying it" % yamlConfigName

                # get a deep copy of the parent data
                tmpConfig = copy.deepcopy(realConfigs[yamlConfig["parent"]])

                # copy the own keys, possibly overwrite parent key values
                for key in yamlConfig:
                    tmpConfig[key] = yamlConfig[key]

                # and now set the script search path:
                # prepend the config name to the parent list
                scriptSearchPathList = [ yamlConfigName ]

                if "scriptSearchPathList" in realConfigs[yamlConfig["parent"]]:
                    scriptSearchPathList.extend(realConfigs[yamlConfig["parent"]]["scriptSearchPathList"])

                tmpConfig["scriptSearchPathList"] = scriptSearchPathList

                realConfigs[yamlConfigName] = tmpConfig
                yamlConfig["done"] = True
                changed = True

            else:
                if args.debug:
                    print "unhappy case: %s" % yamlConfigName
                done = False

        if not done and not changed:
            raise ValueError( "endless loop detected..." )

        if done:
            break


def addUserVariablesToConfig(realConfig):
    # here we fill the commandline parameters into the realConfig.

    # we throw an error exception when we would override
    # an already-set parameter from the yamlConfigs

    if "target_net_type" in realConfig:
        raise ValueError("target_net_type is already set in config")

    realConfig["target_net_type"] = targetNetType

    if "box_version" in realConfig:
        raise ValueError("box_version is already set in config")

    realConfig["box_version"] = boxVersion


def getScriptPath(scriptName, stepName, scriptSearchPathList):
    # here search for a script with the given name in the
    # different possible script directories.
    # this is the search order:
    # first the different dirs for the given step are searched
    # then the different dirs for the step-common dir are searched
    # the different dirs are named like the yaml config files,
    # and they are searched from child to parent recursively.

    # an example:
    # - scripts/step2/ubuntu-1604
    # - scripts/step2/ubuntu
    # - scripts/step2/common
    # - scripts/step-common/ubuntu-1604
    # - scripts/step-common/ubuntu
    # - scripts/step-common/common

    # This way we can have one common script for a given task,
    # and if needed we can put a special script for some special
    # handling for a distrel in a "child" directory, and then the
    # "more specialized" script gets loaded.
    if args.debug:
        print "getScriptPath for scriptName: %s, stepName: %s, scriptSearchPathList: %s" % (
            scriptName, stepName, scriptSearchPathList)

    # the scripts live under the different subdirectories in the scripts/ directory.
    scriptPathPrefix = "scripts"

    # try to find the script in the stepX and as fallback in the step-common directory
    for myStepName in stepName, "step-common":
        
        # try to find the script in the given script search path, walking the inheritance
        # hierarchy up from the child to its parents
        for scriptSearchPathEntry in scriptSearchPathList:

            scriptPath ="%s/%s/%s" % (scriptPathPrefix, myStepName, scriptSearchPathEntry)
            if os.path.isfile( "%s/%s" % (scriptPath, scriptName)):
                if args.debug:
                    print "  got file: %s/%s" % (scriptPath, scriptName)
                return scriptPath

    # when we reach this part, we did not find the requested script in any defined script
    # subdirectory for this distrel. print an error and fail the script in this case.
    raise ValueError("getScriptPath: scriptName: %s stepName: %s error: script not found in search path" % (
        scriptName, stepName))

def jsonListStringFromList(yamlList):
    # here we take the entries in a list, and we
    # convert them to a string that is a valid content of a json list

    myString = ""

    firstLoop = True
    for item in yamlList:
        print "got item: %s" % item

        if firstLoop:
            firstLoop = False
        else:
            # add line delimiter
            myString+=",\n"

        myString+='"%s"' % item

    myString+="\n"

    return myString


def calculateScriptPaths(realConfig):
    # here we walk over the different realConfigs, and we try to
    # find the paths for the scripts that we want to load, this
    # way we can have common scripts in a common dir, and we can
    # have special scripts in special dirs

    if args.debug:
        print "calculcateScriptPaths for %s" % realConfig["name"]

    for key in realConfig:
        if args.debug:
            print "got realConfig key: %s" % key

        if key.startswith("scripts_"):
            if args.debug:
                print "got scripts key: %s" % key

            stepName = key[len("scripts_"):]
            if args.debug:
                print "stepName: %s" % stepName

            scriptsList = realConfig[key]

            tmpList = []

            for script in scriptsList:
                if args.debug:
                    print "working on script: %s" % script

                # do jinja expansion of script file name
                # (we need to do the expansion here, because
                # this content will be inserted as variable
                # content into the jinja template. so this
                # cannot be expanded at the main render() call.)
                tmpScript = jinja2.Template(script).render(realConfig)

                # now find tmpScript in search path
                scriptPath = getScriptPath(tmpScript, stepName, realConfig["scriptSearchPathList"])

                tmpList.append("%s/%s" % (scriptPath, tmpScript))

            # now we need to format the scripts in a packer-json compatible way,
            # i.e. replace ' with "
            realConfig[key] = jsonListStringFromList(tmpList)

def updateIsoUrls(realConfig):
    # we need to hold the iso_urls yaml list as a string that
    # represents a valid json list

    if "iso_urls" in realConfig:
        iso_urls = realConfig["iso_urls"]
        realConfig["iso_urls"] = jsonListStringFromList(iso_urls)

def generateConfigFiles(realConfig, steps):
    # here we generate the configs for the given distribution release,
    # steps, fetch net type, target net type and box version.

    print "generateConfigs for distRel %s" % distRelName

    jinjaEnv = jinja2.Environment(loader=jinja2.FileSystemLoader('config'))

    for step in steps:
        configFile = "build/%s-%s.json" % (distRelName, step)
        if args.debug:
            print "generating config file for %s: %s" % (step, myFile)
    
        try:
            templateFile = 'template-%s.json.jinja' % step
            template = jinjaEnv.get_template(templateFile)
            output_from_parsed_template = template.render(realConfig)
            with open(configFile, "wb") as fh:
                fh.write(output_from_parsed_template)
        except jinja2.exceptions.TemplateNotFound:
            print "error: template for step %s not found: %s" % (step, templateFile)
            print "exiting."
            sys.exit(1)
                
loadYamlConfigs(yamlConfigs)

loadRealConfigsFromYamlConfigs(realConfigs, yamlConfigs)

realConfig = realConfigs[distRelName]

addUserVariablesToConfig(realConfig)

calculateScriptPaths(realConfig)

updateIsoUrls(realConfig)

generateConfigFiles(realConfig, steps)

print "generate-packer-templates.py success"
