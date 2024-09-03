#!/usr/bin/env -S v run

import net.http
import crypto.sha256

// https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
const secp256k1_version = 'v0.5.1' // Update this to the desired version
const secp256k1_dir = @VMODROOT + '/secp256k1'
const secp256k1_zip_url = 'https://github.com/bitcoin-core/secp256k1/archive/refs/tags/${secp256k1_version}.zip'
const secp256k1_zip_file = @VMODROOT + '/secp256k1.zip'
const secp256k1_hash = '000baf23eba2566b3737a227a6ab46f53719984fe9877fd875726b588446b808'

fn download_file(url string, filepath string) ! {
	resp := http.get(url)!
	if resp.status_code != 200 {
		return error('Failed to download file: ${resp.status_code}')
	}
	write_file(filepath, resp.body)!
}

fn verify_sha256(filepath string, expected_hash string) ! {
	file_content := read_file(filepath)!
	actual_hash := sha256.sum(file_content.bytes()).hex()
	if actual_hash != expected_hash {
		return error('SHA256 verification failed. Expected: $expected_hash, Actual: $actual_hash')
	}
}

fn cleanup_dir(dir string) ! {
    if !exists(dir) || !is_dir(dir) {
        return error('Invalid directory: $dir')
    }

    items := ls(dir) or { return error('Failed to list directory contents: $dir') }

    for item in items {
        if item in ['.libs', 'include'] {
            continue // Skip these folders
        }

        full_path := join_path(dir, item)

        if is_dir(full_path) {
            rmdir_all(full_path) or { return error('Failed to remove directory: $full_path') }
        } else {
            rm(full_path) or { return error('Failed to remove file: $full_path') }
        }
    }
}

fn main() {
	if !exists(secp256k1_dir) {
		println('Downloading libsecp256k1...')
		download_file(secp256k1_zip_url, secp256k1_zip_file)!

		verify_sha256(secp256k1_zip_file, secp256k1_hash)!

		println('Extracting libsecp256k1...')
		execute('unzip ${secp256k1_zip_file} -d ${@VMODROOT}')
		mv(@VMODROOT + '/secp256k1-' + secp256k1_version.trim_left('v'), secp256k1_dir)!
		rm(secp256k1_zip_file)!
	}

	chdir(secp256k1_dir)!

	println('Running autogen.sh...')
	system('./autogen.sh')

	println('Configuring libsecp256k1...')
	system('./configure --disable-shared --enable-module-recovery --enable-module-schnorrsig')

	println('Building libsecp256k1...')
	system('make -j4')

	chdir(@VMODROOT)!

	println('Cleaning up unnecessary files...')
	cleanup_dir(secp256k1_dir)!

	println('Build completed successfully!')
	println("Running tests...")
	system('v test .')
	println('\nYou should be good to go. Take a look at the README.md for usage instructions.')	
}
