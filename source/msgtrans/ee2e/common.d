module msgtrans.ee2e.common;

import msgtrans.ee2e.crypto;
import msgtrans.ee2e.message.MsgDefine;
import hunt.logging;
import msgtrans.MessageBuffer;
import std.string;
import google.protobuf;
import std.array;
import core.stdc.string;
import std.base64;

class common {

  static bool keyCalculate(ownkey_s ownkey, peerkey_s peerkey)
  {
      ubyte[CRYPTO_SALT_LEN] salt_xor;
      if (!bytes_xor(ownkey.salt, CRYPTO_SALT_LEN, peerkey.salt, CRYPTO_SALT_LEN, salt_xor))
      {
          logError("xor calculation error.");
          return false;
      }

      /* Calculate the shared key using own public and private keys and the public key of the other party */
      ubyte[CRYPTO_ECDH_SHARED_KEY_LEN] shared_key;
      if (!calc_ecdh_shared_key(ownkey.ec_pub_key, ownkey.ec_priv_key, peerkey.ec_pub_key, shared_key))
      {
          logError("shared key calculation error.");
          return false;
      }

      /* Using HKDF to calculate the final AES key */
      if (!generate_hkdf_bytes(shared_key, salt_xor, CRYPTO_KEY_INFO.representation, CRYPTO_KEY_INFO.length, peerkey.aes_key))
      {
          logError("hkdf calculation error.");
          return false;
      }

      logInfo("Calculated the final AES-KEY: %s",peerkey.aes_key);
      //dash::hex_dump(peerkey.aes_key, CRYPTO_AES_KEY_LEN, std::cout);

      return true;
  }

  static bool encrypt_plaintext(peerkey_s peerkey, ubyte[] str_plaintext, Ciphertext ciphertext)
  {
    ubyte[] str_ciphertext = new ubyte[str_plaintext.length];
    ubyte[] rand_iv = new ubyte[CRYPTO_AES_IV_LEN];
    ubyte[] aes_tag = new ubyte[CRYPTO_AES_TAG_LEN];


    if (!rand_salt(rand_iv, CRYPTO_AES_IV_LEN))
    {
        return false;
    }

    bool ret = aes_encrypt(str_plaintext.ptr, cast(int)str_plaintext.length, peerkey.aes_key.ptr, rand_iv.ptr, str_ciphertext.ptr, aes_tag.ptr);

    if (!ret)
    {
        return false;
    }


    ciphertext.cipher_version = cast(uint)str_plaintext.length;
    ciphertext.aes_iv_12bytes = Base64.encode(rand_iv);
    ciphertext.aes_tag_16bytes = Base64.encode(aes_tag);
    ciphertext.ciphertext_nbytes = Base64.encode(str_ciphertext);

    logInfo("cipher_version %s",  ciphertext.cipher_version);
    logInfo("aes_iv_12bytes %s",  rand_iv);
    logInfo("aes_tag_16bytes %s",  aes_tag);
    logInfo("ciphertext_nbytes %s",  str_ciphertext);
    logInfo("aes key:" ,peerkey.aes_key);

    return true;
  }

  static bool generate_token(const ubyte[CRYPTO_EC_PUB_KEY_LEN] ecdh_pub_key, Token token)
  {
      ubyte[] random_digit = new ubyte[3];
      ubyte[] hmac_256 = new ubyte[CRYPTO_HMAC_SHA256];


      if (!rand_salt(random_digit, 3))
      {
          logError("random digit generation error.");
          return false;
      }

      if (!hmac_sha256(hmac_256, random_digit, 3, ecdh_pub_key, CRYPTO_EC_PUB_KEY_LEN))
      {
          logError("hmac calculation error.");
          return false;
      }

      token.salt_3bytes = Base64.encode(random_digit);
      token.hmac_3bytes = Base64.encode(hmac_256);

      logInfo("token.salt_3bytes  %s",random_digit);
      logInfo("token.salt_3bytes  %s",token.salt_3bytes);
      logInfo("token.hmac_3bytes  %s",token.hmac_3bytes);

      return true;
  }

  static bool verify_token(const ubyte[CRYPTO_EC_PUB_KEY_LEN] ecdh_pub_key, Token token)
  {
      ubyte[] hmac_256 = new ubyte[CRYPTO_HMAC_SHA256];
      ubyte[] dd = Base64.decode(token.salt_3bytes);

    //  logInfo("dd  %s    %d",dd ,cast(uint)token.salt_3bytes.length);
      bool ret = hmac_sha256(hmac_256, Base64.decode(token.salt_3bytes), 3, ecdh_pub_key, CRYPTO_EC_PUB_KEY_LEN);
      if (!ret)
      {
          logError("hmac calculation error.");
          return false;
      }

      logInfo("hmac_256  %s",hmac_256);
      logInfo("hmac_3bytes  %s",token.hmac_3bytes);
      logInfo("salt_3bytes  %s",token.salt_3bytes);

      if (0 != memcmp(Base64.decode(token.hmac_3bytes).ptr, hmac_256.ptr, 3))
      {
          logError("Token check failed");
          return false;
      }

      return true;
  }

  static MessageBuffer encrypted_encode(MessageBuffer message ,ownkey_s client_key , peerkey_s server_key)
  {
      Ciphertext ciphertext = new Ciphertext;
      Token token = new Token;
      token.salt_3bytes = "1";
      token.hmac_3bytes = "1";
      EncryptedRequest encrypted_request = new EncryptedRequest;
      if(!encrypt_plaintext(server_key, message.data, ciphertext))
      {
        logError ("aes encryption error.");
        return null;
      }
      if(client_key !is null)
      {
        if (!common.generate_token(client_key.ec_pub_key, token))
        {
          logError("token generation error.");
          return null;
        }
      }
      logInfo("out  salt_3bytes  %s",token.salt_3bytes);
      logInfo("out  hmac_3bytes  %s",token.hmac_3bytes);
      encrypted_request.token = token;
      encrypted_request.ciphertext = ciphertext;
      logInfo("encrypted_request %s",encrypted_request.toProtobuf.array);
      if (message.extendLength > 0)
      {
        return new MessageBuffer(message.id , encrypted_request.toProtobuf.array, message.tagId);
      }else
      {
        return new MessageBuffer(message.id , encrypted_request.toProtobuf.array);
      }
  }

  static MessageBuffer encrypted_decode(MessageBuffer message, peerkey_s peer_key, bool isClient = false)
  {
      logInfo("encrypted_decode id: %s" ,message.id);
      EncryptedRequest encrypted_request = new EncryptedRequest;
      message.data.fromProtobuf!EncryptedRequest(encrypted_request);

      if(!isClient)
      {
        if (!common.verify_token(peer_key.ec_pub_key, encrypted_request.token))
        {
          logError("token check failed.");
          return null;
        }
      }

      logInfo("============================================================================");
      logInfo("msgId :%d" , message.id);
      logInfo("cipher_version %s" , encrypted_request.ciphertext.cipher_version);
      logInfo("base64 ciphertext_nbytes %s", encrypted_request.ciphertext.ciphertext_nbytes);
      logInfo("base64 aes_tag_16bytes %s", encrypted_request.ciphertext.aes_tag_16bytes);
      logInfo("base64 aes_iv_12bytes %s", encrypted_request.ciphertext.aes_iv_12bytes);


      //uint len = encrypted_request.ciphertext.ciphertext_nbytes.length;
      uint len = encrypted_request.ciphertext.cipher_version;
      ubyte[] ciphertext_nbytes = Base64.decode(encrypted_request.ciphertext.ciphertext_nbytes);
      ubyte[] plaintext = new ubyte[len];

      logInfo("ciphertext_nbytes %s", ciphertext_nbytes);

      ubyte[] aes_tag_16bytes = Base64.decode(encrypted_request.ciphertext.aes_tag_16bytes);

      logInfo("aes_tag_16bytes %s", aes_tag_16bytes);
      if(len != 0)
      {
          bool ret = aes_decrypt(ciphertext_nbytes.ptr,
          len,
          aes_tag_16bytes.ptr,
          peer_key.aes_key.ptr,
          Base64.decode(encrypted_request.ciphertext.aes_iv_12bytes).ptr, plaintext.ptr);
          if (!ret)
          {
            logError("aes decryption error");
            return null;
          }
      }


      logInfo("aes_iv_12bytes %s", Base64.decode(encrypted_request.ciphertext.aes_iv_12bytes));

      logInfo("peer_key.aes_key.ptr  %s" ,peer_key.aes_key);


      if (message.extendLength > 0 )
      {
        return new MessageBuffer(message.id , plaintext,message.tagId);
      }else
      {
        return new MessageBuffer(message.id , plaintext);
      }

  }

}

