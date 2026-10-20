/*
 * Copyright (C) 2024 Yesokim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
protected package mariadb.connection

import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*


/*
* 测试认证插件的兼容情况
* default: caching_sha2_password -> use: caching_sha2_password ssl:close √
* default: caching_sha2_password -> use: mariadb_native_password ssl:close √
* default: caching_sha2_password -> use: sha256_password ssl:close √
* default: caching_sha2_password -> use: caching_sha2_password ssl: open √
* default: caching_sha2_password -> use: mariadb_native_password ssl: open √
* default: caching_sha2_password -> use: sha256_password ssl: open √

* default: sha256_password -> use: caching_sha2_password ssl:close √
* default: sha256_password -> use: mariadb_native_password ssl:close √
* default: sha256_password -> use: sha256_password ssl:close √
* default: sha256_password -> use: caching_sha2_password ssl: open √
* default: sha256_password -> use: mariadb_native_password ssl: open √
* default: sha256_password -> use: sha256_password ssl: open √

* default: mariadb_native_password -> use: caching_sha2_password ssl:close √
* default: mariadb_native_password -> use: mariadb_native_password ssl:close √
* default: mariadb_native_password -> use: sha256_password ssl:close √
* default: mariadb_native_password -> use: caching_sha2_password ssl: open √
* default: mariadb_native_password -> use: mariadb_native_password ssl: open √
* default: mariadb_native_password -> use: sha256_password ssl: open √
*/
// @Test
// public class MariaConnectionTest {


//     @TestCase
//     public func case1(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "caching_user")
//         attr.add(Params.Password, "caching_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         attr.add(Params.SSLMode, "disabled")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

//     @TestCase
//     public func case2(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "native_user")
//         attr.add(Params.Password, "native_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         attr.add(Params.SSLMode, "disabled")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

//     @TestCase
//     public func case3(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "sha256_user")
//         attr.add(Params.Password, "sha256_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         attr.add(Params.SSLMode, "disabled")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

//     @TestCase
//     public func case4(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "caching_user")
//         attr.add(Params.Password, "caching_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

//     @TestCase
//     public func case5(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "native_user")
//         attr.add(Params.Password, "native_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

//     @TestCase
//     public func case6(): Unit {
//         var attr = HashMap<String, String>()
//         attr.add(Params.Username, "sha256_user")
//         attr.add(Params.Password, "sha256_user")
//         attr.add(Params.Host, "localhost")
//         attr.add(Params.Port, "3306")
//         var conn = createAuthedConnection(attr)
//         conn.close()
//     }

// }