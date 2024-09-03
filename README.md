# vsecp256k1 - V module that wraps libsecp256k1

This library currently wraps [libsecp256k1 v0.5.1](https://github.com/bitcoin-core/secp256k1) for use in V. It is a work in progress so take that into account.

#### To use this code, you need to install the following libraries:
- automake
- libtool

### MacOS
`brew install automake libtool`

### Ubuntu
`sudo apt-get install automake libtool`

### Fedora
`sudo dnf install automake libtool`

### CentOS
`sudo yum install automake libtool`

### Windows (Not tested)
- Download and install [MSYS2](https://www.msys2.org/)
- Open MSYS2 terminal and run the following command:
`pacman -S automake libtool`

### How to compile the C requirements:
- Navigate to where the module was installed
- Run the following commands:
`v run vsecp256k1/build.vsh`

This should compile the C code and generate the necessary files for the V module. You should only have to do this once.

### How to use the module:
 - TODO: Add examples
 - TODO: Add documentation
 - TODO: Add tests