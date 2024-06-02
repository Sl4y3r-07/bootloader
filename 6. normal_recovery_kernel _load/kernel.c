void kernel_main() {
    unsigned short *boot_mode = (unsigned short *)0x1000;

    if (*boot_mode == 1) {
        const char *message = "Normal Mode";
        print_string(message);
    } else if (*boot_mode == 2) {
        const char *message = "Recovery Mode";
        print_string(message);
    } else {
        const char *message = "Unknown Mode";
        print_string(message);
    }

    while (1) {
        asm("hlt");
    }
}

void print_string(const char *str) {
    unsigned short *video_memory = (unsigned short *)0xB8000;
    while (*str) {
        *video_memory++ = (*str++ | 0x0700); 
    }
}


void _start() {
    kernel_main();
}
