import vsecp256k1

fn test_context_creation() {
	ctx := vsecp256k1.create_context() or {
		assert false, 'Failed to create context: ${err}'
		return
	}
	defer { ctx.destroy() }
	assert !isnil(ctx), 'Context should not be nil'
}

fn test_private_key_generation() {
	private_key := vsecp256k1.generate_private_key() or {
		assert false, 'Failed to generate private key: ${err}'
		return
	}
	assert private_key.len == 32, 'Private key length should be 32 bytes'
	assert private_key != []u8{len: 32, init: 0}, 'Private key should not be all zeros'
}

fn test_keypair_creation() {
	ctx := vsecp256k1.create_context()!
	defer { ctx.destroy() }
	private_key := vsecp256k1.generate_private_key()!

	keypair := ctx.create_keypair(private_key) or {
		assert false, 'Failed to create keypair: ${err}'
		return
	}
	assert !isnil(keypair), 'Keypair should not be nil'
}

fn test_xonly_pubkey_creation_and_serialization() {
	ctx := vsecp256k1.create_context()!
	defer { ctx.destroy() }
	private_key := vsecp256k1.generate_private_key()!
	keypair := ctx.create_keypair(private_key)!

	x_pubkey := ctx.create_xonly_pubkey_from_keypair(keypair) or {
		assert false, 'Failed to create xonly pubkey: ${err}'
		return
	}
	assert !isnil(x_pubkey), 'Xonly pubkey should not be nil'

	x_pubkey_bytes := ctx.serialize_xonly_pubkey(x_pubkey) or {
		assert false, 'Failed to serialize xonly pubkey: ${err}'
		return
	}
	assert x_pubkey_bytes.len == 32, 'Serialized xonly pubkey should be 32 bytes'
}

fn test_schnorr_signing_and_verification() {
	ctx := vsecp256k1.create_context()!
	defer { ctx.destroy() }
	private_key := vsecp256k1.generate_private_key()!
	keypair := ctx.create_keypair(private_key)!
	x_pubkey := ctx.create_xonly_pubkey_from_keypair(keypair)!

	message := 'Hello, Schnorr!'.bytes()
	signature := ctx.sign_schnorr(message, keypair) or {
		assert false, 'Failed to sign message: ${err}'
		return
	}
	assert signature.len == 64, 'Schnorr signature should be 64 bytes'

	is_valid := ctx.verify_schnorr(signature, message, x_pubkey)
	assert is_valid, 'Signature should be valid'

	// Test with wrong message
	wrong_message := 'Wrong message'.bytes()
	is_invalid := ctx.verify_schnorr(signature, wrong_message, x_pubkey)
	assert !is_invalid, 'Signature should be invalid for wrong message'
}

fn test_error_conditions() {
	ctx := vsecp256k1.create_context()!
	defer { ctx.destroy() }

	// Test with invalid private key
	invalid_private_key := []u8{len: 31, init: 0} // Too short
	keypair_result := ctx.create_keypair(invalid_private_key) or {
		assert err.msg() != '', 'Should fail with invalid private key'
		return
	}
	assert false, 'Should have failed with invalid private key'

	// Test with invalid message length for signing
	valid_keypair := ctx.create_keypair(vsecp256k1.generate_private_key()!)!
	invalid_message := []u8{len: 33, init: 0} // secp256k1 expects 32-byte message
	sign_result := ctx.sign_schnorr(invalid_message, valid_keypair) or {
		assert err.msg() != '', 'Should fail with invalid message length'
		return
	}
	assert false, 'Should have failed with invalid message length'
}
