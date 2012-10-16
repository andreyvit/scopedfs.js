temp   = require 'temp'
fs     = require 'fs'
Path   = require 'path'
mkdirp = require 'mkdirp'
rimraf = require 'rimraf'


class ScopedFS
  constructor: (@path) ->
    # Turn all methods into standalone functions.
    for own k, v of this
      if typeof v is 'function'
        this[k] = v.bind(this)


  # fs module API

  rename: (oldpath, newpath, callback) ->
    fs.rename @pathOf(oldpath), @pathOf(newpath), callback

  renameSync: (oldpath, newpath) ->
    fs.renameSync @pathOf(oldpath), @pathOf(newpath)


  stat: (path, callback) ->
    fs.stat @pathOf(path), callback

  statSync: (path) ->
    fs.statSync @pathOf(path)


  chown: (path, uid, gid, callback) ->
    fs.chown @pathOf(path), uid, gid, callback

  chownSync: (path, uid, gid) ->
    fs.chownSync @pathOf(path), uid, gid


  lchown: (path, uid, gid, callback) ->
    fs.lchown @pathOf(path), uid, gid, callback

  lchownSync: (path, uid, gid) ->
    fs.lchownSync @pathOf(path), uid, gid


  chmod: (path, mode, callback) ->
    fs.chmod @pathOf(path), mode, callback

  chmodSync: (path, mode) ->
    fs.chmodSync @pathOf(path), mode


  lchmod: (path, mode, callback) ->
    fs.lchmod @pathOf(path), mode, callback

  lchmodSync: (path, mode) ->
    fs.lchmodSync @pathOf(path), mode


  lstat: (path, callback) ->
    fs.lstat @pathOf(path), callback

  lstatSync: (path) ->
    fs.lstatSync @pathOf(path)


  link: (srcpath, dstpath, callback) ->
    fs.link @pathOf(srcpath), @pathOf(dstpath), callback

  linkSync: (srcpath, dstpath) ->
    fs.linkSync @pathOf(srcpath), @pathOf(dstpath)


  symlink: (srcpath, dstpath, type, callback) ->
    fssym.symlink @pathOf(srcpath), @pathOf(dstpath), type, callback

  symlinkSync: (srcpath, dstpath, type) ->
    fssym.symlinkSync @pathOf(srcpath), @pathOf(dstpath), type


  readlink: (path, callback) ->
    fs.readlink @pathOf(path), callback

  readlinkSync: (path) ->
    fs.readlinkSync @pathOf(path)


  realpath: (path, cache, callback) ->
    fs.readlink @pathOf(path), cache, callback

  realpathSync: (path, cache) ->
    fs.readlinkSync @pathOf(path), cache


  unlink: (path, callback) ->
    fs.unlink @pathOf(path), callback

  unlinkSync: (path) ->
    fs.unlinkSync @pathOf(path)


  rmdir: (path, callback) ->
    fs.rmdir @pathOf(path), callback

  rmdirSync: (path) ->
    fs.rmdirSync @pathOf(path)


  mkdir: (path, mode, callback) ->
    fs.mkdir @pathOf(path), mode, callback

  mkdirSync: (path, mode) ->
    fs.mkdirSync @pathOf(path), mode


  readdir: (path, mode, callback) ->
    fs.readdir @pathOf(path), mode, callback

  readdirSync: (path, mode) ->
    fs.readdirSync @pathOf(path), mode


  readFile: (relpath, encoding, callback) ->
    fs.readFile @pathOf(relpath), encoding, callback

  readFileSync: (relpath, encoding) ->
    fs.readFileSync @pathOf(relpath), encoding


  writeFile: (relpath, data, encoding, callback) ->
    fs.writeFile @pathOf(relpath), data, encoding, callback

  writeFileSync: (relpath, data, encoding) ->
    fs.writeFileSync @pathOf(relpath), data, encoding


  appendFile: (relpath, data, encoding, callback) ->
    fs.appendFile @pathOf(relpath), data, encoding, callback

  appendFileSync: (relpath, data, encoding) ->
    fs.appendFileSync @pathOf(relpath), data, encoding


  exists: (path, callback) ->
    fs.exists @pathOf(path), callback

  existsSync: (path) ->
    fs.existsSync @pathOf(path)


  createReadStream: (path, options) ->
    fs.createReadStream @pathOf(path), options


  createWriteStream: (path, options) ->
    fs.createWriteStream @pathOf(path), options


  open: (path, flags, mode, callback) ->
    fs.open @pathOf(path), flags, mode, callback

  openSync: (path, flags, mode) ->
    fs.openSync @pathOf(path), flags, mode


  # pass-thru fs APIs

  truncate: (fd, len, callback) ->
    fs.truncate(fd, len, callback)

  truncateSync: (fd, len) ->
    fs.truncateSync(fd, len)

  fchown: (fd, uid, gid, callback) ->
    fs.fchown(fd, uid, gid, callback)

  fchownSync: (fd, uid, gid) ->
    fs.fchownSync(fd, uid, gid)

  fchmod: (fd, mode, callback) ->
    fs.fchmod(fd, mode, callback)

  fchmodSync: (fd, mode) ->
    fs.fchmodSync(fd, mode)

  close: (fs, callback) ->
    fs.close(fs, callback)

  closeSync: (fs) ->
    fs.closeSync(fs)

  futimes: (fd, atime, mtime, callback) ->
    fs.futimes(fd, atime, mtime, callback)

  futimesSync: (fd, atime, mtime) ->
    fs.futimesSync(fd, atime, mtime)

  fsync: (fs, callback) ->
    fs.fsync(fs, callback)

  fsyncSync: (fs) ->
    fs.fsyncSync(fs)

  write: (fd, buffer, offset, length, position, callback) ->
    fs.write(fd, buffer, offset, length, position, callback)

  writeSync: (fd, buffer, offset, length, position) ->
    fs.writeSync(fd, buffer, offset, length, position)

  read: (fd, buffer, offset, length, position, callback) ->
    fs.read(fd, buffer, offset, length, position, callback)

  readSync: (fd, buffer, offset, length, position) ->
    fs.readSync(fd, buffer, offset, length, position)


  # extended API

  rmrf: (path, callback) ->
    rimraf(@pathOf(path), callback)

  rmrfSync: (path) ->
    rimraf.sync(@pathOf(path))

  mkdirp: (path, mode, callback) ->
    mkdirp(@pathOf(path), mode, callback)

  mkdirpSync: (path, mode) ->
    mkdirp.sync(@pathOf(path), mode)

  # Does `mkdirpSync`, then `writeFileSync`.
  putSync: (relpath, data, encoding) ->
    @mkdirpSync Path.dirname(relpath)
    @writeFileSync relpath, data, encoding

  # A convenient method for creating fixture folders in tests
  applySync: (update) ->
    for own relpath, content of update
      if typeof content is 'function'
        content(@pathOf(relpath))
      else if content?
        if relpath.match /\/$/
          @mkdirpSync relpath.replace /\/$/, ''
        else
          @putSync relpath, content
      else
        @rmrfSync relpath, content


  # subfs API

  pathOf: (relpath) ->
    Path.join(@path, relpath)

  scoped: (relpath) ->
    new ScopedFS(@pathOf(relpath))

  createTempFS: (affixes) ->
    new ScopedFS(temp.mkdirSync(affixes))


module.exports = new ScopedFS('/')
module.exports.ScopedFS = ScopedFS
