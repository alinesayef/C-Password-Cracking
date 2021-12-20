//Password is QV12
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <crypt.h>
#include <pthread.h>
#define SALT "$6$AS$"


char *salt_and_encrypted = "$6$AS$Bfb9BA3i7ScNTMAC77zpGxJO.dPRAn9sSPsGjkblj4fObPgtx8X8Yvqrh7GtQfRwi9CmF/PwyL6YAwQ2uLp2m1"; /* Define the encrypted passwrod*/

int passwordfound;

typedef struct arguments_t
{
  int start;
  int end;
  int ID;//Define threadID to print the number of thread
  char *salt_and_encrypted;
} arguments_t;

void substr(char *dest, char *src, int start, int length)
{
  memcpy(dest, src + start, length);
  *(dest + length) = '\0';
}

//method to crack the password
void *crack(void * argsp) {
  if (passwordfound) { pthread_exit(0);}
    arguments_t* args = (arguments_t*)argsp;

    int count = 0;
    char salt[7];    // String used in hashing the password. If salt value is modified, then this value should modified the number accordingly.

    int x, z, y;     // Loop counters
    char plain[7];   // The combination of letters of the password currently being checked.
    char *enc;       // Pointer to the encrypted password.
    substr(salt, salt_and_encrypted, 0, 6);

    printf("- Thread Number %i started: \n",args->ID); // Prints that a thread has started.
    printf("- Searching Range of Thread %i starts with %c: \n",args->ID, args->start);
    printf("- Searching Range of Thread %i ends with %c: \n",args->ID, args->end);

    for(x=args->start ; x<=args->end; x++){ //take the starting and ending arguments
        for(y='A'; y<='Z'; y++){
          for(z=0; z<=99; z++){
                    sprintf(plain, "%c%c%02d", x, y, z);
                    enc = (char *) crypt(plain, salt);
                    count++;



                    if (strcmp(salt_and_encrypted, enc) == 0) {
                        printf("Thread number %i has found the match: #%-8d%s %s\n", args->ID, count, plain, enc);

                       passwordfound = 1;

                       pthread_exit(0);
                    }
                }
        }
    }
  }



int main(int argc, char *argv[])
{
	//Ask the user to enter the number of threads
    int numOfThread;
    printf("Enter the number of threads:\n");
    scanf("%d",&numOfThread);

  pthread_t t[numOfThread];
  arguments_t t_arguments[numOfThread];

  /* Define the arguments for all threads. */
  int eachThreadPart=26/numOfThread;
  int start=65;
  for(int i=0;i<numOfThread;i++){
      t_arguments[i].start = start;
      t_arguments[i].end = start+eachThreadPart-1;
      t_arguments[i].ID = i;
      t_arguments[i].salt_and_encrypted = salt_and_encrypted;
      start=t_arguments[i].end+1;
  }
  t_arguments[numOfThread-1].end=90;
  passwordfound = 0;

//Create the threads
  for(int i=0;i<numOfThread;i++){
  pthread_create(&t[i], NULL, crack, &t_arguments[i]);
  }

//Join the threads
  for(int i=0;i<numOfThread;i++){
  pthread_join(t[i], NULL);
  }


  return 0;
}
