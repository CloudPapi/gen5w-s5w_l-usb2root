#!/usr/bin/env python3
import hashlib, sys
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

KEY = bytes.fromhex("60a93d70f73302a63e5ed0d0ea38be22")
OUT = "VarUpgrade"

data = open(sys.argv[1], "rb").read()
size = len(data)
pad_len = -size % 16
size32 = (size + 2**31) % 2**32 - 2**31  # size as signed int32
iv = hashlib.sha256(f"{OUT}{size32}".encode()).digest()[:16]

enc = Cipher(algorithms.AES(KEY), modes.CBC(iv)).encryptor()
ct = enc.update(data + bytes(pad_len)) + enc.finalize()

# 0x4024-byte trailer: magic | unused | sha256 | spilled cipher bytes | zeros
meta = bytearray(0x4024)
meta[:3] = b"TER"
meta[36:36 + pad_len] = ct[size:]
meta[4:36] = hashlib.sha256(iv + meta[36:]).digest()

with open(OUT, "wb") as f:
    f.write(ct[:size] + meta)
