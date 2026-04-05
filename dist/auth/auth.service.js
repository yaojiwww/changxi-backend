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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("../user/user.entity");
let AuthService = class AuthService {
    jwtService;
    userRepository;
    verifyCodes = {};
    constructor(jwtService, userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }
    generateCode() {
        return Math.floor(1000 + Math.random() * 9000).toString();
    }
    async sendCode(phoneNumber) {
        const code = this.generateCode();
        this.verifyCodes[phoneNumber] = code;
        setTimeout(() => delete this.verifyCodes[phoneNumber], 300000);
        console.log(`[短信服务] 已为手机号 ${phoneNumber} 生成验证码: ${code}`);
        return { code: 200, debugCode: code };
    }
    verifyCode(phoneNumber, code) {
        return this.verifyCodes[phoneNumber] === code;
    }
    async register(phoneNumber, code) {
        const isValid = this.verifyCode(phoneNumber, code);
        if (!isValid) {
            return { code: 400, msg: '验证码错误或已过期' };
        }
        const existingUser = await this.userRepository.findOne({ where: { phoneNumber } });
        if (existingUser) {
            const token = this.generateToken(existingUser);
            return { code: 200, msg: '登录成功', token, user: existingUser };
        }
        const user = new user_entity_1.User();
        user.phoneNumber = phoneNumber;
        user.accountName = `用户${phoneNumber.slice(-4)}`;
        const savedUser = await this.userRepository.save(user);
        delete this.verifyCodes[phoneNumber];
        const token = this.generateToken(savedUser);
        return { code: 200, msg: '注册成功', token, user: savedUser };
    }
    generateToken(user) {
        return this.jwtService.sign({ userId: user.id, phoneNumber: user.phoneNumber });
    }
    async login(phoneNumber, code) {
        const isValid = this.verifyCode(phoneNumber, code);
        if (!isValid) {
            return { code: 400, msg: '验证码错误或已过期' };
        }
        const user = await this.userRepository.findOne({ where: { phoneNumber } });
        if (!user) {
            return { code: 404, msg: '用户不存在' };
        }
        delete this.verifyCodes[phoneNumber];
        const token = this.generateToken(user);
        return { code: 200, msg: '登录成功', token, user };
    }
    async validateToken(payload) {
        return this.userRepository.findOne({ where: { id: payload.userId } });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        typeorm_2.Repository])
], AuthService);
//# sourceMappingURL=auth.service.js.map