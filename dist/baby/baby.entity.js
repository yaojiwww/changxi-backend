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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Baby = void 0;
const typeorm_1 = require("typeorm");
let Baby = class Baby {
    id;
    userId;
    babyName;
    gender;
    birthDate;
    height;
    weight;
    bloodType;
    avatarUrl;
    createAt;
    updateAt;
};
exports.Baby = Baby;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Baby.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'user_id' }),
    __metadata("design:type", Number)
], Baby.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, name: 'baby_name' }),
    __metadata("design:type", String)
], Baby.prototype, "babyName", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'tinyint', name: 'gender' }),
    __metadata("design:type", Number)
], Baby.prototype, "gender", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', name: 'birth_date' }),
    __metadata("design:type", Date)
], Baby.prototype, "birthDate", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'float', nullable: true }),
    __metadata("design:type", Number)
], Baby.prototype, "height", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'float', nullable: true }),
    __metadata("design:type", Number)
], Baby.prototype, "weight", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'tinyint', name: 'blood_type', nullable: true }),
    __metadata("design:type", Number)
], Baby.prototype, "bloodType", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 255, name: 'avatar_url', nullable: true }),
    __metadata("design:type", String)
], Baby.prototype, "avatarUrl", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'create_at' }),
    __metadata("design:type", Date)
], Baby.prototype, "createAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)({ name: 'update_at' }),
    __metadata("design:type", Date)
], Baby.prototype, "updateAt", void 0);
exports.Baby = Baby = __decorate([
    (0, typeorm_1.Entity)('baby')
], Baby);
//# sourceMappingURL=baby.entity.js.map