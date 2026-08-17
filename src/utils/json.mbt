///|
/// JsonValue defines structured AST nodes for JSON data representation.
pub(all) enum JsonValue {
  JString(String)
  JNumber(Double)
  JBool(Bool)
  JNull
  JArray(Array[JsonValue])
  JObject(Map[String, JsonValue])
} derive(Eq, Debug)

///|
/// Creates a JSON String node.
pub fn jstr(s : String) -> JsonValue {
  JString(s)
}

///|
/// Creates a JSON Number node.
pub fn jnum(n : Double) -> JsonValue {
  JNumber(n)
}

///|
/// Creates a JSON Boolean node.
pub fn jbool(b : Bool) -> JsonValue {
  JBool(b)
}

///|
/// Creates a JSON Null node.
pub fn jnull() -> JsonValue {
  JNull
}

///|
/// Creates a JSON Array node from an Array of values.
pub fn jarray(items : Array[JsonValue]) -> JsonValue {
  JArray(items)
}

///|
/// Creates a JSON Object node from key-value tuples.
pub fn jobject(entries : Array[(String, JsonValue)]) -> JsonValue {
  let map : Map[String, JsonValue] = Map::from_array([])
  for entry in entries {
    let (k, v) = entry
    map.set(k, v)
  }
  JObject(map)
}

///|
/// Escapes special characters for JSON string literal output.
pub fn escape_json_string(s : String) -> String {
  let buf = StringBuilder::new()
  buf.write_string("\"")
  for ch in s {
    if ch == '"' {
      buf.write_string("\\\"")
    } else if ch == '\\' {
      buf.write_string("\\\\")
    } else if ch == '\n' {
      buf.write_string("\\n")
    } else if ch == '\r' {
      buf.write_string("\\r")
    } else if ch == '\t' {
      buf.write_string("\\t")
    } else {
      buf.write_char(ch)
    }
  }
  buf.write_string("\"")
  buf.to_string()
}

///|
/// Serializes JsonValue AST to formatted JSON string.
pub fn JsonValue::stringify(
  self : JsonValue,
  pretty? : Bool = true,
  indent_level? : Int = 0,
) -> String {
  let indent_str = if pretty {
    let buf = StringBuilder::new()
    for _i in 0..<indent_level {
      buf.write_string("  ")
    }
    buf.to_string()
  } else {
    ""
  }

  match self {
    JString(s) => escape_json_string(s)
    JNumber(n) => n.to_string()
    JBool(b) => if b { "true" } else { "false" }
    JNull => "null"
    JArray(arr) =>
      if arr.length() == 0 {
        "[]"
      } else if !pretty {
        let buf = StringBuilder::new()
        buf.write_string("[")
        for i, item in arr {
          if i > 0 {
            buf.write_string(",")
          }
          buf.write_string(item.stringify(pretty=false))
        }
        buf.write_string("]")
        buf.to_string()
      } else {
        let buf = StringBuilder::new()
        buf.write_string("[\n")
        let inner_indent = indent_str + "  "
        for i, item in arr {
          buf.write_string(inner_indent)
          buf.write_string(
            item.stringify(pretty=true, indent_level=indent_level + 1),
          )
          if i < arr.length() - 1 {
            buf.write_string(",")
          }
          buf.write_string("\n")
        }
        buf.write_string(indent_str)
        buf.write_string("]")
        buf.to_string()
      }
    JObject(obj) => {
      let keys : Array[String] = []
      for k, _ in obj {
        keys.push(k)
      }
      keys.sort()

      if keys.length() == 0 {
        "{}"
      } else if !pretty {
        let buf = StringBuilder::new()
        buf.write_string("{")
        for i, k in keys {
          if i > 0 {
            buf.write_string(",")
          }
          buf.write_string(escape_json_string(k))
          buf.write_string(":")
          match obj.get(k) {
            Some(v) => buf.write_string(v.stringify(pretty=false))
            None => buf.write_string("null")
          }
        }
        buf.write_string("}")
        buf.to_string()
      } else {
        let buf = StringBuilder::new()
        buf.write_string("{\n")
        let inner_indent = indent_str + "  "
        for i, k in keys {
          buf.write_string(inner_indent)
          buf.write_string(escape_json_string(k))
          buf.write_string(": ")
          match obj.get(k) {
            Some(v) =>
              buf.write_string(
                v.stringify(pretty=true, indent_level=indent_level + 1),
              )
            None => buf.write_string("null")
          }
          if i < keys.length() - 1 {
            buf.write_string(",")
          }
          buf.write_string("\n")
        }
        buf.write_string(indent_str)
        buf.write_string("}")
        buf.to_string()
      }
    }
  }
}
