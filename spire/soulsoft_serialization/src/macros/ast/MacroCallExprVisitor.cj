/*
 * Copyright (c) 杭州颉创科技有限公司 2025. All rights reserved.
 * This source file is licensed under the MIT License found in the
 * LICENSE file in the root directory of this source tree.
 */

package soulsoft_serialization.macros.ast

import std.ast.*
import std.collection.*

protected class MacroCallExprVisitor<T> <: Visitor where T <: Decl {
    private var _matchedDecl: ?T = None
    private let _capturedMacros = ArrayList<MacroExpandDecl>()

    private func tryCapture(decl: Decl): Unit {
        if (let decl: T <- decl) {
            _matchedDecl = decl
            this.breakTraverse()
        }
    }

    public override func visit(decl: MacroExpandDecl) {
        // 这里重新构造一份独立的宏声明，避免把最终目标声明本身当成“前置宏”收进去。
        let tokens = quote(@$(decl.identifier)[$(decl.macroAttrs)]())
        if (let decl: MacroExpandDecl <- parseDecl(tokens)) {
            _capturedMacros.add(decl)
        }
    }

    public override func visit(decl: PropDecl) {
        tryCapture(decl)
    }

    public override func visit(decl: VarDecl) {
        tryCapture(decl)
    }

    public override func visit(decl: ClassDecl) {
        tryCapture(decl)
    }

    public override func visit(decl: StructDecl) {
        tryCapture(decl)
    }

    public func getResult(): ?MacroCallExpr<T> {
        if (let Some(decl) <- _matchedDecl) {
            return MacroCallExpr<T>(decl, _capturedMacros)
        }
        return None
    }
}
