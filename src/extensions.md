# Extensions

Terminal, Browser and Text are extensions: each crate implements `extension::Extension` and
registers itself, and the workspace only talks to the `ExtensionRegistry`.

## Adding one

1. Depend on the `extension` crate. Implement `Item` (plus `EventEmitter<ItemEvent>`) for your view.
2. Implement `Extension`: `manifest` (id, name, description, icon) and `build_item` are required.
   Optional: `init` (key bindings, settings), `serialize_item`/`restore_item` (session),
   `open_path`/`item_path` (file handling), `launch_action` (a choice that runs an action instead of building a tab, e.g. Project asks for a folder).
3. Expose `register_extension(cx)` calling `ExtensionRegistry::register(Arc::new(MyExtension::new()), cx)`.
4. Call it from `app/src/main.rs` before `workspace::init`. Registration order is launcher order.

The launcher, the session store and file opening pick the extension up with no workspace changes.
