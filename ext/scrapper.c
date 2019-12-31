/*
* 
* author: Xuan Cao xcao2@ualberta.ca
* 
*/
#include "ruby.h"
#include "get_identifier.h"


// this is main initialization method
// initialize other module or class, you need create different init_whatever() function
void Init_scrapper() {
  VALUE Scrapper = rb_define_module( "Scrapper" );   // create Scrapper module
  VALUE 
  rb_define_singleton_method( Scrapper, "ext_test", method_ext_test, 0 );


}
