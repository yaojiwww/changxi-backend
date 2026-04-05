"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BabyModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const baby_service_1 = require("./baby.service");
const baby_controller_1 = require("./baby.controller");
const baby_entity_1 = require("./baby.entity");
const user_entity_1 = require("../user/user.entity");
let BabyModule = class BabyModule {
};
exports.BabyModule = BabyModule;
exports.BabyModule = BabyModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([baby_entity_1.Baby, user_entity_1.User])],
        controllers: [baby_controller_1.BabyController],
        providers: [baby_service_1.BabyService],
    })
], BabyModule);
//# sourceMappingURL=baby.module.js.map