import vsecp256k1

fn test_new() {

    ctx := vsecp256k1.create_context(vsecp256k1.context_sign | vsecp256k1.context_verify)!
    defer { ctx.destroy() }

    private_key := vsecp256k1.generate_private_key()!
    println('Created private key: ${private_key.hex()}')

    keypair := ctx.create_keypair(private_key)!
    x_pubkey, _ := ctx.create_xonly_pubkey(keypair)!
    x_pubkey_bytes := ctx.serialize_xonly_pubkey(x_pubkey)!
    println('Created x-only public key: $x_pubkey_bytes.hex()')

    nsec_hrp := 'nsec'
    nsec := vsecp256k1.encode_from_base256(nsec_hrp, private_key) or {
        println('Encoding failed: $err')
        return
    }
    println('Bech32 encoded private key: $nsec')

    npub_hrp := 'npub'
    npub := vsecp256k1.encode_from_base256(npub_hrp, x_pubkey_bytes) or {
        println('Encoding failed: $err')
        return
    }
    println('Bech32 encoded public key: $npub')

    message := 'Hello, Schnorr!'.bytes()
    signature := ctx.sign_schnorr(message, keypair)!
    println('Schnorr signature: ${signature.hex()}')

    is_valid := ctx.verify_schnorr(signature, message, x_pubkey)
    println('Signature is valid: $is_valid')
}