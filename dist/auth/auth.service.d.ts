import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { User } from '../user/user.entity';
export declare class AuthService {
    private jwtService;
    private userRepository;
    private verifyCodes;
    constructor(jwtService: JwtService, userRepository: Repository<User>);
    private generateCode;
    sendCode(phoneNumber: string): Promise<{
        code: number;
        debugCode: string;
    }>;
    verifyCode(phoneNumber: string, code: string): boolean;
    register(phoneNumber: string, code: string): Promise<{
        code: number;
        msg: string;
        token?: string;
        user?: User;
    }>;
    private generateToken;
    login(phoneNumber: string, code: string): Promise<{
        code: number;
        msg: string;
        token?: string;
        user?: User;
    }>;
    validateToken(payload: {
        userId: number;
        phoneNumber: string;
    }): Promise<User | null>;
}
