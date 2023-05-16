local sha = require"sha2"
    local hmac = sha.hmac
    local  data  =  hmac(sha.sha256, "MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQBQQxM3UE0xWVqxnSfoYu4+XDICb+WTaZ87wGMFsSm7CizsniDVn0B+Xjptoz1PBSA7n0G5FOb7OPHpg8rH4gVoNcx9kZgBES5v7WX2Awr73wMHJiXMDR1KQA/iVRUzTXIz3k44U58qkkxljJ4SxKgxSmXmSJkK1vPSNdzvK9vN6zldqHV/iK7c/ZMiykWYUHUqwkQcCQM8+e4W+FJIGwHjiP6UOJRnQPsL5xCpTDkdzlJGyd6+cP8BCInWMrrWOvy1dJCl+Vl935/bU1bblApwEYUBh4SLsLEthbFPmXoqNUBKrWSrrcr486wpLq/FKM776LGiRt23DOCRY971AU1lAgMBAAE=", "The quick brown fox jumps over the lazy dog")
    print(data)
