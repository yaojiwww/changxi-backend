/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

macro package soulsoft_serialization.macros

import std.ast.*
import std.collection.*

protected class MacroUtilities {
    protected static func parseMacroArgumentsAsExpr(attr: Tokens): HashMap<String, Expr> {
        let syntheticCallExpr = CallExpr(quote(
            f($(attr))
        ))
        let arguments = HashMap<String, Expr>()
        for (argument in syntheticCallExpr.arguments) {
            arguments.add(argument.identifier.value, argument.expr)
        }
        return arguments
    }

    protected static func parseMacroArgumentsAsTokens(attr: Tokens): HashMap<String, Tokens> {
        let arguments = HashMap<String, Tokens>()
        for ((name, expr) in MacroUtilities.parseMacroArgumentsAsExpr(attr)) {
            arguments.add(name, expr.toTokens())
        }
        return arguments
    }
}
