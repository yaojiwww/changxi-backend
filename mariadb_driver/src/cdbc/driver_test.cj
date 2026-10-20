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
package mariadb.cdbc

import std.time.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import std.math.numeric.*
import std.database.sql.*

@Test
protected class DriverTest {
    @TestCase
    public func mariadbTest(): Unit {
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        let username = ("username", "test_user")
        let password = ("password", "test_user")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        let dataSource = driver.open("mariadb://localhost:3306", [username, password, database, sslMode])
        let connection = dataSource.connect()
        insetTest(connection)
        queryTest(connection)
    }

    @TestCase
    public func mysqlTest(): Unit {
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        let username = ("username", "test_user")
        let password = ("password", "test_user")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        let dataSource = driver.open("mariadb://localhost:3306", [username, password, database, sslMode])
        let connection = dataSource.connect()
        insetTest(connection)
        queryTest(connection)

    }

    @TestCase
    public func tidbTest(): Unit {
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        let username = ("username", "root")
        let password = ("password", "")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        let dataSource = driver.open("mariadb://localhost:3306", [username, password, database, sslMode])
        let connection = dataSource.connect()
        insetTest(connection)
    }

    @TestCase
    public func ocaseBaseTest(): Unit {
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        let username = ("username", "root")
        let password = ("password", "")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        let dataSource = driver.open("mariadb://localhost:3306", [username, password, database, sslMode])
        let connection = dataSource.connect()
        insetTest(connection)
    }

    @TestCase
    public func pooledDatasourceTest(): Unit {
        let driver = DriverManager.getDriver("mariadb").getOrThrow()
        let username = ("username", "test_user")
        let password = ("password", "test_user")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        let timeout = ("pool.connection.timeout", "10")
        let idleTimeout = ("pool.idle.timeout", "1")
        let keepaliveTime = ("pool.keepalive.time", "0.5")
        let maxIdleSize = ("pool.max.idle.size", "30")
        let maxLifeTime = ("pool.max.life.time", "10")
        let maxSize = ("pool.max.size", "100")
        let params = ArrayList<(String, String)>()
        params.add(username)
        params.add(password)
        params.add(database)
        params.add(sslMode)
        params.add(timeout)
        params.add(idleTimeout)
        params.add(keepaliveTime)
        params.add(maxIdleSize)
        params.add(maxLifeTime)
        params.add(maxSize)
        let dataSource = driver.open("mariadb://localhost:3306", params.toArray())

        let pool = (dataSource as PooledDatasource) ?? throw Exception()
        //允许连接在池中闲置的最长时间，超过这个时间的空闲连接可能会被回收。默认值10m
        pool.idleTimeout |> println
        //连接池最大连接数量，负数或0表示无限制。默认值10
        pool.maxSize |> println
        //最大空闲连接数量，超过这个数量的空闲连接会被关闭，负数或0表示无限制。默认值0
        pool.maxIdleSize |> println
        //自连接创建以来的持续时间，在该持续时间之后，连接将自动关闭。单位 m， 默认值30m
        pool.maxLifeTime |> println
        //从池中获取连接的超时时间。默认值30s
        pool.connectionTimeout |> println
        // 检查空闲连接健康状况的间隔时间，防止它被数据库或网络基础设施超时。单位 m，默认值1m
        pool.keepaliveTime |> println
        let conn = dataSource.connect()
        conn.close()
        dataSource.connect()

    }
}

protected func insetTest(conn: Connection): Unit {
    numericInsertTest(conn)
    timeInsertTest(conn)
    characterInsertTest(conn)
}

protected func queryTest(conn: Connection): Unit {
    numericQueryTest(conn)
    timeInsertTest(conn)
    characterQueryTest(conn)
}

protected func numericInsertTest(conn: Connection): Unit {
    let sql = "INSERT INTO numeric_types (bool_col, bit_col, tinyint_col, utinyint_col, smallint_col, usmallint_col, mediumint_col, umediumint_col, int_col, uint_col, bigint_col, ubigint_col, float_col, double_col, decimal_col) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    let statement = conn.prepareStatement(sql)
    //insert null
    statement.update()
    // insert min
    statement.set<Bool>(1, false)
    statement.set<Array<Byte>>(2, [])
    statement.set<Int8>(3, Int8.Min)
    statement.set<UInt8>(4, UInt8.Min)
    statement.set<Int16>(5, Int16.Min)
    statement.set<UInt16>(6, UInt16.Min)
    statement.set<Int32>(7, -8388608)
    statement.set<UInt32>(8, 0)
    statement.set<Int32>(9, Int32.Min)
    statement.set<UInt32>(10, UInt32.Min)
    statement.set<Int64>(11, Int64.Min)
    statement.set<UInt64>(12, UInt64.Min)
    statement.set<Float32>(13, Float32.Min)
    statement.set<Float64>(14, Float64.Min)
    statement.set<Decimal>(15, Decimal.parse("1.23456789"))
    statement.update()
    // //insert max
    statement.set<Bool>(1, true)
    statement.set<Array<Byte>>(2, [1, 2, 3, 4])
    statement.set<Int8>(3, Int8.Max)
    statement.set<UInt8>(4, UInt8.Max)
    statement.set<Int16>(5, Int16.Max)
    statement.set<UInt16>(6, UInt16.Max)
    statement.set<Int32>(7, 8388607)
    statement.set<UInt32>(8, 16777215)
    statement.set<Int32>(9, Int32.Max)
    statement.set<UInt32>(10, UInt32.Max)
    statement.set<Int64>(11, Int64.Max)
    statement.set<UInt64>(12, UInt64.Max)
    statement.set<Float32>(13, Float32.Max)
    statement.set<Float64>(14, Float64.Max)
    statement.set<Decimal>(15, Decimal.parse("1.23456789"))
    statement.update()
}

protected func timeInsertTest(conn: Connection): Unit {
    let sql = "INSERT INTO time_types (date_col, time_col, datetime_col, timestamp_col, year_col) VALUES (?, ?, ?, ?, ?);"
    let statement = conn.prepareStatement(sql)
    //insert null
    statement.update()
    //insert value
    statement.set<DateTime>(1, DateTime.now())
    statement.set<DateTime>(2, DateTime.now())
    statement.set<DateTime>(3, DateTime.now())
    statement.set<DateTime>(4, DateTime.now())
    statement.set<Int64>(5, 2077)
    statement.update()
}

protected func characterInsertTest(conn: Connection): Unit {
    let sql = "INSERT INTO character_types (char_col, varchar_col, tinytext_col, text_col, mediumtext_col, longtext_col, tinyblob_col, blob_col, mediumblob_col, longblob_col, json_col, set_col, enum_col) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    let statement = conn.prepareStatement(sql)
    //insert null
    statement.update()
    statement.set<String>(1, "我冒了严寒，回到相隔二千余里，别了二十余年的故乡去。")
    statement.set<String>(2, "时候既然是深冬；渐近故乡时，天气又阴晦了，冷风吹进船舱中")
    statement.set<String>(3, "于是我自己解释说：故乡本也如此，——虽然没有进步，也未必有如我所感的悲凉")
    statement.set<String>(4,
        "我所记得的故乡全不如此。我的故乡好得多了。但要我记起他的美丽，说出他的佳处来，却又没有影像，没有言辞了。仿佛也就如此。"
    )
    statement.set<String>(5,
        "但我们终于谈到搬家的事。我说外间的寓所已经租定了，又买了几件家具，此外须将家里所有的木器卖去，再去增添。母亲也说好，而且行李也略已齐集，木器不便搬运的，也小半卖去了，只是收不起钱来。\r\n\r\n“你休息一两天，去拜望亲戚本家一回，我们便可以走了。”母亲说。\r\n\r\n“是的。”\r\n\r\n“还有闰土，他每到我家来时，总问起你，很想见你一回面。我已经将你到家的大约日期通知他，他也许就要来了。”\r\n\r\n这时候，我的脑里忽然闪出一幅神异的图画来：深蓝的天空中挂着一轮金黄的圆月，下面是海边的沙地，都种着一望无际的碧绿的西瓜，其间有一个十一二岁的少年，项带银圈，手捏一柄钢叉，向一匹猹⑵尽力的刺去，那猹却将身一扭，反从他的胯下逃走了。"
    )
    statement.set<String>(6,
        "这少年便是闰土。我认识他时，也不过十多岁，离现在将有三十年了；那时我的父亲还在世，家景也好，我正是一个少爷。那一年，我家是一件大祭祀的值年⑶。这祭祀，说是三十多年才能轮到一回，所以很郑重；正月里供祖像，供品很多，祭器很讲究，拜的人也很多，祭器也很要防偷去。我家只有一个忙月（我们这里给人做工的分三种：整年给一定人家做工的叫长工；按日给人做工的叫短工；自己也种地，只在过年过节以及收租时候来给一定人家做工的称忙月），忙不过来，他便对父亲说，可以叫他的儿子闰土来管祭器的。\r\n\r\n我的父亲允许了；我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\r\n\r\n我于是日日盼望新年，新年到，闰土也就到了。好容易"
    )
    statement.set<Array<Byte>>(7, [])
    statement.set<Array<Byte>>(8, Array<Byte>(1024, repeat: 0))
    statement.set<Array<Byte>>(9, Array<Byte>(1024 * 1024, repeat: 0))
    //longblob
    statement.set<Array<Byte>>(10, Array<Byte>(1024 * 1024, repeat: 0))
    //json
    statement.set<String>(11, '{"name":"yesokim", "age": 22, "sex": 1}')
    //set
    statement.set<String>(12, "value1,value2")
    //enum
    statement.set<String>(13, "value1")
    statement.update()
}

protected func numericQueryTest(conn: Connection): Unit {
    let statement = conn.prepareStatement("select * from numeric_types")
    let result = statement.query()
    while (result.next()) {
        result.getOrNull<Bool>(1) |> println
        result.getOrNull<Array<Byte>>(2) |> println
        result.getOrNull<Int8>(3) |> println
        result.getOrNull<UInt8>(4) |> println
        result.getOrNull<Int16>(5) |> println
        result.getOrNull<UInt16>(6) |> println
        result.getOrNull<Int32>(7) |> println
        result.getOrNull<UInt32>(8) |> println
        result.getOrNull<Int32>(9) |> println
        result.getOrNull<UInt32>(10) |> println
        result.getOrNull<Int64>(11) |> println
        result.getOrNull<UInt64>(12) |> println
        result.getOrNull<Float32>(13) |> println
        result.getOrNull<Float64>(14) |> println
        result.getOrNull<Decimal>(15) |> println
    }
}

protected func timeQueryTest(conn: Connection): Unit {
    let statement = conn.prepareStatement("select * from time_types")
    let result = statement.query()
    while (result.next()) {
        result.getOrNull<DateTime>(1) |> println
        result.getOrNull<DateTime>(2) |> println
        result.getOrNull<DateTime>(3) |> println
        result.getOrNull<DateTime>(4) |> println
        result.getOrNull<Int16>(5) |> println
    }
}

protected func characterQueryTest(conn: Connection): Unit {
    let statement = conn.prepareStatement("select * from character_types")
    let result = statement.query()
    while (result.next()) {
        result.getOrNull<String>(1) |> println
        result.getOrNull<String>(2) |> println
        result.getOrNull<String>(3) |> println
        result.getOrNull<String>(4) |> println
        result.getOrNull<String>(5) |> println
        result.getOrNull<String>(6) |> println
        (result.getOrNull<Array<Byte>>(7) ?? []).size |> println
        (result.getOrNull<Array<Byte>>(8) ?? []).size |> println
        (result.getOrNull<Array<Byte>>(9) ?? []).size |> println
        (result.getOrNull<Array<Byte>>(10) ?? []).size |> println
        result.getOrNull<String>(11) |> println
        result.getOrNull<String>(12) |> println
        result.getOrNull<String>(13) |> println
    }
}
