#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

#define DRIVER_AUTHOR "Kris Lamoureux"
#define DRIVER_DESC   "Hello world kernel module"

int init_module(void)
{
	printk(KERN_INFO "helloworld: hello, world\n");
	return 0;
}

void cleanup_module(void)
{
	printk(KERN_INFO "helloworld: goodbye, world\n");
}

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
