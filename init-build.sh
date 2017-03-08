#!/bin/sh

dumptext() {
    cat <<EOF
#!/bin/sh

source ~/env/init-build/build.sh

CONFIGURATION=Release
ARCHITECTURE=x64
ACTION=Build
SOLUTION=*.sln

# deploy() {
#     true
# }
#
# other functions: prebuild, postbuild, error

build
EOF
}

dumptext > make.sh
