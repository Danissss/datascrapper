/*
* 
* author: Xuan Cao xcao2@ualberta.ca
* 
*/
#include <ruby.h>
#include "get_identifier.h"



static VALUE call_get_ids(VALUE self) {
  get_ids();
}


// this is main initialization method
// initialize other module or class, you need create different init_whatever() function
void Init_scrapper() {
  VALUE Scrapper = rb_define_module( "Scrapper" );   // create Scrapper module 
  rb_define_singleton_method( Scrapper, "call_get_ids", call_get_ids, 0 );
}
