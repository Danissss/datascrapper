/*
 * call-seq:
 *  attribute_type
 *
 * The attribute_type for this AttributeDecl
 */
#include <get_identifier.h>


static VALUE get_ids(VALUE self)
{
  printf("I invoked Scrapper::GetIdentifier.get_ids\n", );
}



void init_get_identifier()
{
  VALUE Scrapper = rb_define_module("Scrapper"); // this is for defining the parent/boss module
  VALUE Identifier = rb_define_module_under(Scrapper, "GetIdentifier"); // then create submodule (under Scrapper)
  // VALUE node = rb_define_class_under(xml, "Node", rb_cObject); // this is define class under GetIdentifier submodule, but I don't like class
  rb_define_method(Identifier, "get_ids", get_ids, 0);  // define the method under identifier
}
