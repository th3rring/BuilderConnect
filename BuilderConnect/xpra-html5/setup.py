#!/usr/bin/env python
# This file is part of Xpra.
# Copyright (C) 2017-2021 Antoine Martin <antoine@xpra.org>
# Xpra is released under the terms of the GNU GPL v2, or, at your option, any
# later version. See the file LICENSE for details.

import re
import sys
import shutil
import os.path
import subprocess


def glob_recurse(srcdir):
    m = {}
    for root, _, files in os.walk(srcdir):
        for f in files:
            dirname = root[len(srcdir)+1:]
            filename = os.path.join(root, f)
            m.setdefault(dirname, []).append(filename)
    return m

def get_status_output(*args, **kwargs):
    import subprocess
    kwargs["stdout"] = subprocess.PIPE
    kwargs["stderr"] = subprocess.PIPE
    try:
        p = subprocess.Popen(*args, **kwargs)
    except Exception as e:
        print("error running %s,%s: %s" % (args, kwargs, e))
        return -1, "", ""
    stdout, stderr = p.communicate()
    return p.returncode, stdout.decode("utf-8"), stderr.decode("utf-8")


def install_symlink(symlink_options, dst):
    for symlink_option in symlink_options:
        if symlink_option.find("*"):
            import glob
            #this is a glob, find at least one match:
            matches = glob.glob(symlink_option)
            if matches:
                symlink_option = matches[0]
            else:
                continue
        if os.path.exists(symlink_option):
            print("symlinked %s from %s" % (dst, symlink_option))
            if os.path.exists(dst):
                os.unlink(dst)
            os.symlink(symlink_option, dst)
            return True
    #print("no symlinks found for %s from %s" % (dst, symlink_options))
    return False


def get_vcs_info():
    def get_output_line(cmd):
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        out, _ = proc.communicate()
        if proc.returncode!=0:
            print("Error: %s returned %s" % (cmd, proc.returncode))
            return None
        v = out.decode("utf-8").splitlines()[0]
        return v
    info = {}
    branch = get_output_line("git branch --show-current")
    if branch:
        info["BRANCH"] = branch
    parts = get_output_line("git describe --always --tags").split("-")
    #ie: parts = ["v4.0.6", "85", "gf253d3f9d"]
    rev = 0
    if len(parts)==3:
        rev = parts[1]
    if branch=="master":
        rev = get_output_line("git rev-list --count HEAD --first-parent")
    if rev:
        try:
            rev = int(rev)
        except:
            print("invalid revision number %r" % (rev,))
        else:
            info["REVISION"] = rev

    proc = subprocess.Popen("git status", stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, _ = proc.communicate()
    changes = 0
    if proc.returncode==0:
        changes = 0
        lines = out.decode('utf-8').splitlines()
        for line in lines:
            sline = line.strip()
            if sline.startswith("modified: ") or sline.startswith("new file:") or sline.startswith("deleted:"):
                changes += 1
    if changes:
        info["LOCAL_MODIFICATIONS"] = changes
    return info

def record_vcs_info():
    info = get_vcs_info()
    if info:
        with open("./vcs-info", 'w') as f:
            for k,v in info.items():
                f.write("%s=%s\n" % (k,v))

def load_vcs_info():
    info = {}
    if os.path.exists("./vcs-info"):
        with open("./vcs-info", 'r') as f:
            for line in f:
                if line.startswith("#"):
                    continue
                parts = line.strip("\n\r").split("=")
                if len(parts)==2:
                    info[parts[0]] = parts[1]
    return info

def install_html5(install_dir="www", minifier="uglifyjs", gzip=True, brotli=True, verbose=False):
    info = load_vcs_info()
    if minifier not in ("", None, "copy"):
        print("minifying html5 client to '%s' using %s" % (install_dir, minifier))
    else:
        print("copying html5 client to '%s'" % (install_dir, ))
    #those are used to replace the file we ship in source form
    #with one that is maintained by the distribution:
    symlinks = {
        "jquery.js"     : [
            "/usr/share/javascript/jquery/jquery.js",
            "/usr/share/javascript/jquery/latest/jquery.js",
            "/usr/share/javascript/jquery/3/jquery.js",
            ],
        "jquery-ui.js"     : [
            "/usr/share/javascript/jquery-ui/jquery-ui.js",
            "/usr/share/javascript/jquery-ui/latest/jquery-ui.js",
            "/usr/share/javascript/jquery-ui/3/jquery-ui.js",
            ],
        }
    for k,files in glob_recurse("html5").items():
        if k!="":
            k = os.sep+k
        for fname in files:
            if fname.endswith(".tmp"):
                continue
            src = os.path.join(os.getcwd(), fname)
            parts = fname.split(os.path.sep)
            if parts[0]=="html5":
                fname = os.path.join(*parts[1:])
            if install_dir==".":
                install_dir = os.getcwd()
            dst = os.path.join(install_dir, fname)
            if os.path.exists(dst):
                os.unlink(dst)
            #try to find an existing installed library and symlink it:
            symlink_options = symlinks.get(os.path.basename(fname), [])
            if install_symlink(symlink_options, dst):
                #we've created a symlink, skip minification and compression
                continue
            ddir = os.path.split(dst)[0]
            if ddir and not os.path.exists(ddir):
                os.makedirs(ddir, 0o755)
            ftype = os.path.splitext(fname)[1].lstrip(".")
            bname = os.path.basename(src)

            fsrc = src
            if ftype=="js" or fname.endswith("index.html"):
                #save to a temporary file after replacing strings:
                with open(src, mode='br') as f:
                    odata = f.read().decode("latin1")
                data = odata
                if bname=="Utilities.js" and info:
                    print("adding vcs info to %s" % (bname,))
                    REVISION = info.get("REVISION")
                    if REVISION:
                        data = data.replace('REVISION : 0,',
                                            'REVISION : %s,' % REVISION)
                    LOCAL_MODIFICATIONS = info.get("LOCAL_MODIFICATIONS")
                    if LOCAL_MODIFICATIONS:
                        data = data.replace('LOCAL_MODIFICATIONS : 0,',
                                            'LOCAL_MODIFICATIONS : %s,' % LOCAL_MODIFICATIONS)
                    BRANCH = info.get("BRANCH")
                    if BRANCH:
                        data = data.replace('BRANCH : "master",',
                                            'BRANCH : "%s",' % BRANCH)
                for regexp, replacewith in {
                    r"^\s*for\s*\(\s*let\s+"     : "for(var ",
                    r"^\s*let\s+"                : "var ",
                    r"^\s*for\s*\(\s*const\s+"   : "for(var ",
                    r"^\s*const\s+"              : "var ",
                    }.items():
                    p = re.compile(regexp)
                    newdata = []
                    for line in data.splitlines():
                        newdata.append(p.sub(replacewith, line))
                    data = "\n".join(newdata)

                if data!=odata:
                    fsrc = src+".tmp"
                    with open(fsrc, "wb") as f:
                        f.write(data.encode("latin1"))
                    os.chmod(fsrc, 0o644)

            if minifier not in ("", None, "copy") and ftype=="js":
                if minifier=="uglifyjs":
                    minify_cmd = ["uglifyjs",
                                  fsrc,
                                  "-o", dst,
                                  "--compress",
                                  ]
                else:
                    assert minifier=="yuicompressor"
                    try:
                        import yuicompressor
                        jar = yuicompressor.get_jar_filename()
                        java_cmd = os.environ.get("JAVA", "java")
                        minify_cmd = [java_cmd, "-jar", jar]
                    except:
                        minify_cmd = ["yuicompressor"]
                    minify_cmd += [
                                  fsrc,
                                  "--nomunge",
                                  "--line-break", "400",
                                  "--type", ftype,
                                  "-o", dst,
                                  ]
                r = get_status_output(minify_cmd)[0]
                if r!=0:
                    print("Error: failed to minify '%s', command %s returned error %i" % (
                        bname, minify_cmd, r))
                    shutil.copyfile(fsrc, dst)
                os.chmod(dst, 0o644)
                print("minified %s" % (fname, ))
            else:
                print("copied %s" % (fname,))
                shutil.copyfile(fsrc, dst)
                os.chmod(dst, 0o644)

            if fsrc!=src:
                os.unlink(fsrc)

            if ftype not in ("png", ):
                if gzip:
                    gzip_dst = "%s.gz" % dst
                    if os.path.exists(gzip_dst):
                        os.unlink(gzip_dst)
                    cmd = ["gzip", "-f", "-n", "-9", "-k", dst]
                    get_status_output(cmd)
                    if os.path.exists(gzip_dst):
                        os.chmod(gzip_dst, 0o644)
                if brotli:
                    br_dst = "%s.br" % dst
                    if os.path.exists(br_dst):
                        os.unlink(br_dst)
                    #find brotli on $PATH
                    paths = os.environ.get("PATH", "").split(os.pathsep)
                    if os.name=="posix":
                        #not always present,
                        #but brotli is often installed there (install from source):
                        paths.append("/usr/local/bin")
                    for x in paths:
                        br = os.path.join(x, "brotli")
                        if sys.platform.startswith("win"):
                            br += ".exe"
                        if not os.path.exists(br):
                            continue
                        cmd = [br, "-k", dst]
                        code, out, err = get_status_output(cmd)
                        if code!=0:
                            print("brotli error code=%i on %s" % (code, cmd))
                            if out:
                                print("stdout=%s" % out)
                            if err:
                                print("stderr=%s" % err)
                        elif os.path.exists(br_dst):
                            os.chmod(br_dst, 0o644)
                            break
                        else:
                            print("Warning: brotli did not create '%s'" % br_dst)

    if os.name=="posix":
        try:
            from xpra.platform.paths import get_desktop_background_paths
        except ImportError as e:
            print("cannot locate desktop background: %s" % (e,))
        else:
            paths = get_desktop_background_paths()
            print("desktop background paths: %s" % (paths,))
            if paths:
                extra_symlinks = {"background.png" : paths}
                for f, symlink_options in extra_symlinks.items():
                    dst = os.path.join(install_dir, f)
                    install_symlink(symlink_options, dst)


def main():
    if "sdist" in sys.argv:
        record_vcs_info()
        from distutils.core import setup
        setup(name = "xpra-html5",
              version = "4.1",
              license = "MPL-2",
              author = "Antoine Martin",
              author_email = "antoine@xpra.org",
              url = "https://xpra.org/",
              download_url = "https://xpra.org/src/",
              description = "HTML5 client for xpra",
        ) 
        sys.exit(0)
    elif "install" in sys.argv:
        record_vcs_info()
        minifier = "yuicompressor" if sys.platform.startswith("win") else "uglifyjs"
        install_dir = os.path.join(sys.prefix, "share/xpra/www")
        if len(sys.argv)>=3:
            install_dir = sys.argv[2]
        if len(sys.argv)>=4:
            minifier = sys.argv[3]
        if len(sys.argv)>=5:
            print("invalid number of arguments: %i" % len(sys.argv))
            print("usage:")
            print("%s [installation-directory [minifier]]" % sys.argv[0])
            sys.exit(1)

        install_html5(install_dir, minifier)
        sys.exit(0)
    else:
        print("invalid arguments, use 'sdist' or 'install'")
        sys.exit(1)

if __name__ == "__main__":
    main()
