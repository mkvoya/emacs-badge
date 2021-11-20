#import <Cocoa/Cocoa.h>

#include "emacs-module.h"

#ifdef DEBUG
#define dprintf(fmt, ...) fprintf(stderr, fmt, ##__VA_ARGS__)
#else
#define dprintf(fmt, ...)
#endif

int plugin_is_GPL_compatible = 1;

/* Frequently-used symbols. */
static emacs_value Qnil;
static emacs_value Qt;

static emacs_value
update_badge(emacs_env *env, ptrdiff_t n, emacs_value *args, void *_)
{
  ptrdiff_t len;
  bool succ = env->copy_string_contents(env, args[0], NULL, &len);
  if (!succ) {
    fprintf(stderr, "error getting the string length.\n");
    return Qnil;
  }
  char *buffer = malloc(len + 1); // It seems that we don't need to +1 here, but whatever.
  if (!buffer) {
    fprintf(stderr, "error allocating memory for the string content.\n");
    return Qnil;
  }

  succ = env->copy_string_contents(env, args[0], buffer, &len);
  if (!succ) {
    fprintf(stderr, "error getting the string content.\n");
    free(buffer);
    return Qnil;
  }

  dprintf ("%s label: %s\n", __func__, buffer);

  [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]];

  free(buffer);

  return Qt;
}

int
emacs_module_init (struct emacs_runtime *ert)
{
  emacs_env *env = ert->get_environment (ert);
  // Symbols
  Qt = env->make_global_ref (env, env->intern(env, "t"));
  Qnil = env->make_global_ref (env, env->intern(env, "nil"));

  emacs_value Femacs_badge;
  Femacs_badge = env->make_function (env, 1, 1, /* Take exactly 1 parameter -- the badget label to show. */
                                     update_badge, "Update the badge label on the Emacs dock icon.", NULL);
  emacs_value symbol = env->intern (env, "emacs-badge--update"); /* the symbol */
  emacs_value args[] = {symbol, Femacs_badge};
  env->funcall (env, env->intern (env, "defalias"), 2, args);

  emacs_value Qfeat = env->intern (env, "emacs-badge-module");
  emacs_value Qprovide = env->intern (env, "provide");
  env->funcall (env, Qprovide, 1, (emacs_value[]){Qfeat});

  return 0;
}
