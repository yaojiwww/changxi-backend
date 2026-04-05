"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BabyController = void 0;
const common_1 = require("@nestjs/common");
const baby_service_1 = require("./baby.service");
const create_baby_dto_1 = require("./dto/create-baby.dto");
const update_baby_dto_1 = require("./dto/update-baby.dto");
let BabyController = class BabyController {
    babyService;
    constructor(babyService) {
        this.babyService = babyService;
    }
    create(createBabyDto) {
        return this.babyService.create(createBabyDto);
    }
    findAll() {
        return this.babyService.findAll();
    }
    findByUserId(userId) {
        return this.babyService.findByUserId(+userId);
    }
    findOne(id) {
        return this.babyService.findOne(+id);
    }
    update(id, updateBabyDto) {
        return this.babyService.update(+id, updateBabyDto);
    }
    remove(id) {
        return this.babyService.remove(+id);
    }
};
exports.BabyController = BabyController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_baby_dto_1.CreateBabyDto]),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "findByUserId", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_baby_dto_1.UpdateBabyDto]),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], BabyController.prototype, "remove", null);
exports.BabyController = BabyController = __decorate([
    (0, common_1.Controller)('baby'),
    __metadata("design:paramtypes", [baby_service_1.BabyService])
], BabyController);
//# sourceMappingURL=baby.controller.js.map