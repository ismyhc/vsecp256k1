import vsecp256k1

fn test_new() {

    ctx := vsecp256k1.create_context()!
    defer { ctx.destroy() }

    private_key := vsecp256k1.generate_private_key()!
    eprintln('Created private key: ${private_key.hex()}')

    keypair := ctx.create_keypair(private_key)!
    x_pubkey, _ := ctx.create_xonly_pubkey(keypair)!
    x_pubkey_bytes := ctx.serialize_xonly_pubkey(x_pubkey)!
    eprintln('Created x-only public key: $x_pubkey_bytes.hex()')

    message := 'Hello, Schnorr!'.bytes()
    signature := ctx.sign_schnorr(message, keypair)!
    eprintln('Schnorr signature: ${signature.hex()}')

    is_valid := ctx.verify_schnorr(signature, message, x_pubkey)
    eprintln('Signature is valid: $is_valid')

}