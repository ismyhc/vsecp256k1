import vsecp256k1

fn test_new() {
    ctx := vsecp256k1.create_context()!
    defer { ctx.destroy() }
    assert isnil(ctx) == false, 'context should not be nil'

    private_key := vsecp256k1.generate_private_key()!
    assert isnil(private_key) == false, 'context should not be nil'
    assert private_key.len == 32, 'private_key length should be 32'

    keypair := ctx.create_keypair(private_key)!
    assert isnil(keypair) == false, 'keypair should not be nil'

    x_pubkey, _ := ctx.create_xonly_pubkey(keypair)!
    assert isnil(x_pubkey) == false, 'x_pubkey should not be nil'

    x_pubkey_bytes := ctx.serialize_xonly_pubkey(x_pubkey)!
    assert isnil(x_pubkey_bytes) == false, 'x_pubkey_bytes should not be nil'
    assert x_pubkey_bytes.len == 32, 'x_pubkey_bytes length should be 32'

    message := 'Hello, Schnorr!'.bytes()
    signature := ctx.sign_schnorr(message, keypair)!
    assert isnil(signature) == false, 'signature should not be nil'

    is_valid := ctx.verify_schnorr(signature, message, x_pubkey)
    assert is_valid == true, 'signature should be valid'
}