# Description
Both the C and CUDA program can crack an encrypted 2 letter, 2 number password. EncryptSHA512.c generates an encrypted password.

# Compile Commands

C password cracking

gcc Password_Cracking.c -pthread -lcrypt


CUDA password cracking

nvcc Password_Cracking.cu

# Disclaimer

There is no guarantee that this code will work perfectly. It has been published in the spirit of benefiting the GitHub community.
