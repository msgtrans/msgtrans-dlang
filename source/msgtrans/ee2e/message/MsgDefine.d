module msgtrans.ee2e.message.MsgDefine;

import google.protobuf;

enum KeyExchangeType {
  UNKNOWN_REQUEST_TYPE   =  0,
  KEY_EXCHANGE_INITIATE   = 1,
  KEY_EXCHANGE_FINALIZE   = 2
}

class KeyInfo {
  @Proto(1) string salt_32bytes = protoDefaultValue!(string);
  @Proto(2) string ec_public_key_65bytes = protoDefaultValue!(string);
}

class KeyExchangeRequest
{
  @Proto(1) KeyExchangeType key_exchange_type = protoDefaultValue!KeyExchangeType;
  @Proto(2) KeyInfo key_info = protoDefaultValue!KeyInfo;
}

class Token {
  @Proto(1) string salt_3bytes  = protoDefaultValue!(string);  // random at each request
  @Proto(2) string hmac_3bytes  = protoDefaultValue!(string);  // calculated by salt_3bytes and its public-key
}

class Ciphertext {
  @Proto(1) uint     cipher_version          =  protoDefaultValue!uint;  // default 1
  @Proto(2) string  aes_iv_12bytes          =  protoDefaultValue!(string);  // randomly generated each time
  @Proto(3) string  ciphertext_nbytes       =  protoDefaultValue!(string);  // PlainText message serialized and encrypted
  @Proto(4) string  aes_tag_16bytes         =  protoDefaultValue!(string);  // generated after AES encryption
}


class EncryptedRequest {
  @Proto(1) Token            token           = protoDefaultValue!Token;  // The token to verify the identify of the client
  @Proto(2) Ciphertext       ciphertext      = protoDefaultValue!Ciphertext;   // It can be decrypted into PlainText message
}





enum MESSAGE : uint {
  INITIATE = 1000110001,
  FINALIZE = 2000120001
}
