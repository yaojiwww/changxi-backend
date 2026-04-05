import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../user/user.entity';

@Injectable()
export class AuthService {
  // 模拟数据库存储验证码 { "138xxx": "1234" }
  private verifyCodes: Record<string, string> = {};

  constructor(
    private jwtService: JwtService,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  // 生成4位验证码
  private generateCode(): string {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  // 发送验证码
  async sendCode(phoneNumber: string): Promise<{ code: number; debugCode: string }> {
    const code = this.generateCode();
    this.verifyCodes[phoneNumber] = code;

    // 5分钟过期
    setTimeout(() => delete this.verifyCodes[phoneNumber], 300000);

    console.log(`[短信服务] 已为手机号 ${phoneNumber} 生成验证码: ${code}`);
    return { code: 200, debugCode: code };
  }

  // 验证验证码
  verifyCode(phoneNumber: string, code: string): boolean {
    return this.verifyCodes[phoneNumber] === code;
  }

  // 注册（验证成功后自动创建用户）
  async register(phoneNumber: string, code: string): Promise<{
    code: number;
    msg: string;
    token?: string;
    user?: User;
  }> {
    const isValid = this.verifyCode(phoneNumber, code);
    if (!isValid) {
      return { code: 400, msg: '验证码错误或已过期' };
    }

    // 检查用户是否已存在
    const existingUser = await this.userRepository.findOne({ where: { phoneNumber } });
    if (existingUser) {
      // 已存在则直接登录
      const token = this.generateToken(existingUser);
      return { code: 200, msg: '登录成功', token, user: existingUser };
    }

    // 创建新用户
    const user = new User();
    user.phoneNumber = phoneNumber;
    user.accountName = `用户${phoneNumber.slice(-4)}`; // 默认昵称
    const savedUser = await this.userRepository.save(user);

    // 删除已使用的验证码
    delete this.verifyCodes[phoneNumber];

    const token = this.generateToken(savedUser);
    return { code: 200, msg: '注册成功', token, user: savedUser };
  }

  // 生成 JWT
  private generateToken(user: User): string {
    return this.jwtService.sign({ userId: user.id, phoneNumber: user.phoneNumber });
  }

  // 根据手机号登录
  async login(phoneNumber: string, code: string): Promise<{
    code: number;
    msg: string;
    token?: string;
    user?: User;
  }> {
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

  // 验证 JWT token
  async validateToken(payload: { userId: number; phoneNumber: string }): Promise<User | null> {
    return this.userRepository.findOne({ where: { id: payload.userId } });
  }
}
