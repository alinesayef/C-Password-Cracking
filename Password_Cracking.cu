#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__device__ char pwdFound[4];

__device__ __host__ void CudaCrypt(char* rawPassword, char* encryptedPassword) {
	encryptedPassword[0] = rawPassword[0] + 2;
	encryptedPassword[1] = rawPassword[0] - 2;
	encryptedPassword[2] = rawPassword[0] + 1;
	encryptedPassword[3] = rawPassword[1] + 3;
	encryptedPassword[4] = rawPassword[1] - 3;
	encryptedPassword[5] = rawPassword[1] - 1;
	encryptedPassword[6] = rawPassword[2] + 2;
	encryptedPassword[7] = rawPassword[2] - 2;
	encryptedPassword[8] = rawPassword[3] + 4;
	encryptedPassword[9] = rawPassword[3] - 4;
	encryptedPassword[10] = '\0';

	for (int i = 0; i < 10; i++) {
		if (i >= 0 && i < 6) { //checking all lower case letter limits
			if (encryptedPassword[i] > 122) {
				encryptedPassword[i] = (encryptedPassword[i] - 122) + 97;
			}
			else if (encryptedPassword[i] < 97) {
				encryptedPassword[i] = (97 - encryptedPassword[i]) + 97;
			}
		}
		else { //checking number section
			if (encryptedPassword[i] > 57) {
				encryptedPassword[i] = (encryptedPassword[i] - 57) + 48;
			}
			else if (encryptedPassword[i] < 48) {
				encryptedPassword[i] = (48 - encryptedPassword[i]) + 48;
			}
		}
	}
}

__global__ void crack(char* alphabet, char* numbers, char* encryptedPwdToFind) {
	char genRawPass[4];
	
	genRawPass[0] = alphabet[blockIdx.x];
	genRawPass[1] = alphabet[blockIdx.y];
	genRawPass[2] = numbers[threadIdx.x];
	genRawPass[3] = numbers[threadIdx.y];
	
	char newPassword[11];


	CudaCrypt(genRawPass, newPassword); //run the CudaCrypt function


	for (int i = 0; i < 10; ++i) {
		if (newPassword[i] != encryptedPwdToFind[i]) {
			return;
		}
	}
	
	pwdFound[0] = genRawPass[0];
	pwdFound[1] = genRawPass[1];
	pwdFound[2] = genRawPass[2];
	pwdFound[3] = genRawPass[3];
	
	printf("Encrypted Password provided: %s\n", encryptedPwdToFind);
	printf("Password found: %c%c%c%c\n", pwdFound[0],pwdFound[1],pwdFound[2],pwdFound[3]); //print the found password
}

int main(int argc, char** argv) {
	char* commands = "Usage:\nhash [clear password]\ndecrypt [hash of the password]\nhashndecrypt [clear password]\n\n"; //sets possible commands to a "command" variable.

	char encryptedPwdToFind[11];
	strcpy(encryptedPwdToFind, "cxbdwy2745"); // The default encrypted password to decrypt.

//Determine the type of command input
	if (argc == 3) {
		if (!strcmp(argv[1], "hash")) {
			if (strlen(argv[2]) != 4) {
				printf("%s\n", commands);
				return 1;
			}
			char hash[11];
			CudaCrypt(argv[2], hash);
			printf("Hash generated: %s\n", hash);
			return 0;
		}
		else if (!strcmp(argv[1], "decrypt")) {
			if (strlen(argv[2]) != 10) {
				printf("%s\n", commands);
				return 1;
			}
			strcpy(encryptedPwdToFind, argv[2]);
		}
		else if (!strcmp(argv[1], "hashndecrypt")) {
			if (strlen(argv[2]) != 4) {
				printf("%s\n", commands);
				return 1;
			}
			CudaCrypt(argv[2], encryptedPwdToFind);
		}
		else {
			printf("%s\n", commands);
			return 1;
		}
	}
	
	//Output possible commands to the user
	else if (argc > 1) {
		printf("%s\n", commands);
		return 1;
	}

	printf("Trying to find the password for %s\n", encryptedPwdToFind);

//Array for numbers and letters of the alphabet
	char cpuAlphabet[26] = { 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z' };
	char cpuNumbers[10] = { '0','1','2','3','4','5','6','7','8','9' };

//Allocate memory for the letters of the alphabet and copy them from host to the device
	char* gpuAlphabet;
	cudaMalloc((void**)&gpuAlphabet, sizeof(char) * 26);
	cudaMemcpy(gpuAlphabet, cpuAlphabet, sizeof(char) * 26, cudaMemcpyHostToDevice);

//Allocate memory for the numbers and copy them from host to the device
	char* gpuNumbers;
	cudaMalloc((void**)&gpuNumbers, sizeof(char) * 10);
	cudaMemcpy(gpuNumbers, cpuNumbers, sizeof(char) * 10, cudaMemcpyHostToDevice);


	char* gpuEncryptedPwdToFind;
	cudaMalloc((void**)&gpuEncryptedPwdToFind, sizeof(char) * 11);
	cudaMemcpy(gpuEncryptedPwdToFind, encryptedPwdToFind, sizeof(char) * 11, cudaMemcpyHostToDevice);

	crack << < dim3(26, 26), dim3(10, 10) >> > (gpuAlphabet, gpuNumbers, gpuEncryptedPwdToFind);

	cudaDeviceSynchronize();
	
	//Free allocated memory
	cudaFree(gpuAlphabet);
	cudaFree(gpuNumbers);
	cudaFree(gpuEncryptedPwdToFind);
	
}













