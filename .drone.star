# Use, modification, and distribution are
# subject to the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# Copyright Rene Rivera 2020.

# Configuration for https://cloud.drone.io/.

def main(ctx):
  return [
    linux_cxx("GCC 9", "g++-9", packages="g++-9"),
    linux_cxx("GCC 8", "g++-8", packages="g++-8"),
    linux_cxx("Clang 9", "clang-9", packages="clang-9", llvm_os="bionic", llvm_ver="9", image="ubuntu:18.04"),
    linux_cxx("Clang 8", "clang-8", packages="clang-8", llvm_os="bionic", llvm_ver="8", image="ubuntu:18.04")
  ]

# Generate pipeline for Linux platform compilers.
def linux_cxx(name, cxx, cxxflags="", packages="", llvm_os="", llvm_ver="", arch="amd64", image="ubuntu:18.04"):
  return {
    "name": "Linux %s" % name,
    "kind": "pipeline",
    "type": "docker",
    "trigger": { "branch": [ "master" ] },
    "platform": {
      "os": "linux",
      "arch": arch
    },
    # Create env vars per generation arguments.
    "environment": {
      "CXX": cxx,
      "CXXFLAGS": cxxflags,
      "PACKAGES": packages,
      "LLVM_OS": llvm_os,
      "LLVM_VER": llvm_ver
    },
    "steps": [
      {
        "name": "Everything",
        "image": image,
        "commands": [
          # Need some extra container setup.
          "echo '==================================> SETUP'",
          "apt-get update && apt-get install -y sudo software-properties-common wget apt-transport-https && rm -rf /var/lib/apt/lists/*",
          # The install runs a helper script to do the install and any setup.
          "echo '==================================> INSTALL TOOLSET'",
          "uname -a",
          "./.ci_playground/linux-cxx-install.sh",
          # And the compiler step just calls the compiler.
          "echo '==================================> COMPILE'",
          "$${CXX} --version",
          "$${CXX} $${CXXFLAGS} -v src/main.cpp"
        ]
      }
    ]
  }
