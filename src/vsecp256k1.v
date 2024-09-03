module vsecp256k1

import crypto.rand
import crypto.sha256

#flag @VMODROOT/secp256k1/.libs/libsecp256k1.a
#flag -I@VMODROOT/secp256k1/include
#flag -I@VMODROOT/secp256k1/

#include "secp256k1.h"
#include "secp256k1_extrakeys.h"
#include "secp256k1_schnorrsig.h"

@[typedef]
struct C.secp256k1_context {}

@[typedef]
struct C.secp256k1_pubkey {}

@[typedef]
struct C.secp256k1_ecdsa_signature {}

@[typedef]
struct C.secp256k1_xonly_pubkey {}

@[typedef]
struct C.secp256k1_keypair {}

fn C.secp256k1_context_create(u32) &C.secp256k1_context
fn C.secp256k1_context_destroy(&C.secp256k1_context)
fn C.secp256k1_ec_seckey_verify(&C.secp256k1_context, &u8) int
fn C.secp256k1_ec_pubkey_create(&C.secp256k1_context, &C.secp256k1_pubkey, &u8) int
fn C.secp256k1_ecdsa_sign(&C.secp256k1_context, &C.secp256k1_ecdsa_signature, &u8, &u8, voidptr, voidptr) int
fn C.secp256k1_keypair_create(&C.secp256k1_context, &C.secp256k1_keypair, &u8) int
fn C.secp256k1_keypair_xonly_pub(&C.secp256k1_context, &C.secp256k1_xonly_pubkey, &int, &C.secp256k1_keypair) int
fn C.secp256k1_xonly_pubkey_serialize(&C.secp256k1_context, &u8, &C.secp256k1_xonly_pubkey) int
fn C.secp256k1_schnorrsig_sign32(&C.secp256k1_context, &u8, &u8, &C.secp256k1_keypair, &u8) int
fn C.secp256k1_schnorrsig_verify(&C.secp256k1_context, &u8, &u8, int, &C.secp256k1_xonly_pubkey) int

pub const (
    context_verify = u32(C.SECP256K1_CONTEXT_VERIFY)
    context_sign   = u32(C.SECP256K1_CONTEXT_SIGN)
)

pub struct Context {
    ctx &C.secp256k1_context
}

pub struct KeyPair {
    keypair C.secp256k1_keypair
}

pub fn create_context(flags u32) !&Context {
    ctx := C.secp256k1_context_create(flags)
    if isnil(ctx) {
        return error('Failed to create secp256k1 context')
    }
    return &Context{ctx}
}

pub fn (c &Context) destroy() {
    C.secp256k1_context_destroy(c.ctx)
}

pub fn generate_private_key() ![]u8 {
    for {
        private_key := rand.bytes(32)!
        if C.secp256k1_ec_seckey_verify(0, private_key.data) == 1 {
            return private_key
        }
    }
    return error('Failed to generate valid private key')
}

pub fn (c &Context) create_keypair(seckey []u8) !KeyPair {
    mut keypair := KeyPair{}
    if C.secp256k1_keypair_create(c.ctx, &keypair.keypair, seckey.data) != 1 {
        return error('Failed to create keypair')
    }
    return keypair
}

pub fn (c &Context) create_xonly_pubkey(keypair KeyPair) !(&C.secp256k1_xonly_pubkey, bool) {
    mut pubkey := &C.secp256k1_xonly_pubkey{}
    mut pk_parity := 0
    if C.secp256k1_keypair_xonly_pub(c.ctx, pubkey, &pk_parity, &keypair.keypair) != 1 {
        return error('Failed to create x-only public key')
    }
    return pubkey, pk_parity == 1
}

pub fn (c &Context) serialize_xonly_pubkey(pubkey &C.secp256k1_xonly_pubkey) ![]u8 {
    mut serialized := []u8{len: 32}
    if C.secp256k1_xonly_pubkey_serialize(c.ctx, serialized.data, pubkey) != 1 {
        return error('Failed to serialize x-only public key')
    }
    return serialized
}

pub fn (c &Context) sign_schnorr(msg []u8, keypair KeyPair) ![]u8 {
    msg_hash := sha256.sum(msg)
    mut sig := []u8{len: 64}
    if C.secp256k1_schnorrsig_sign32(c.ctx, sig.data, msg_hash.data, &keypair.keypair, 0) != 1 {
        return error('Failed to create Schnorr signature')
    }
    return sig
}

pub fn (c &Context) verify_schnorr(sig []u8, msg []u8, pubkey &C.secp256k1_xonly_pubkey) bool {
    msg_hash := sha256.sum(msg)
    return C.secp256k1_schnorrsig_verify(c.ctx, sig.data, msg_hash.data, 32, pubkey) == 1
}