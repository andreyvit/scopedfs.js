{ ok, equal, deepEqual } = require 'assert'

fs       = require 'fs'
Path     = require 'path'
scopedfs = require '../lib/scopedfs'

describe "ScopedFS", ->

  it "should be able to create and fill a new temp dir", ->
    tempfs = scopedfs.createTempFS('subfs-test-')

    ok tempfs.path.match /subfs-test-/
    ok fs.statSync(tempfs.path).isDirectory()

    tempfs.putSync 'foo/bar/boz.txt', "42\n"

    p = Path.join(tempfs.path, 'foo/bar/boz.txt')
    ok fs.statSync(p).isFile()

    equal fs.readFileSync(p, 'utf8'), "42\n"


  it "should implement some of the fs APIs", ->
    tempfs = scopedfs.createTempFS('subfs-test-')
    tempfs.putSync 'foo/bar/boz.txt', "42\n"
    tempfs.putSync 'foo/bar/buzz.txt', "24\n"

    deepEqual tempfs.readdirSync('foo/bar').sort(), ['boz.txt', 'buzz.txt']


  it "should implement scoped APIs", ->
    tempfs = scopedfs.createTempFS('subfs-test-')
    subfs = tempfs.scoped('foo')
    subfs.putSync 'bar/boz.txt', "42\n"
    subfs.putSync 'bar/buzz.txt', "24\n"

    deepEqual tempfs.readdirSync('foo/bar').sort(), ['boz.txt', 'buzz.txt']
