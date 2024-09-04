import vsecp256k1

fn test_create_private_key() {

    ctx := vsecp256k1.create_context()!
    defer { ctx.destroy() }

    private_key := vsecp256k1.generate_private_key()!
	assert private_key.len == 32, 'private_key length should be 32'

}