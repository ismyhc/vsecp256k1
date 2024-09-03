# vsecp256k1 - V module that wraps libsecp256k1

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

This should compile the C code and generate the necessary files for the V module.

### How to use the module:
 - TODO: Add examples