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

char *readLineAsNSString(FILE *file)
{
    size_t rc = fread(buffer, 5, 1, file);
    if(rc!=NULL)
        return &buffer;
    else
        return NULL;
}
          
          

          
          
void *myThreadFun(void *arguments)
{
   /* struct arg_struct *args = (struct arg_struct *)arguments;
    struct sockaddr_in sin;
    int s = socket(AF_INET, SOCK_STREAM,0);
    bzero((char *) &sin, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = inet_addr(args->host);
    sin.sin_port = htons(args->port);
    struct ifreq ifr;
    ifr.ifr_addr.sa_family = AF_INET;
    strncpy(ifr.ifr_name, args->interface, IFNAMSIZ-1);
    ioctl(s, SIOCGIFADDR, &ifr);
    struct sockaddr* ipaddr = (struct sockaddr*)&ifr.ifr_addr;
    int reuseOn = 1;
    bind(s, ipaddr, ipaddr->sa_len );
    connect(s,  (struct sockaddr*)&sin,sizeof(sin));
    char* message = args->message;
    char** p = str_split(message,'\n');
    int i;
    
    for (i = 0; *(p  + i); i++)
    {
        //reuseOn = 1;
        //setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *) &reuseOn, sizeof(int));
        //send(s,*(p + i),strlen(*(p + i))+1,0);
        printf("carattere=[%s]\n", *(p + i));
        printf(args->interface);
        //reuseOn = 0;
        //setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *) &reuseOn, sizeof(int));
        //free(*(p + i));
    }
    
    close(s);
    printf("%s\n", inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr));
    NSLog(@"finish \n");
    pthread_exit(NULL); */
    struct arg_thread *args = (struct arg_thread *)arguments;
    char* buffer ;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"package" ofType:@"json"];
    FILE *file = fopen([path cStringUsingEncoding: NSUTF8StringEncoding], "r");
    unsigned long int reuseOn = (unsigned long int)TRUE;

    //while((buffer = readLineAsNSString(file))!=NULL){
        //setsockopt(args->socket, IPPROTO_TCP, TCP_NODELAY, &reuseOn, sizeof(reuseOn));
       // UIImage *image = [UIImage imageNamed:@"bull_no_geometrie.jpg"];
       // NSUInteger size = strlen(buffer);
       // unsigned char array[size];
       // NSData* ddata = [NSData dataWithBytes:(const void *)buffer length:sizeof(unsigned char)*size];
    
    //NSData *data = UIImageJPEGRepresentation(image,FALSE);
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"bull_no_geometrie" ofType:@"jpg"];
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    printf("%lu", (unsigned long)data.length);
    uint8_t * bytePtr = (uint8_t  * )[data bytes];
     NSInteger totalData = [data length] / sizeof(uint8_t);
    
    // Here, For getting individual bytes from fileData, uint8_t is used.
    // You may choose any other data type per your need, eg. uint16, int32, char, uchar, ... .
    // Make sure, fileData has atleast number of bytes that a single byte chunk would need. eg. for int32, fileData length must be > 4 bytes. Makes sense ?
    
    // Now, if you want to access whole data (fileData) as an array of uint8_t
   
    //NSData *data = UIImagePNGRepresentation(image);
        //NSUInteger len = data.length;
        //uint8_t *bytes = (uint8_t *)[data bytes];
        //NSMutableString *result = [NSMutableString stringWithCapacity:len * 3];
        //[result appendString:@"["];
        //for (NSUInteger i = 0; i < len; i++) {
          //  if (i) {
           //     [result appendString:@","];
           // }
           // [result appendFormat:@"%d", bytes[i]];
        //}
        //[result appendString:@"]"];
        printf("\n");
        printf("%ld", (long)totalData);
        printf("\n");
        printf("%s", bytePtr);
        send(args->socket,bytePtr, totalData,0);
       // printf("char=[%s]\n", byteData );
        printf("\n");
        printf("%s", args->interfaccia);
        printf("\n");
        //usleep(1000);
        
    //}
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
        
        printf("Before Thread\n");
        int port = 50000;
        struct arg_struct *sim_args = (struct arg_struct *)malloc(sizeof(struct arg_struct));
        sim_args->host= "52.14.182.175";
        sim_args->interface = "pdp_ip0";
        sim_args->port = port;
        struct arg_struct *wifi_args = (struct arg_struct *)malloc(sizeof(struct arg_struct));
        wifi_args->host = "192.168.1.107";
        wifi_args->interface = "en0";
        wifi_args->port = port;

        /** PREPARO SOCKET SIM **/
//        struct sockaddr_in sin_sim;
//        int sim_socket = socket(AF_INET, SOCK_STREAM,0);
//        bzero((char *) &sin_sim, sizeof(sin_sim));
//        sin_sim.sin_family = AF_INET;
//        sin_sim.sin_addr.s_addr = inet_addr(sim_args->host);
//        sin_sim.sin_port = htons(sim_args->port);
//        struct ifreq ifr_sim;
//        ifr_sim.ifr_addr.sa_family = AF_INET;
//        strncpy(ifr_sim.ifr_name, sim_args->interface, IFNAMSIZ-1);
//        ioctl(sim_socket, SIOCGIFADDR, &ifr_sim);
//        struct sockaddr* ipaddr_sim = (struct sockaddr*)&ifr_sim.ifr_addr;
//        int reuseOn_sim = 1;
//        bind(sim_socket, ipaddr_sim, ipaddr_sim->sa_len );
//        connect(sim_socket,  (struct sockaddr*)&sin_sim,sizeof(sin_sim));
//
//        struct arg_thread *sim_thread_args = (struct arg_thread *)malloc(sizeof(struct arg_thread));
//        sim_thread_args->socket = sim_socket;
//        sim_thread_args->interfaccia = "sim";
//        sim_thread_args->_sockaddr =sin_sim;
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
        /** FINE PREPARAZIONE SOCKET WIFI **/
        printf("lancio threads");
      
        //pthread_create(&threads[0], NULL, myThreadFun, (void*)sim_thread_args);
        pthread_create(&threads[1], NULL, myThreadFun,  (void*)wifi_thread_args);
        //pthread_create(&threads[0], NULL, myThreadFun, (void*)sim_args);
        //pthread_create(&threads[1], NULL, myThreadFun,  (void*)wifi_args);
        //pthread_join(threads[1], NULL);pthread_join(threads[0], NULL);
        printf("After Thread\n");
        /* block until all threads complete
        for (int i = 0; i < NUM_THREADS; ++i) {
            pthread_join(threads[i], NULL);
        }*/
//
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
    
}








