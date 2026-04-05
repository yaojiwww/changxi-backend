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
exports.BabyService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const baby_entity_1 = require("./baby.entity");
const user_entity_1 = require("../user/user.entity");
let BabyService = class BabyService {
    babyRepository;
    userRepository;
    constructor(babyRepository, userRepository) {
        this.babyRepository = babyRepository;
        this.userRepository = userRepository;
    }
    async create(createBabyDto) {
        const baby = new baby_entity_1.Baby();
        Object.assign(baby, createBabyDto);
        return this.babyRepository.save(baby);
    }
    async findAll() {
        return this.babyRepository.find();
    }
    async findOne(id) {
        return this.babyRepository.findOne({ where: { id } });
    }
    async findByUserId(userId) {
        const babies = await this.babyRepository.find({ where: { userId } });
        const user = await this.userRepository.findOne({ where: { id: userId } });
        const currentBabyId = user?.currentBabyId;
        return babies.map((baby) => ({
            ...baby,
            isCurrent: baby.id === currentBabyId,
        }));
    }
    async update(id, updateBabyDto) {
        const { userId, ...rest } = updateBabyDto;
        await this.babyRepository.update(id, rest);
        return this.findOne(id);
    }
    async remove(id) {
        await this.babyRepository.delete(id);
    }
};
exports.BabyService = BabyService;
exports.BabyService = BabyService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(baby_entity_1.Baby)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], BabyService);
//# sourceMappingURL=baby.service.js.map