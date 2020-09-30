module msgtrans.ee2e.crypto;

import hunt.logging;
import deimos.openssl.ssl;
import deimos.openssl.rand;
import deimos.openssl.aes;
import deimos.openssl.evp;
import core.stdc.string;

enum CRYPTO_CURVE_NID = NID_X9_62_prime256v1;

enum  CRYPTO_EC_PUB_KEY_LEN = 65;

enum  CRYPTO_EC_PRIV_KEY_LEN = 32;

enum  CRYPTO_SALT_LEN = 32;

enum  CRYPTO_ECDH_SHARED_KEY_LEN = 32;

enum  CRYPTO_HMAC_SHA256 = 32;

enum  CRYPTO_AES_KEY_LEN = 32;

enum  CRYPTO_AES_IV_LEN = 12;

enum  CRYPTO_AES_TAG_LEN = 16;

enum  CRYPTO_ECDSA_SIG_s_LEN = 32;

enum  CRYPTO_ECDSA_SIG_r_LEN = 32;

enum  CRYPTO_ECDSA_SIG_LEN = CRYPTO_ECDSA_SIG_s_LEN + CRYPTO_ECDSA_SIG_r_LEN;

enum  CRYPTO_VERSION = 1;

enum  CRYPTO_KEY_INFO = "ENCRYPTION";


class ownkey_s
{
    ubyte[CRYPTO_EC_PUB_KEY_LEN] ec_pub_key;
    ubyte[CRYPTO_EC_PRIV_KEY_LEN] ec_priv_key;
    ubyte[CRYPTO_SALT_LEN] salt;
}

class peerkey_s
{
    ubyte[CRYPTO_EC_PUB_KEY_LEN] ec_pub_key;
    ubyte[CRYPTO_AES_KEY_LEN] aes_key;
    ubyte[CRYPTO_SALT_LEN] salt;
}

bool rand_salt(ubyte[] salt, int bytes)
{
  return (RAND_bytes(salt.ptr, bytes)==1);
}

bool generate_ecdh_keys(out ubyte[CRYPTO_EC_PUB_KEY_LEN] ecdh_public_key, out ubyte[CRYPTO_EC_PRIV_KEY_LEN] ecdh_private_key)
{
    size_t len = 0;
    bool ret = false;

    const(EC_KEY) *ecdh = EC_KEY_new();
    const(EC_POINT) *point = null;
    const(EC_GROUP) *group = null;

  //Generate Public
    ecdh = EC_KEY_new_by_curve_name(CRYPTO_CURVE_NID);

    group = EC_KEY_get0_group(ecdh);

  /* get x y */
    if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field)
    {
      if (!EC_KEY_generate_key(cast(EC_KEY*)ecdh))
      {
        logError("Ecdh NIST P-256 generate error.");
        goto err;
      }

      point = EC_KEY_get0_public_key(ecdh);

      len = EC_POINT_point2oct(group, point, point_conversion_form_t.POINT_CONVERSION_UNCOMPRESSED, ecdh_public_key.ptr, cast(size_t)CRYPTO_EC_PUB_KEY_LEN , null);
      if (len != CRYPTO_EC_PUB_KEY_LEN)
      {
        logError("Ecdh NIST P-256 public key get error.");
        goto err;
      }

      len = BN_bn2bin(EC_KEY_get0_private_key(ecdh), ecdh_private_key.ptr);
      if (len != CRYPTO_EC_PRIV_KEY_LEN)
      {
        logError("Ecdh NIST P-256 private key get error.");
        goto err;
      }

      ret = true;
    }

    err:
    EC_KEY_free(cast(EC_KEY*)ecdh);
    return ret;
}

bool calc_ecdh_shared_key(const ubyte[CRYPTO_EC_PUB_KEY_LEN] ecdh1_public_key,
                          const ubyte[CRYPTO_EC_PRIV_KEY_LEN] ecdh1_private_key,
                          const ubyte[CRYPTO_EC_PUB_KEY_LEN] ecdh2_public_key,
                          out ubyte[CRYPTO_ECDH_SHARED_KEY_LEN] ecdh_shared_key)
{
    int len = 0;
    int ret = false;
    EC_KEY *ecdh = EC_KEY_new();
    const(EC_GROUP) *group = null;
    BIGNUM   *priv = null;
    EC_POINT *p_ecdh1_public = null;
    EC_POINT *p_ecdh2_public = null;

    ecdh = EC_KEY_new_by_curve_name(CRYPTO_CURVE_NID);
    if (ecdh is null)
    {
      logError("Ecdh key by curve name error.");
      goto err;
    }

    group = EC_KEY_get0_group(ecdh);

    if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field)
    {
      /* 1==> Set ecdh1's public and privat key. */
      p_ecdh1_public = EC_POINT_new(group);
      if (p_ecdh1_public is null)
      {
        logError("EC_POINT new error.");
        goto err;
      }

      ret = EC_POINT_oct2point(group, p_ecdh1_public, ecdh1_public_key.ptr, CRYPTO_EC_PUB_KEY_LEN, null);
      if (!ret)
      {
        logError("EC_POINT oct2point error.");
        goto err;
      }

      if (!EC_KEY_set_public_key(ecdh, p_ecdh1_public))
      {
        logError("Ecdh set public key error.");
      }

      priv = BN_bin2bn(ecdh1_private_key.ptr, CRYPTO_EC_PRIV_KEY_LEN, null);
      if (!EC_KEY_set_private_key(ecdh, priv))
      {
        logError("set private error \n");
      }
      /*-------------*/

      /* 2==> Set ecdh2's public key */
      p_ecdh2_public = EC_POINT_new(group);
      if (p_ecdh2_public is null)
      {
        logError("EC_POINT new error.");
        goto err;
      }

      ret = EC_POINT_oct2point(group, p_ecdh2_public, ecdh2_public_key.ptr, CRYPTO_EC_PUB_KEY_LEN, null);
      if (!ret)
      {
        logError("EC_POINT oct2point error.");
        goto err;
      }

      if (!EC_KEY_set_public_key(ecdh, p_ecdh2_public))
      {
        logError("Ecdh set public key error.");
        goto err;
      }
      /*------------*/

      /* 3==> Calculate the shared key of ecdh1 and ecdh2 */
      len = ECDH_compute_key(ecdh_shared_key.ptr, CRYPTO_ECDH_SHARED_KEY_LEN, p_ecdh2_public, ecdh, null);
      if (len != CRYPTO_ECDH_SHARED_KEY_LEN)
      {
        logError("Ecdh compute key error.");
        goto err;
      }

      ret = 0;
    }

    err:
    if (priv)
      BN_free(priv);
    if (ecdh)
      EC_KEY_free(ecdh);
    if (p_ecdh1_public)
      EC_POINT_free(p_ecdh1_public);
    if (p_ecdh2_public)
      EC_POINT_free(p_ecdh2_public);

    return (ret==0);
}

bool ecdsa_sign(const ubyte[CRYPTO_EC_PRIV_KEY_LEN] ec_private_key, ubyte *hash, ubyte hash_len, ubyte[CRYPTO_ECDSA_SIG_LEN] sign)
{
    int len = 0;
    int ret = false;
    EC_KEY *eckey = EC_KEY_new();
    BIGNUM   *priv = null;
    const (EC_GROUP) *group = null;
    EC_POINT *p_ec_point = null;

    eckey = EC_KEY_new_by_curve_name(CRYPTO_CURVE_NID);
    if (eckey is null)
    {
      logError("Ecdh key by curve name error.");
      goto err;
    }

    group = EC_KEY_get0_group(eckey);

    if (EC_METHOD_get_field_type(EC_GROUP_method_of(group)) == NID_X9_62_prime_field)
    {
        priv = BN_bin2bn(ec_private_key.ptr,CRYPTO_EC_PRIV_KEY_LEN, null);
        if (!EC_KEY_set_private_key(eckey, priv))
        {
          logError("set private error \n");
        }

        ECDSA_SIG *signature = ECDSA_do_sign(hash, hash_len, eckey);
        if (signature is null)
        {
          logError("ECDSA_do_sign error.");
          goto err;
        }

        ret = 0;

        BN_bn2bin(signature.s, sign.ptr);
        BN_bn2bin(signature.r, sign.ptr + CRYPTO_ECDSA_SIG_s_LEN);

        ECDSA_SIG_free(signature);
    }
err:
if (priv)
  BN_free(priv);
    if (eckey)
      EC_KEY_free(eckey);

    return (ret == 0);
}


bool hmac_sha256(ubyte[] hmac, const ubyte[] key, uint key_len, const ubyte[] data, uint data_len)
{
    uint resultlen = 0;
    HMAC(EVP_sha256(), key.ptr, key_len, data.ptr, data_len, hmac.ptr, &resultlen);
    logInfo("hmac_sha256 .............................. %s",hmac);
    if (resultlen != CRYPTO_HMAC_SHA256)
    {
      logError("HMAC SHA-256 error.");
      return false;
    }

    return true;
}

bool bytes_xor(const ubyte[] data1, int data1_len, const ubyte[] data2, int data2_len, ubyte[] m_out)
{
    int i = 0;

    if ((data1_len != data2_len) || (m_out is null))
        return false;

    for (i = 0; i < data1_len; i ++)
    {
       m_out[i] = data1[i] ^ data2[i];
    }

    return true;
}

bool generate_hkdf_bytes(const ubyte[CRYPTO_ECDH_SHARED_KEY_LEN] ecdh_shared_key,const ubyte[CRYPTO_SALT_LEN] salt, const ubyte[] info, int info_len, ubyte[] m_out)
{
    const EVP_MD *md = EVP_sha256();
    ubyte[CRYPTO_ECDH_SHARED_KEY_LEN] prk ;
    ubyte[CRYPTO_ECDH_SHARED_KEY_LEN] T ;
    ubyte[CRYPTO_AES_KEY_LEN] tmp;
    uint outlen = CRYPTO_ECDH_SHARED_KEY_LEN;
    int i, ret, tmplen;
    ubyte *p;
    /*extract is a simple HMAC...
      Note:salt should be treated as hmac key and ikm should be treated as data
     */
    if (!HMAC(md, salt.ptr, CRYPTO_SALT_LEN, ecdh_shared_key.ptr, CRYPTO_ECDH_SHARED_KEY_LEN, prk.ptr, &outlen))
      return false;
    ret = CRYPTO_AES_KEY_LEN/CRYPTO_ECDH_SHARED_KEY_LEN + !!(CRYPTO_AES_KEY_LEN%CRYPTO_ECDH_SHARED_KEY_LEN);

    tmplen = outlen;
    for (i = 0; i < ret; i++)
    {
        p = tmp.ptr;

        /*T(0) = empty string (zero length)*/
        if (i != 0)
        {
          memcpy(p, T.ptr, CRYPTO_ECDH_SHARED_KEY_LEN);
          p += CRYPTO_ECDH_SHARED_KEY_LEN;
        }

        memcpy(p, info.ptr, info_len);
        p += info_len;
        *p++ = cast(ubyte)(i + 1);

        HMAC(md, prk.ptr, CRYPTO_ECDH_SHARED_KEY_LEN, tmp.ptr, cast(int)(p - tmp.ptr), T.ptr, &outlen);
        memcpy(m_out.ptr + i*CRYPTO_ECDH_SHARED_KEY_LEN, T.ptr, tmplen < CRYPTO_ECDH_SHARED_KEY_LEN ? tmplen:CRYPTO_ECDH_SHARED_KEY_LEN);
        tmplen -= CRYPTO_ECDH_SHARED_KEY_LEN;
    }

    return true;
}


bool aes_encrypt(const ubyte *plaintext, int plaintext_len, const ubyte *key, const ubyte *iv, ubyte *ciphertext, ubyte *tag)
{
    EVP_CIPHER_CTX *ctx;

    int len;

    int ciphertext_len;

    int ret = -1;


    /* Create and initialise the context */
    ctx = EVP_CIPHER_CTX_new();
    if (ctx is null)
    {
      goto err;
    }


    /* Initialise the encryption operation. */
    if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), null, null, null))
      goto err;

    /* Set IV length if default 12 bytes (96 bits) is not appropriate */
    //if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 12, null))
    //   goto err;

    /* Initialise key and IV */
    if(1 != EVP_EncryptInit_ex(ctx, null, null, key, iv))  goto err;

    /* Provide any AAD data. This can be called zero or more times as
       * required
       */
    //if(1 != EVP_EncryptUpdate(ctx, null, &len, aad, aad_len))
    //   handleErrors();

    /* Provide the message to be encrypted, and obtain the encrypted output.
       * EVP_EncryptUpdate can be called multiple times if necessary
       */
    if(1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len))
    {
      goto err;
    }
    ciphertext_len = len;

    /* Finalise the encryption. Normally ciphertext bytes may be written at
       * this stage, but this does not occur in GCM mode
       */
    if(1 != EVP_EncryptFinal_ex(ctx, ciphertext, &len))  goto err;
    //ciphertext_len += len;

    /* Get the tag */
    if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, tag))
      goto err;

    err:
    /* Clean up */
    EVP_CIPHER_CTX_free(ctx);

    return (ciphertext_len == plaintext_len);
}

bool aes_decrypt(const ubyte *ciphertext, int ciphertext_len, const ubyte *tag, const ubyte *key, const ubyte *iv, ubyte *plaintext)
{
    EVP_CIPHER_CTX *ctx;
    int len;
    int plaintext_len;
    int ret = -1;

    /* Create and initialise the context */
    ctx = EVP_CIPHER_CTX_new();
    if(ctx is null)
    {
      goto err;
    }

    /* Initialise the decryption operation. */
    if(!EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), null, null, null))
        goto err;

    /* Set IV length. Not necessary if this is 12 bytes (96 bits) */
    //if(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 12, null))
    //    goto err;

    /* Initialise key and IV */
    if(!EVP_DecryptInit_ex(ctx, null, null, key, iv)) goto err;

    /* Provide any AAD data. This can be called zero or more times as
     * required
     */
    //if(!EVP_DecryptUpdate(ctx, null, &len, aad, aad_len))
    //    handleErrors();

    /* Provide the message to be decrypted, and obtain the plaintext output.
     * EVP_DecryptUpdate can be called multiple times if necessary
     */
    if(!EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len))
        goto err;
    plaintext_len = len;

    /* Set expected tag value. Works in OpenSSL 1.0.1d and later */
    if(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, cast(void*)tag))
        goto err;

    /* Finalise the decryption. A positive return value indicates success,
     * anything else is a failure - the plaintext is not trustworthy.
     */
    ret = EVP_DecryptFinal_ex(ctx, plaintext, &len);
    //plaintext_len = len;

    //CRYPTO_DBG("ret:%d", ret);
err:
    /* Clean up */
    EVP_CIPHER_CTX_free(ctx);

    if(ret > 0)
    {
        /* Success */
        return (plaintext_len == ciphertext_len);
    }
    else
    {
        /* Verify failed */
        return false;
    }
}
