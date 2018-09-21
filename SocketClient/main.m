//
//  main.m
//  SocketClient
//
//  Created by riccardo on 13/09/18.
//  Copyright © 2018 amadio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <assert.h>
#include <pthread.h>
#include <net/if.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h> /* for strncpy */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>    // for TCP_NODELAY
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/file.h>

struct arg_struct {
    char *interface;
    char *host;
    int port;
};

struct arg_thread {
    int socket;
    char* interfaccia;
    struct sockaddr_in _sockaddr;
    int percentuale;
    
};

char** str_split(char* a_str, const char a_delim)
{
    char** result    = 0;
    size_t count     = 0;
    char* tmp        = a_str;
    char* last_comma = 0;
    char delim[2];
    delim[0] = a_delim;
    delim[1] = 0;
    
    /* Count how many elements will be extracted. */
    while (*tmp)
    {
        if (a_delim == *tmp)
        {
            count++;
            last_comma = tmp;
        }
        tmp++;
    }
    
    /* Add space for trailing token. */
    count += last_comma < (a_str + strlen(a_str) - 1);
    
    /* Add space for terminating null string so caller
     knows where the list of returned strings ends. */
    count++;
    
    result = malloc(sizeof(char*) * count);
    
    if (result)
    {
        size_t idx  = 0;
        char* token = strtok(a_str, delim);
        
        while (token)
        {
            assert(idx < count);
            *(result + idx++) = strdup(token);
            token = strtok(0, delim);
        }
        assert(idx == count - 1);
        *(result + idx) = 0;
    }
    
    return result;
}


char buffer[5];

/*char *readLineAsNSString(FILE *file)
 {
 size_t rc = fread(buffer, 5, 1, file);
 if(rc!=NULL)
 return &buffer;
 else
 return NULL;
 }*/

const char* fileBytes;
NSUInteger lengthFileBytes;

void initStream()
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"foto" ofType:@"jpg"];
    NSData * fileData = [NSData dataWithContentsOfFile: path];
    
    fileBytes = (const char*)[fileData bytes];
    lengthFileBytes = [fileData length];
}
int count=0;
unsigned char get()
{
    unsigned char c;
    if(count<(int)lengthFileBytes)
    {
        c = fileBytes[count];
        return c;
    }
    return c;
}



void *myThreadFun(void *arguments)
{
    
    struct arg_thread *args = (struct arg_thread *)arguments;
    unsigned long int reuseOn = (unsigned long int)TRUE;
    //while((buffer = readLineAsNSString(file))!=NULL){
    //setsockopt(args->socket, IPPROTO_TCP, TCP_NODELAY, &reuseOn, sizeof(reuseOn));
    
    //printf("%s", buffer);
    setsockopt(args->socket, IPPROTO_TCP, TCP_NODELAY, 1, sizeof(int));
    int percentuale = (args->percentuale * (int)lengthFileBytes)/100;
    printf("%d", percentuale);
    for(int i =0;i<percentuale;i=i+1)
    {
        unsigned char a[1] ;
        unsigned int local_count = count;
        a[0]=get();

        //strncpy(buff, &fileBytes[i], 3);
        //char str[12];
        /*
         sprintf(str, "%d", i);
         NSError* error = nil;
         NSString *buffer = [NSString stringWithFormat:@"%s", buff];
         NSString *strString = [NSString stringWithFormat:@"%s", str];
         NSArray *array =[NSArray arrayWithObjects: buffer,strString, nil];
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];*/
        //printf(aByte);
        //char *msg[2] ;
        //msg[0] = aByte;
        //msg[1] = "\n";
        
        
        unsigned char c[2];
        memcpy(c, (unsigned char*)&local_count, 2);
        printf("%lu", sizeof(c));
        printf("\n");
        printf("chunkid ");
        printf("%s", args->interfaccia);
        printf("\n");
        printf("%s",c);
        printf("\n");
        unsigned char d[3];
        d[0]=a[0];
        for(int i=0;i<2;i++)
        {
            d[i+1]=c[i];
        }
        send(args->socket, d, 3, 0);
        count++;
    }
    //printf("sended");
    //printf("%d", count);
    //usleep(1000);
    
    //}
    printf("%d", count);
    close(args->socket);
    
    //reuseOn = 0;
    //setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *) &reuseOn, sizeof(int));
    //free(*(p + i));
    
    pthread_exit(NULL);
}

#define NUM_THREADS 2



int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        pthread_t threads[NUM_THREADS];
        initStream();
        int port = 3306;
        struct arg_struct *sim_args = (struct arg_struct *)malloc(sizeof(struct arg_struct));
        sim_args->host= "18.191.173.32";
        sim_args->interface = "pdp_ip0";
        sim_args->port = 3306;
        struct arg_struct *wifi_args = (struct arg_struct *)malloc(sizeof(struct arg_struct));
        wifi_args->host = "10.0.3.12";
        wifi_args->interface = "en0";
        wifi_args->port = 2000;
        
        
        /** PREPARO SOCKET SIM **/
                struct sockaddr_in sin_sim;
                int sim_socket = socket(AF_INET, SOCK_STREAM,0);
                bzero((char *) &sin_sim, sizeof(sin_sim));
                sin_sim.sin_family = AF_INET;
                sin_sim.sin_addr.s_addr = inet_addr(sim_args->host);
                sin_sim.sin_port = htons(sim_args->port);
                struct ifreq ifr_sim;
                ifr_sim.ifr_addr.sa_family = AF_INET;
                strncpy(ifr_sim.ifr_name, sim_args->interface, IFNAMSIZ-1);
                ioctl(sim_socket, SIOCGIFADDR, &ifr_sim);
                struct sockaddr* ipaddr_sim = (struct sockaddr*)&ifr_sim.ifr_addr;
                int reuseOn_sim = 1;
                bind(sim_socket, ipaddr_sim, ipaddr_sim->sa_len );
                connect(sim_socket,  (struct sockaddr*)&sin_sim,sizeof(sin_sim));
        
                struct arg_thread *sim_thread_args = (struct arg_thread *)malloc(sizeof(struct arg_thread));
                sim_thread_args->socket = sim_socket;
                sim_thread_args->interfaccia = "sim";
                sim_thread_args->_sockaddr =sin_sim;
                sim_thread_args->percentuale = 50;
        /** FINE PREPARAZIONE SOCKET SIM **/
        
        /** PREPARO SOCKET WIFI**/
        struct sockaddr_in sin_wifi;
        int wifi_socket = socket(AF_INET, SOCK_STREAM,0);
        bzero((char *) &sin_wifi, sizeof(sin_wifi));
        sin_wifi.sin_family = AF_INET;
        sin_wifi.sin_addr.s_addr = inet_addr(wifi_args->host);
        sin_wifi.sin_port = htons(wifi_args->port);
        struct ifreq ifr_wifi;
        ifr_wifi.ifr_addr.sa_family = AF_INET;
        strncpy(ifr_wifi.ifr_name, wifi_args->interface, IFNAMSIZ-1);
        ioctl(wifi_socket, SIOCGIFADDR, &ifr_wifi);
        struct sockaddr* ipaddr_wifi = (struct sockaddr*)&ifr_wifi.ifr_addr;
        int reuseOn_wifi = 1;
        bind(wifi_socket, ipaddr_wifi, ipaddr_wifi->sa_len );
        connect(wifi_socket,  (struct sockaddr*)&sin_wifi,sizeof(sin_wifi));
        struct arg_thread *wifi_thread_args = (struct arg_thread *)malloc(sizeof(struct arg_thread));
        wifi_thread_args->socket = wifi_socket;
        wifi_thread_args->interfaccia = "wifi";
        wifi_thread_args->_sockaddr =sin_wifi;
        wifi_thread_args->percentuale = 50;
        /** FINE PREPARAZIONE SOCKET WIFI **/
        for (int i = 0; i < NUM_THREADS; i++)
        {
            if (i == 0)
                pthread_create(&threads[0], NULL, myThreadFun, (void*)sim_thread_args);
            else
                pthread_create(&threads[1], NULL, myThreadFun,  (void*)wifi_thread_args);
            
        }
        for (int i = 0; i < 2; i++)
            pthread_join(threads[i], NULL);
        
        //pthread_create(&threads[0], NULL, myThreadFun, (void*)sim_args);
        //pthread_create(&threads[1], NULL, myThreadFun,  (void*)wifi_args);
        //pthread_join(threads[1], NULL);pthread_join(threads[0], NULL);
        /* block until all threads complete
         for (int i = 0; i < NUM_THREADS; ++i) {
         pthread_join(threads[i], NULL);
         }*/
        //
        
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
    
}









